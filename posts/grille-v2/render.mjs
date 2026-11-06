import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' }).catch(()=>chromium.launch());
const p = await b.newPage({ viewport: { width: 2160, height: 2880 } });
await p.goto('file://' + process.cwd() + '/bloc.html');
await (await p.$('#b')).screenshot({ path: 'bloc-2x2.png' });
await b.close();
