import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' }).catch(()=>chromium.launch());
const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
await p.goto('file://' + process.cwd() + '/couverture.html');
await (await p.$('section')).screenshot({ path: 'couverture-reel-epingle.png' });
await b.close();
