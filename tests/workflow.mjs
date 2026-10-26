import { createRequire } from "node:module";
import assert from "node:assert/strict";
import { mkdir } from "node:fs/promises";
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || "playwright");
await mkdir(new URL("../test-results/", import.meta.url), { recursive: true });
(async () => {
  const browser = await chromium.launch({
    executablePath:
      process.env.CHROME_PATH ||
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    headless: true,
    args: [
      "--enable-webgl",
      "--ignore-gpu-blocklist",
      "--use-angle=swiftshader",
      "--enable-unsafe-swiftshader",
    ],
  });
  const page = await browser.newPage({
      viewport: { width: 1400, height: 1000 },
    }),
    errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  const ready = () => page.waitForFunction(() => window.digitalNatives?.ready);
  const mesh = () =>
    page.evaluate(() => JSON.parse(JSON.stringify(window.digitalNatives.mesh)));
  await page.goto("http://localhost:8080");
  await ready();
  assert.equal(
    await page.evaluate(() => window.digitalNatives.state.tool),
    "coformer",
  );
  assert.equal(
    await page.locator("nav a").first().getAttribute("id"),
    "coformer-tab",
  );
  assert.match(await page.locator("#S1-label").innerText(), /Wave amplitude/);
  await page.selectOption("#operation", "perlin");
  assert.match(await page.locator("#S2-label").innerText(), /Noise frequency/);
  await page.locator("#S1-value").fill("60");
  await page.locator("#S2-value").fill("30");
  await page.locator("#apply").click();
  let formMesh = await mesh();
  await page.locator("#continue-colouring").click();
  await page.waitForURL("**/?tool=ccc");
  await ready();
  assert.deepEqual(await mesh(), formMesh);
  assert.match(await page.locator("#P1-label").innerText(), /Red rise/);
  await page.selectOption("#algorithm", "13");
  assert.match(await page.locator("#P1-label").innerText(), /Red 1/);
  await page.selectOption("#algorithm", "11");
  assert.match(await page.locator("#P1-label").innerText(), /Hue base/);
  assert(await page.locator("#P8").isDisabled());
  await page.selectOption("#algorithm", "35");
  assert.match(await page.locator("#P5-label").innerText(), /Brightness 2/);
  assert(await page.locator("#P6").isDisabled());
  await page.locator("#P1-value").fill("170");
  await page.locator("#P1-value").dispatchEvent("change");
  let colourMesh = await mesh();
  await page.screenshot({
    path: new URL("../test-results/context-labels.png", import.meta.url)
      .pathname,
  });
  await page.locator("#coformer-tab").click();
  await page.waitForURL("**/?tool=coformer");
  await ready();
  assert.deepEqual(await mesh(), formMesh);
  await page.screenshot({
    path: new URL("../test-results/form-labels.png", import.meta.url).pathname,
  });
  await page.locator("#ccc-tab").click();
  await page.waitForURL("**/?tool=ccc");
  await ready();
  assert.deepEqual(await mesh(), colourMesh);
  assert.equal(await page.locator("#algorithm").inputValue(), "35");
  assert.equal(await page.locator("#P1-value").inputValue(), "170");
  assert.deepEqual(errors, []);
  console.log(
    "PASS: default stage/order, dynamic RGB/HSB/form labels, unused controls, exact mesh+colour handoff, independent stage restoration and parameters; no browser errors.",
  );
  await browser.close();
})();
