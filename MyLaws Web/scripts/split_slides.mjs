import { execFile } from 'child_process';
import path from 'path';
import fs from 'fs';

// Let's create individual slide HTML files to screenshot each one easily
const fullHtml = fs.readFileSync('scratch/pitch_deck.html', 'utf-8');
const slides = fullHtml.split(/<!-- SLIDE \d+:/);

// slides[0] is the header part up to <body>
const htmlHead = slides[0].substring(0, slides[0].indexOf('<body>') + 6);
const htmlTail = '</body></html>';

for (let i = 1; i < slides.length; i++) {
  const slideContent = '<!-- SLIDE ' + slides[i].substring(0, slides[i].lastIndexOf('</div>\n</div>') + 14);
  const singleSlideHtml = `${htmlHead}\n${slideContent}\n${htmlTail}`;
  fs.writeFileSync(`scratch/slide_${i}.html`, singleSlideHtml, 'utf-8');
}
console.log('Created individual slide HTMLs 1 to', slides.length - 1);
