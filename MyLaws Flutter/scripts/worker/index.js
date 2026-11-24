const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, HEAD, POST, PUT, OPTIONS",
  "Access-Control-Allow-Headers": "*",
  "Access-Control-Expose-Headers": "Content-Range, Content-Length, Accept-Ranges, ETag",
};

function parseRange(rangeHeader) {
  if (!rangeHeader) return undefined;
  const match = rangeHeader.match(/bytes=(\d+)-(\d*)/);
  if (!match) return undefined;
  const offset = parseInt(match[1], 10);
  if (match[2]) {
    const end = parseInt(match[2], 10);
    return { offset, length: end - offset + 1 };
  }
  return { offset };
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    const key = url.searchParams.get("key") || "Qwen2.5-0.5B-Instruct-Q4_K_M.gguf";
    const uploadId = url.searchParams.get("uploadId");
    const partNumber = parseInt(url.searchParams.get("partNumber") || "0", 10);

    // Public high-speed CORS download endpoint for Flutter Web & Mobile apps
    if (url.pathname === "/download" || url.pathname.startsWith("/download/")) {
      const targetKey = url.searchParams.get("key") || url.pathname.replace(/^\/download\/?/, "") || key;

      try {
        if (request.method === "HEAD") {
          const head = await env.BUCKET.head(targetKey);
          if (!head) {
            return new Response(null, { status: 404, headers: CORS_HEADERS });
          }
          const headers = new Headers();
          head.writeHttpMetadata(headers);
          for (const [k, v] of Object.entries(CORS_HEADERS)) {
            headers.set(k, v);
          }
          headers.set("Accept-Ranges", "bytes");
          headers.set("ETag", head.httpEtag);
          headers.set("Content-Type", "application/octet-stream");
          headers.set("Content-Length", head.size.toString());
          return new Response(null, { headers, status: 200 });
        }

        const rangeHeader = request.headers.get("range");
        const parsedRange = parseRange(rangeHeader);

        const object = await env.BUCKET.get(targetKey, {
          range: parsedRange,
          onlyIf: request.headers,
        });

        if (!object) {
          return new Response("Not found in R2", { status: 404, headers: CORS_HEADERS });
        }

        const headers = new Headers();
        object.writeHttpMetadata(headers);
        for (const [k, v] of Object.entries(CORS_HEADERS)) {
          headers.set(k, v);
        }
        headers.set("Accept-Ranges", "bytes");
        headers.set("ETag", object.httpEtag);
        headers.set("Content-Type", "application/octet-stream");

        if (parsedRange && object.range) {
          const endOffset = object.range.offset + (object.range.length ? object.range.length - 1 : 0);
          headers.set("Content-Range", `bytes ${object.range.offset}-${endOffset}/${object.size}`);
        }

        const status = object.body ? (parsedRange ? 206 : 200) : 304;
        return new Response(object.body, { headers, status });
      } catch (err) {
        return new Response(err.message, { status: 500, headers: CORS_HEADERS });
      }
    }

    // Security check: optional secret header for administrative upload methods
    const authHeader = request.headers.get("x-upload-secret");
    if (env.UPLOAD_SECRET && authHeader !== env.UPLOAD_SECRET) {
      return new Response("Unauthorized", { status: 401, headers: CORS_HEADERS });
    }

    try {
      if (url.pathname === "/status") {
        const head = await env.BUCKET.head(key);
        if (!head) {
          return Response.json({ exists: false }, { headers: CORS_HEADERS });
        }
        return Response.json({
          exists: true,
          key: head.key,
          size: head.size,
          etag: head.etag,
          uploaded: head.uploaded,
        }, { headers: CORS_HEADERS });
      }

      if (url.pathname === "/multipart/create" && request.method === "POST") {
        const upload = await env.BUCKET.createMultipartUpload(key);
        return Response.json({ uploadId: upload.uploadId, key: upload.key }, { headers: CORS_HEADERS });
      }

      if (url.pathname === "/multipart/part" && request.method === "PUT") {
        if (!uploadId || !partNumber) {
          return new Response("Missing uploadId or partNumber", { status: 400, headers: CORS_HEADERS });
        }
        const upload = env.BUCKET.resumeMultipartUpload(key, uploadId);
        const part = await upload.uploadPart(partNumber, request.body);
        return Response.json(part, { headers: CORS_HEADERS });
      }

      if (url.pathname === "/multipart/complete" && request.method === "POST") {
        if (!uploadId) {
          return new Response("Missing uploadId", { status: 400, headers: CORS_HEADERS });
        }
        const parts = await request.json();
        const upload = env.BUCKET.resumeMultipartUpload(key, uploadId);
        const obj = await upload.complete(parts);
        return Response.json({
          success: true,
          key: obj.key,
          size: obj.size,
          etag: obj.etag,
          httpEtag: obj.httpEtag,
        }, { headers: CORS_HEADERS });
      }

      if (url.pathname === "/multipart/abort" && request.method === "POST") {
        if (!uploadId) {
          return new Response("Missing uploadId", { status: 400, headers: CORS_HEADERS });
        }
        const upload = env.BUCKET.resumeMultipartUpload(key, uploadId);
        await upload.abort();
        return Response.json({ aborted: true }, { headers: CORS_HEADERS });
      }

      return new Response("Not found", { status: 404, headers: CORS_HEADERS });
    } catch (err) {
      return Response.json({ error: err.message, stack: err.stack }, { status: 500, headers: CORS_HEADERS });
    }
  },
};
