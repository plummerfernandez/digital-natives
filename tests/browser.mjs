import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { mkdir, readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseSTL } from "../src/mesh.js";
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), ".."),
  out = path.join(root, "test-results");
await mkdir(out, { recursive: true });
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
    acceptDownloads: true,
  }),
  errors = [];
page.on("pageerror", (e) => errors.push(e.message));
const go = async (tool) => {
  await page.goto(`http://localhost:${process.env.PORT || 8080}/?tool=${tool}`);
  await page.waitForFunction(() => window.digitalNatives?.ready);
};
const mesh = () =>
  page.evaluate(() => JSON.parse(JSON.stringify(window.digitalNatives.mesh)));
const number = async (id, value) => {
  await page.locator("#" + id + "-value").fill(String(value));
  await page.locator("#" + id + "-value").dispatchEvent("change");
};
const download = async (id, file) => {
  const pending = page.waitForEvent("download");
  await page.locator("#" + id).click();
  const d = await pending;
  await d.saveAs(path.join(out, file));
  return readFile(path.join(out, file));
};
try {
  await go("ccc");
  const initial = await mesh();
  assert.equal(initial.faces.length, 675);
  await page.screenshot({ path: path.join(out, "ccc.png") });
  for (let i = 0; i <= 35; i++) {
    await page.selectOption("#algorithm", String(i));
    const m = await mesh();
    assert.ok(
      m.colors.every(
        (c) =>
          c.length === 3 &&
          c.every((x) => Number.isFinite(x) && x >= 0 && x <= 255),
      ),
    );
  }
  await number("P1", 180);
  await number("P7", 20);
  await page.locator("#reroll").click();
  const saved = await mesh(),
    session = await download("project", "session.json");
  assert.equal(JSON.parse(session).mesh.faces.length, saved.faces.length);
  await number("P1", 15);
  await page.setInputFiles("#session-file", path.join(out, "session.json"));
  await page.waitForFunction(
    () => document.getElementById("status").textContent === "Session restored",
  );
  assert.deepEqual(await mesh(), saved);
  const stl = await download("stl", "mesh.stl"),
    roundtrip = parseSTL(
      stl.buffer.slice(stl.byteOffset, stl.byteOffset + stl.byteLength),
    );
  assert.equal(roundtrip.faces.length, saved.faces.length);
  assert.match(
    (await download("vrml", "mesh.wrl")).toString(),
    /colorPerVertex FALSE/,
  );
  assert.match((await download("obj", "mesh.obj")).toString(), /^v /m);
  const png = await download("png", "image.png");
  assert.equal(png.subarray(1, 4).toString(), "PNG");
  await download("parameters", "notes.txt");
  await number("P1", 30);
  await page.setInputFiles("#session-file", path.join(out, "notes.txt"));
  await page.waitForFunction(
    () =>
      document.getElementById("status").textContent ===
      "Original ccc parameters restored",
  );
  assert.equal(await page.inputValue("#P1-value"), "180");
  // Uploaded geometry is parsed by the real file input, not a test-only entry point.
  await page.setInputFiles("#file", {
    name: "tetrahedron.obj",
    mimeType: "text/plain",
    buffer: Buffer.from(
      "v 0 0 0\nv 1 0 0\nv 0 1 0\nv 0 0 1\nf 1 3 2\nf 1 2 4\nf 2 3 4\nf 3 1 4",
    ),
  });
  await page.waitForFunction(
    () => window.digitalNatives.mesh.faces.length === 4,
  );
  await go("coformer");
  await number("S1", 75);
  await number("S2", 40);
  const before = await mesh();
  await page.locator("#apply").click();
  const after = await mesh();
  assert.notDeepEqual(before.vertices, after.vertices);
  await page.locator("#undo").click();
  assert.deepEqual(await mesh(), before);
  await page.locator("#redo").click();
  assert.deepEqual(await mesh(), after);
  await number("Z1", 75);
  await number("Z2", 20);
  await page
    .getByRole("button", { name: "Select Z region", exact: true })
    .click();
  assert.match(
    await page.locator("#selection-info").innerText(),
    /vertices selected/,
  );
  await page.screenshot({ path: path.join(out, "coformer.png") });
  const ops = await page
    .locator("#operation option")
    .evaluateAll((es) => es.map((e) => e.value));
  for (const op of ops) {
    await page.locator("#reset").click();
    await page.selectOption("#operation", op);
    await page.locator("#apply").click();
    assert.match(await page.locator("#status").innerText(), /^Applied /, op);
  }
  for (const label of [
    "Twist",
    "Sine twist",
    "Smooth",
    "Planar subdivision",
    "Catmull–Clark",
    "Fractal subdivision",
    "Cup",
    "Bell base",
    "Trumpet",
  ]) {
    await page.locator("#reset").click();
    await page.getByRole("button", { name: label, exact: true }).click();
    assert.match(await page.locator("#status").innerText(), /^Applied /, label);
  }
  await page.selectOption("#sample", "box.stl");
  await page.locator("#load-sample").click();
  await page.waitForFunction(
    () => document.getElementById("model-name").textContent === "box.stl",
  );
  await page.setViewportSize({ width: 390, height: 844 });
  await page.screenshot({ path: path.join(out, "mobile.png"), fullPage: true });
  assert.equal(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= innerWidth,
    ),
    true,
  );
  assert.deepEqual(errors, []);
  console.log(
    "PASS: browser rendering, 36 colour modes, all exposed transformations, undo/redo, session round-trip, original notes, uploads, STL/VRML/OBJ/PNG downloads, mobile layout; no JavaScript errors.",
  );
} finally {
  await browser.close();
}
