import { test } from "node:test";
import assert from "node:assert/strict";
import { Mesh } from "../src/mesh.js";
import { exportGLB, exportGLTF, buildGLTF } from "../src/gltf.js";
const mesh = () =>
  new Mesh(
    [
      [0, 0, 0],
      [100, 0, 0],
      [0, 0, 100],
      [0, 100, 0],
    ],
    [
      [0, 1, 2],
      [0, 3, 1],
    ],
    [
      [128, 0, 255],
      [0, 255, 0],
    ],
  );
test("glTF preserves distinct face colours, orientation and scale without editing source", () => {
  const m = mesh(),
    before = JSON.stringify(m),
    { json, binary } = buildGLTF(m);
  assert.equal(JSON.stringify(m), before);
  assert.deepEqual(json.accessors[0].max.map(x => x || 0), [
    Math.fround(0.1),
    Math.fround(0.1),
    0,
  ]);
  const view = new DataView(binary),
    colors = json.bufferViews[2].byteOffset;
  assert.ok(Math.abs(view.getFloat32(colors, true) - 0.21586) < 0.00001);
  for (let i = 0; i < 3; i++)
    assert.equal(
      view.getFloat32(colors + i * 12, true),
      view.getFloat32(colors, true),
    );
  assert.equal(view.getFloat32(colors + 3 * 12 + 4, true), 1);
  assert.equal(json.accessors[0].count, 6);
  assert.equal(buildGLTF(m, { unit: "m" }).json.accessors[0].max[0], 100);
  assert.throws(() => buildGLTF(m, { unit: "unknown" }));
});
test("GLB has correct header, alignment and shared binary data with embedded glTF", () => {
  const m = mesh(),
    glb = exportGLB(m),
    v = new DataView(glb),
    jsonLength = v.getUint32(12, true);
  assert.equal(v.getUint32(0, true), 0x46546c67);
  assert.equal(v.getUint32(4, true), 2);
  assert.equal(v.getUint32(8, true), glb.byteLength);
  assert.equal(jsonLength % 4, 0);
  const j = JSON.parse(
    new TextDecoder().decode(new Uint8Array(glb, 20, jsonLength)),
  );
  assert.equal(j.asset.version, "2.0");
  assert.equal(j.buffers[0].uri, undefined);
  const g = JSON.parse(exportGLTF(m)),
    data = Buffer.from(g.buffers[0].uri.split(",")[1], "base64");
  assert.deepEqual(data, Buffer.from(glb, 28 + jsonLength));
});
