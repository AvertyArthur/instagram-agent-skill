import { chromium } from '/opt/node22/lib/node_modules/playwright/index.mjs';
const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' }).catch(()=>chromium.launch());
const p = await b.newPage({ viewport: { width: 1080, height: 1350 } });
await p.goto('file://' + process.cwd() + '/slides.html');
const s = await p.$$('section');
for (let i = 0; i < s.length; i++) await s[i].screenshot({ path: `slide-${i+1}.png` });
await b.close(); console.log(s.length, 'slides');
