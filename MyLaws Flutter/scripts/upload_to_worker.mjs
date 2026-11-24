import fs from 'node:fs';
import path from 'node:path';

const WORKER_URL = process.env.WORKER_URL || 'https://mylaws-model-uploader.fork-x-master.workers.dev';
const SECRET = process.env.UPLOAD_SECRET || '';
const KEY = process.env.KEY || process.argv[2] || 'Qwen2.5-0.5B-Instruct-Q4_K_M.gguf';

// Path to local model
const MODEL_PATH = path.resolve(process.env.MODEL_PATH || process.argv[3] || 'D:\\Download\\Qwen2.5-0.5B-Instruct-Q4_K_M.gguf');
if (!fs.existsSync(MODEL_PATH)) {
  console.error(`File not found: ${MODEL_PATH}`);
  process.exit(1);
}

const stats = fs.statSync(MODEL_PATH);
const totalSize = stats.size;
console.log(`Target file: ${MODEL_PATH}`);
console.log(`Total size: ${totalSize} bytes (${(totalSize / (1024 * 1024)).toFixed(2)} MB)`);

// 20 MB part size (R2 requires min 5MB, max 5GB per part)
const PART_SIZE = 20 * 1024 * 1024;
const totalParts = Math.ceil(totalSize / PART_SIZE);
console.log(`Chunk size: ${PART_SIZE / (1024 * 1024)} MB across ${totalParts} parts`);

async function main() {
  // Step 1: Check if already uploaded
  console.log('\nChecking bucket status...');
  const statusRes = await fetch(`${WORKER_URL}/status?key=${encodeURIComponent(KEY)}`, {
    headers: { 'x-upload-secret': SECRET },
  });
  const statusData = await statusRes.json();
  if (statusData.exists && statusData.size === totalSize) {
    console.log(`Model is ALREADY fully uploaded to R2! Size: ${statusData.size} bytes.`);
    process.exit(0);
  }

  // Step 2: Create multipart upload
  console.log('\nInitiating multipart upload on Cloudflare R2...');
  const createRes = await fetch(`${WORKER_URL}/multipart/create?key=${encodeURIComponent(KEY)}`, {
    method: 'POST',
    headers: { 'x-upload-secret': SECRET },
  });
  if (!createRes.ok) {
    const text = await createRes.text();
    throw new Error(`Failed to create multipart upload: ${createRes.status} ${text}`);
  }
  const { uploadId } = await createRes.json();
  console.log(`Multipart upload created. UploadId: ${uploadId}`);

  // Step 3: Upload each part
  const fileDescriptor = fs.openSync(MODEL_PATH, 'r');
  const uploadedParts = [];
  let bytesUploaded = 0;

  try {
    for (let partNumber = 1; partNumber <= totalParts; partNumber++) {
      const start = (partNumber - 1) * PART_SIZE;
      const length = Math.min(PART_SIZE, totalSize - start);
      const buffer = Buffer.alloc(length);
      fs.readSync(fileDescriptor, buffer, 0, length, start);

      const partUrl = `${WORKER_URL}/multipart/part?key=${encodeURIComponent(KEY)}&uploadId=${encodeURIComponent(uploadId)}&partNumber=${partNumber}`;
      
      let attempt = 0;
      let success = false;
      let partResult = null;

      while (!success && attempt < 3) {
        attempt++;
        try {
          const partRes = await fetch(partUrl, {
            method: 'PUT',
            headers: {
              'x-upload-secret': SECRET,
              'Content-Type': 'application/octet-stream',
            },
            body: buffer,
          });

          if (!partRes.ok) {
            const errText = await partRes.text();
            throw new Error(`HTTP ${partRes.status}: ${errText}`);
          }

          partResult = await partRes.json();
          success = true;
        } catch (err) {
          console.warn(`Part ${partNumber} attempt ${attempt} failed: ${err.message}. Retrying in 2s...`);
          if (attempt >= 3) throw err;
          await new Promise((r) => setTimeout(r, 2000));
        }
      }

      bytesUploaded += length;
      const pct = ((bytesUploaded / totalSize) * 100).toFixed(1);
      console.log(`[${pct}%] Part ${partNumber}/${totalParts} uploaded successfully. ETag: ${partResult.etag}`);
      uploadedParts.push(partResult);
    }
  } catch (err) {
    console.error(`\nUpload failed: ${err.message}. Aborting multipart upload...`);
    await fetch(`${WORKER_URL}/multipart/abort?key=${encodeURIComponent(KEY)}&uploadId=${encodeURIComponent(uploadId)}`, {
      method: 'POST',
      headers: { 'x-upload-secret': SECRET },
    });
    fs.closeSync(fileDescriptor);
    process.exit(1);
  }

  fs.closeSync(fileDescriptor);

  // Step 4: Complete multipart upload
  console.log('\nAll chunks uploaded. Finalizing multipart assembly on Cloudflare R2...');
  const completeRes = await fetch(
    `${WORKER_URL}/multipart/complete?key=${encodeURIComponent(KEY)}&uploadId=${encodeURIComponent(uploadId)}`,
    {
      method: 'POST',
      headers: {
        'x-upload-secret': SECRET,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(uploadedParts),
    }
  );

  if (!completeRes.ok) {
    const errText = await completeRes.text();
    throw new Error(`Failed to complete multipart upload: ${completeRes.status} ${errText}`);
  }

  const completeData = await completeRes.json();
  console.log('\n SUCCESS! File is completely assembled in Cloudflare R2:');
  console.log(JSON.stringify(completeData, null, 2));

  // Step 5: Final head check
  const finalCheck = await fetch(`${WORKER_URL}/status?key=${encodeURIComponent(KEY)}`, {
    headers: { 'x-upload-secret': SECRET },
  });
  console.log('\nFinal R2 Bucket Object Status:', await finalCheck.json());
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
