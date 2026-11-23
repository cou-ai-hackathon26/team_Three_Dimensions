import { execFile } from 'child_process';
import path from 'path';
import fs from 'fs';

const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const htmlPath = path.resolve('scratch/pitch_deck.html');
const pdfPath = path.resolve('MyLaws_CoU_AI_Hackathon_2026.pdf');

console.log('Generating PDF from:', htmlPath);
console.log('Output to:', pdfPath);

const args = [
  '--headless',
  '--disable-gpu',
  '--no-pdf-header-footer',
  '--run-all-compositor-stages-before-draw',
  '--virtual-time-budget=6000',
  '--print-to-pdf=' + pdfPath,
  'file:///' + htmlPath.replace(/\\/g, '/')
];

execFile(chrome, args, (err, stdout, stderr) => {
  if (err) {
    console.error('Error executing Chrome:', err);
    process.exit(1);
  }
  console.log('stdout:', stdout);
  console.log('stderr:', stderr);

  if (fs.existsSync(pdfPath)) {
    const stats = fs.statSync(pdfPath);
    console.log(`PDF created successfully! Size: ${stats.size} bytes (${(stats.size / 1024).toFixed(1)} KB)`);
  } else {
    console.error('PDF file was not created!');
    process.exit(1);
  }
});
