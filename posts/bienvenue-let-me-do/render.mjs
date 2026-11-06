import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' }).catch(()=>chromium.launch());
const p = await b.newPage({ viewport: { width: 8640, height: 1350 } });
await p.goto('file://' + process.cwd() + '/carrousel.html'); await p.waitForLoadState('networkidle');
await (await p.$('#c')).screenshot({ path: 'bande-complete.png' });
await b.close();
