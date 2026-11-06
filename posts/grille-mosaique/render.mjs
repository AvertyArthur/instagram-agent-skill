import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' }).catch(()=>chromium.launch());
const p = await b.newPage({ viewport: { width: 3240, height: 4320 } });
await p.goto('file://' + process.cwd() + '/mosaique.html');
await (await p.$('#m')).screenshot({ path: 'mosaique-complete.png' });
await b.close();
