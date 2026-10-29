const { chromium } = require('C:/Users/amirt/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '../flutter_app/build/web');
const out = path.join(__dirname, 'inventory-verification');

(async () => {
  fs.mkdirSync(out, { recursive: true });
  const login = await fetch('http://127.0.0.1:8007/api/auth/login', {
    method: 'POST', headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ email: process.env.PITCH_EMAIL, password: process.env.PITCH_PASSWORD }),
  });
  if (!login.ok) throw new Error('Local admin login failed');
  const { token } = await login.json();
  const headers = { Authorization: `Bearer ${token}`, Accept: 'application/json' };
  const students = await (await fetch('http://127.0.0.1:8007/api/students?for_inventory=true', { headers })).json();
  const student = students.data[0];
  if (!student) throw new Error('No local student available');
  const browser = await chromium.launch({ headless: true, executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
  try {
    const context = await browser.newContext({ viewport: { width: 393, height: 852 } });
    await context.addInitScript(({ token }) => {
      localStorage.setItem('flutter.schookeep_token', JSON.stringify(token));
      localStorage.setItem('flutter.schookeep_is_admin', 'true');
    }, { token });
    await context.route('**/*', async r => {
      const url = new URL(r.request().url());
      if (url.hostname === '127.0.0.1') return r.continue();
      if (url.hostname === 'www.gstatic.com' && url.pathname.includes('flutter-canvaskit')) {
        const relative = url.pathname.split('/').slice(3).join('/');
        return r.fulfill({ body: fs.readFileSync(path.join(root, 'canvaskit', relative)), contentType: relative.endsWith('.wasm') ? 'application/wasm' : 'application/javascript' });
      }
      if (url.hostname === 'fonts.gstatic.com') return r.fulfill({ body: fs.readFileSync('C:/Windows/Fonts/arial.ttf'), contentType: 'font/ttf' });
      return r.abort();
    });
    const failures = [];
    const fontWarnings = [];
    const sourceLines = fs.readFileSync(path.join(root, 'main.dart.js'), 'utf8').split('\n');
    for (const width of [393, 320, 1280]) {
      const page = await context.newPage();
      await page.setViewportSize({ width, height: width === 1280 ? 900 : 852 });
      page.on('pageerror', e => {
        const frames = [...e.stack.matchAll(/main\.dart\.js:(\d+):\d+/g)];
        // The offline harness substitutes Arial for unavailable fallback fonts.
        if (frames.some(m => sourceLines[Number(m[1]) - 1]?.includes('expected length and checksum'))) {
          fontWarnings.push(`${width}: offline fallback font checksum mismatch`);
        } else failures.push(`${width} ${page.url()} ${e.stack}`);
      });
      page.on('response', r => { if (r.url().includes('/api/') && r.status() >= 400) failures.push(`${r.status()} ${r.url()}`); });
      for (const [name, route] of [
        ['directory', '/nurse/medications/student-inventory'],
        ['student', `/nurse/students/${student.id}/inventory`],
        ['school', '/nurse/medications/inventory'],
      ]) {
        await page.goto(`http://127.0.0.1:5184/#${route}`);
        await page.waitForTimeout(10000);
        await page.waitForLoadState('networkidle', { timeout: 20000 }).catch(() => {});
        await page.screenshot({ path: path.join(out, `${name}-${width}.png`) });
        const left = width > 393 ? (width - 393) / 2 : 0;
        if (name === 'directory') {
          await page.mouse.click(left + 120, 245);
          await page.waitForTimeout(2000);
          if (!page.url().endsWith(`/nurse/students/${student.id}/inventory`)) throw new Error('Student inventory link did not open');
        }
        if (name === 'student') {
          await page.mouse.click(left + Math.min(width, 393) - 36, 72);
          await page.waitForTimeout(600);
          await page.screenshot({ path: path.join(out, `add-medicine-${width}.png`) });
          await page.keyboard.press('Escape');
        }
        if (name === 'school') {
          await page.mouse.click(left + 240, 128);
          await page.waitForTimeout(2000);
          if (!page.url().endsWith('/nurse/medications/student-inventory')) throw new Error('Student stock switch did not open');
        }
      }
      await page.close();
    }
    const report = { student: student.name, failures, fontWarnings, screenshots: out };
    fs.writeFileSync(path.join(out, 'verification.json'), JSON.stringify(report, null, 2));
    console.log(JSON.stringify(report));
    if (failures.length) process.exitCode = 1;
  } finally {
    await browser.close();
    await fetch('http://127.0.0.1:8007/api/auth/logout', { method: 'POST', headers });
  }
})().catch(e => { console.error(e.message); process.exitCode = 1; });
