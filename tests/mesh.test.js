import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import {
  Mesh,
  parseSTL,
  parseOBJ,
  exportSTL,
  exportOBJ,
  exportVRML,
} from "../src/mesh.js";
import { operate, OPERATIONS } from "../src/operations.js";
import { createColorAlgorithm, COLOR_NAMES } from "../src/colors.js";
const fixture = () => {
  const b = readFileSync(new URL("../assets/vase.stl", import.meta.url));
  return parseSTL(b.buffer.slice(b.byteOffset, b.byteOffset + b.byteLength));
};
const cube = () =>
  parseOBJ(
    "v -1 -1 0\nv 1 -1 0\nv 1 1 0\nv -1 1 0\nv -1 -1 2\nv 1 -1 2\nv 1 1 2\nv -1 1 2\nf 4 3 2 1\nf 5 6 7 8\nf 1 2 6 5\nf 2 3 7 6\nf 3 4 8 7\nf 4 1 5 8",
  );
test("original STL loads with valid indices and finite geometry", () => {
  const m = fixture();
  assert.ok(m.faces.length > 100);
  m.validate();
  console.log(
    "Original vase:",
    m.vertices.length,
    "vertices,",
    m.faces.length,
    "faces",
  );
});
test("colour STL round-trip preserves coordinates, normals orientation, and 5-bit colours", () => {
  const a = cube();
  a.colors = a.colors.map(() => [255, 0, 123]);
  const b = parseSTL(exportSTL(a));
  assert.equal(b.faces.length, a.faces.length);
  assert.deepEqual(b.bounds().size, a.bounds().size);
  assert.deepEqual(b.colors[0], [255, 0, 123]);
  assert.deepEqual(b.normal(0), a.normal(0));
});
test("ASCII STL and OBJ import, OBJ export", () => {
  let m = parseSTL(
    new TextEncoder().encode(
      "solid a\nfacet normal 0 0 1\nouter loop\nvertex 0 0 0\nvertex 1 0 0\nvertex 0 1 0\nendloop\nendfacet\nendsolid",
    ).buffer,
  );
  assert.equal(m.area(0), 0.5);
  assert.deepEqual(parseOBJ(exportOBJ(m)).vertices, m.vertices);
  assert.throws(() => parseOBJ("v 0 0 0\nf 1 2 3"));
});
test("all 36 colour modes evaluate on original vase", () => {
  const m = fixture(),
    d = m.dimensions();
  for (const id of Object.keys(COLOR_NAMES)) {
    const fn = createColorAlgorithm(() => 0.5);
    for (
      let i = 0;
      i < m.faces.length;
      i += Math.max(1, Math.floor(m.faces.length / 100))
    ) {
      const c = fn(
        ...m.center(i),
        m.area(i),
        +id,
        [0, 240, 240, 110, 110, 85, 25, 10],
        d,
      );
      assert.equal(c.length, 3, "mode " + id);
      assert.ok(
        c.every((v) => Number.isFinite(v) && v >= 0 && v <= 255),
        "mode " + id,
      );
    }
  }
});
test("classic gradient matches original formula at base/middle/top", () => {
  const f = createColorAlgorithm(() => 0.5);
  const d = {
    objectHeight: 100,
    objectWidth: 50,
    objectDepth: 50,
    fAmax: 1,
    fAmin: 1,
  };
  assert.deepEqual(
    f(0, 0, 0, 1, 2, [0, 240, 240, 110, 110, 85, 0, 0], d),
    [110, 110, 85],
  );
  assert.deepEqual(
    f(0, 0, 50, 1, 2, [0, 240, 240, 110, 110, 85, 0, 0], d),
    [110, 230, 205],
  );
  assert.deepEqual(
    f(0, 0, 100, 1, 2, [0, 240, 240, 110, 110, 85, 0, 0], d),
    [110, 255, 255],
  );
});
test("wave follows source equation and does not mutate its input", () => {
  const a = fixture(),
    before = a.clone(),
    b = operate(a, "wave", { S1: 80 });
  assert.deepEqual(a.vertices, before.vertices);
  const h = a.bounds().objectHeight;
  for (let i = 0; i < a.vertices.length; i++) {
    assert.ok(
      Math.abs(
        b.vertices[i][0] -
          a.vertices[i][0] -
          Math.sin((a.vertices[i][2] / h) * Math.PI * 10) * 0.8,
      ) < 1e-9,
    );
  }
});
test("crop creates plane intersections and preserves half-space", () => {
  const a = cube(),
    b = a.clip(2, 1, true);
  assert.equal(b.bounds().min[2], 1);
  assert.equal(b.bounds().max[2], 2);
  assert.ok(b.topology().boundary.length > 0);
  b.validate();
});
test("mirror has symmetric bounds and welded seam", () => {
  let m = operate(cube(), "mirror");
  assert.equal(m.bounds().min[0], -m.bounds().max[0]);
  assert.equal(m.topology().boundary.length, 0);
});
test("subdivision preserves planar surface; Catmull-Clark remains manifold", () => {
  let a = cube(),
    b = a.subdivide();
  assert.equal(b.faces.length, a.faces.length * 4);
  assert.deepEqual(b.bounds().size, a.bounds().size);
  assert.equal(b.topology().boundary.length, 0);
  let c = a.subdivide(true);
  c.validate();
  assert.equal(c.topology().boundary.length, 0);
});
test("active geometry operations produce finite results on original vase", () => {
  for (const name of [
    ...Object.keys(OPERATIONS),
    "twist",
    "sineTwist",
    "smooth",
    "subdivide",
    "catmull",
    "fractal",
    "cup",
    "trumpet",
    "bellbase",
    "cropTop",
    "cropBase",
  ]) {
    let a = fixture();
    try {
      operate(
        a,
        name,
        { S1: 30, S2: 40, Z1: 70, Z2: 10 },
        () => 0.55,
        2012,
      ).validate();
    } catch (e) {
      assert.fail(name + ": " + e.message);
    }
  }
});
test("VRML carries all face colours without altering mesh", () => {
  let a = cube(),
    before = a.clone(),
    s = exportVRML(a);
  assert.match(s, /colorPerVertex FALSE/);
  assert.deepEqual(a, before);
});

test("selected deformation leaves unselected vertices unchanged", () => {
  const a = fixture(),
    h = a.bounds().objectHeight,
    ids = new Set();
  a.faces.forEach((f, i) => {
    const z = a.center(i)[2];
    if (z > 0.2 * h && z < 0.75 * h) f.forEach((j) => ids.add(j));
  });
  const b = operate(a, "wave", { S1: 80 }, () => 0.5, 2012, [20, 75]);
  for (let i = 0; i < a.vertices.length; i++)
    if (!ids.has(i)) assert.deepEqual(b.vertices[i], a.vertices[i]);
});
test("empty crops fail explicitly and leave source intact", () => {
  const a = cube(),
    before = a.clone();
  assert.throws(() => operate(a, "cropTop", { Z1: -10 }), /remove every face/);
  assert.deepEqual(a, before);
});
test("legacy integer division in cup2 is preserved", () => {
  const a = fixture(),
    h = a.bounds().objectHeight,
    b = operate(a, "cup2", { S1: 81, S2: 61 });
  for (let i = 0; i < a.vertices.length; i++) {
    const [x, y, z] = a.vertices[i],
      s = Math.sin(z / h + 61);
    assert.ok(Math.abs(b.vertices[i][0] - x * s) < 1e-9);
    assert.ok(Math.abs(b.vertices[i][1] - y * s) < 1e-9);
  }
});
