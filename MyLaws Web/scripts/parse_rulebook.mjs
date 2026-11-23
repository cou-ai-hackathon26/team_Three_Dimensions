import fs from 'fs';
import zlib from 'zlib';

const buf = fs.readFileSync('scratch/rulebook.pdf');
const str = buf.toString('latin1');

const streamRegex = /<<([\s\S]*?)>>\s*stream[\r\n]+([\s\S]*?)[\r\n]+endstream/g;
let match;
let allText = '';

while ((match = streamRegex.exec(str)) !== null) {
  const dict = match[1];
  const streamData = match[2];
  if (dict.includes('/FlateDecode')) {
    try {
      const raw = Buffer.from(streamData, 'latin1');
      const decompressed = zlib.inflateSync(raw).toString('latin1');
      
      // Look for text in decompressed content
      // Tj, TJ, or raw strings
      const lines = decompressed.split(/[\r\n]+/);
      for (const line of lines) {
        if (line.endsWith('Tj') || line.endsWith('TJ') || line.includes('(') || line.includes('[')) {
          // extract anything in parentheses
          const parens = line.match(/\(([^)]*)\)/g);
          if (parens) {
            allText += parens.map(p => p.slice(1, -1)).join('') + ' ';
          }
        }
      }
      allText += '\n--- OBJECT STREAM ---\n';
    } catch (e) {
      // not flate or corrupted
    }
  }
}

fs.writeFileSync('scratch/rulebook_full.txt', allText);
console.log('Saved rulebook_full.txt! Length:', allText.length);
console.log(allText.substring(0, 3000));
