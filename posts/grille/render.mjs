import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' }).catch(()=>chromium.launch());
const p = await b.newPage({ viewport: { width: 1080, height: 1920 } });
await p.goto('file://' + process.cwd() + '/covers.html'); await p.waitForLoadState('networkidle');
for (const s of await p.$$('section')) await s.screenshot({ path: (await s.getAttribute('data-name')) + '.png' });
await b.close();
