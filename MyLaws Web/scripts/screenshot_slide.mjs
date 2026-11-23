import { execFile } from 'child_process';
import path from 'path';

const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const htmlPath = path.resolve('scratch/pitch_deck.html');
const shotPath = path.resolve('scratch/slide1_preview.png');

const args = [
  '--headless',
  '--disable-gpu',
  '--window-size=1920,1080',
  '--screenshot=' + shotPath,
  'file:///' + htmlPath.replace(/\\/g, '/')
];

execFile(chrome, args, (err) => {
  if (err) console.error(err);
  else console.log('Slide 1 screenshot created!');
});
