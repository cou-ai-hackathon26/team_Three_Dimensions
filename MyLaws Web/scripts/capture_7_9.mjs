import { execFile } from 'child_process';
import path from 'path';

const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

async function capture(i) {
  return new Promise((resolve) => {
    const htmlPath = path.resolve(`scratch/slide_${i}.html`);
    const shotPath = path.resolve(`scratch/slide_${i}.png`);
    execFile(chrome, [
      '--headless',
      '--disable-gpu',
      '--window-size=1920,1080',
      '--virtual-time-budget=2000',
      '--screenshot=' + shotPath,
      'file:///' + htmlPath.replace(/\\/g, '/')
    ], () => {
      resolve();
    });
  });
}

for (let i = 7; i <= 9; i++) {
  await capture(i);
  console.log(`Captured slide ${i}`);
}
