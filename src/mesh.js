import { add, sub, mul, cross, length, unit, average, dot } from "./math.js";
export class Mesh {
  constructor(vertices = [], faces = [], colors = []) {
    this.vertices = vertices;
    this.faces = faces;
    this.colors = faces.map((_, i) =>
      colors[i] ? [...colors[i]] : [210, 210, 210],
    );
  }
  clone() {
    return new Mesh(
      this.vertices.map((v) => [...v]),
      this.faces.map((f) => [...f]),
      this.colors,
    );
  }
  bounds() {
    if (!this.vertices.length)
      throw Error("The mesh has no vertices. Undo to restore it.");
    const min = [Infinity, Infinity, Infinity],
      max = [-Infinity, -Infinity, -Infinity];
    for (const v of this.vertices)
      for (let i = 0; i < 3; i++) {
        min[i] = Math.min(min[i], v[i]);
        max[i] = Math.max(max[i], v[i]);
      }
    const size = sub(max, min);
    return {
      min,
      max,
      size,
      center: average([min, max]),
      objectWidth: size[0],
      objectDepth: size[1],
      objectHeight: size[2],
    };
  }
  center(i) {
    return average(this.faces[i].map((j) => this.vertices[j]));
  }
  normal(i) {
    const f = this.faces[i],
      a = this.vertices[f[0]];
    let n = [0, 0, 0];
    for (let j = 1; j < f.length - 1; j++)
      n = add(
        n,
        cross(sub(this.vertices[f[j]], a), sub(this.vertices[f[j + 1]], a)),
      );
    return unit(n);
  }
  area(i) {
    const f = this.faces[i],
      a = this.vertices[f[0]];
    let s = 0;
    for (let j = 1; j < f.length - 1; j++)
      s +=
        length(
          cross(sub(this.vertices[f[j]], a), sub(this.vertices[f[j + 1]], a)),
        ) / 2;
    return s;
  }
  dimensions() {
    let fAmax = 0,
      fAmin = Infinity;
    for (let i = 0; i < this.faces.length; i++) {
      let a = this.area(i);
      fAmax = Math.max(fAmax, a);
      fAmin = Math.min(fAmin, a);
    }
    return { ...this.bounds(), fAmax, fAmin };
  }
  ground() {
    let z = this.bounds().min[2];
    this.vertices.forEach((v) => (v[2] -= z));
    return this;
  }
  validate() {
    if (!this.faces.length)
      throw Error("This operation would remove every face.");
    if (this.faces.length > 200000)
      throw Error("Mesh exceeds the 200,000-face browser limit.");
    for (const v of this.vertices)
      if (v.length !== 3 || !v.every(Number.isFinite))
        throw Error("Operation produced invalid coordinates.");
    for (const f of this.faces)
      if (
        f.length < 3 ||
        f.some(
          (i) => !Number.isInteger(i) || i < 0 || i >= this.vertices.length,
        )
      )
        throw Error("Invalid face index.");
    return this;
  }
  triangles() {
    let out = [];
    this.faces.forEach((f, i) => {
      for (let j = 1; j < f.length - 1; j++)
        out.push({
          ids: [f[0], f[j], f[j + 1]],
          color: this.colors[i],
          face: i,
        });
    });
    return out;
  }
  topology() {
    const edges = new Map(),
      neighbors = this.faces.map(() => new Set()),
      vertexFaces = this.vertices.map(() => []),
      vertexNeighbors = this.vertices.map(() => new Set());
    this.faces.forEach((f, fi) => {
      f.forEach((a, j) => {
        const b = f[(j + 1) % f.length],
          key = a < b ? `${a},${b}` : `${b},${a}`;
        if (!edges.has(key)) edges.set(key, []);
        edges.get(key).push({ a, b, face: fi });
        vertexFaces[a].push(fi);
        vertexNeighbors[a].add(b);
        vertexNeighbors[b].add(a);
      });
    });
    for (const es of edges.values())
      for (const a of es)
        for (const b of es)
          if (a.face !== b.face) neighbors[a.face].add(b.face);
    return {
      edges,
      neighbors,
      vertexFaces,
      vertexNeighbors,
      boundary: [...edges.values()]
        .filter((e) => e.length === 1)
        .map((e) => e[0]),
    };
  }
  compact() {
    const ids = new Map(),
      v = [];
    this.faces = this.faces.map((f) =>
      f.map((i) => {
        if (!ids.has(i)) {
          ids.set(i, v.length);
          v.push(this.vertices[i]);
        }
        return ids.get(i);
      }),
    );
    this.vertices = v;
    return this;
  }
  weld(epsilon = 1e-7) {
    let ids = new Map(),
      v = [],
      remap = this.vertices.map((p) => {
        const key = p.map((x) => Math.round(x / epsilon)).join(",");
        if (!ids.has(key)) {
          ids.set(key, v.length);
          v.push(p);
        }
        return ids.get(key);
      });
    this.faces = this.faces.map((f) => f.map((i) => remap[i]));
    this.vertices = v;
    return this.compact();
  }
  append(other) {
    let n = this.vertices.length;
    this.vertices.push(...other.vertices.map((v) => [...v]));
    this.faces.push(...other.faces.map((f) => f.map((i) => i + n)));
    this.colors.push(...other.colors.map((c) => [...c]));
    return this;
  }
  removeFaces(ids) {
    this.colors = this.colors.filter((_, i) => !ids.has(i));
    this.faces = this.faces.filter((_, i) => !ids.has(i));
    return this.compact();
  }
  // Sutherland-Hodgman clipping; intentionally uncapped, matching the original crop tools.
  clip(axis, value, positive = true) {
    let v = [],
      f = [],
      c = [];
    const eps = 1e-8;
    this.faces.forEach((face, fi) => {
      let poly = face.map((i) => this.vertices[i]),
        out = [];
      for (let i = 0; i < poly.length; i++) {
        let a = poly[i],
          b = poly[(i + 1) % poly.length],
          da = (a[axis] - value) * (positive ? 1 : -1),
          db = (b[axis] - value) * (positive ? 1 : -1);
        if (da >= -eps) out.push([...a]);
        if ((da > eps && db < -eps) || (da < -eps && db > eps)) {
          let t = (value - a[axis]) / (b[axis] - a[axis]);
          out.push(a.map((x, k) => x + t * (b[k] - x)));
        }
      }
      out = out.filter((p, i) => !i || length(sub(p, out[i - 1])) > eps);
      if (out.length > 2) {
        f.push(
          out.map((p) => {
            v.push(p);
            return v.length - 1;
          }),
        );
        c.push(this.colors[fi]);
      }
    });
    return new Mesh(v, f, c).weld();
  }
  triangulate() {
    let t = this.triangles();
    return new Mesh(
      this.vertices.map((v) => [...v]),
      t.map((t) => t.ids),
      t.map((t) => t.color),
    );
  }
  subdivide(catmull = false) {
    if (this.faces.length * 6 > 200000)
      throw Error("Subdivision would exceed the browser mesh limit.");
    const { edges, vertexFaces, vertexNeighbors, boundary } = this.topology(),
      centers = this.faces.map((_, i) => this.center(i)),
      v = this.vertices.map((p) => [...p]),
      edgeIndex = new Map(),
      faceIndex = [];
    if (catmull) {
      const bNeighbors = new Map();
      for (const e of boundary) {
        for (const [a, b] of [
          [e.a, e.b],
          [e.b, e.a],
        ]) {
          if (!bNeighbors.has(a)) bNeighbors.set(a, []);
          bNeighbors.get(a).push(b);
        }
      }
      this.vertices.forEach((p, i) => {
        const bn = bNeighbors.get(i);
        if (bn?.length === 2)
          v[i] = add(
            mul(p, 0.75),
            mul(add(this.vertices[bn[0]], this.vertices[bn[1]]), 0.125),
          );
        else if (!bn) {
          const fs = vertexFaces[i],
            ns = [...vertexNeighbors[i]],
            n = fs.length;
          if (n) {
            const F = average(fs.map((j) => centers[j])),
              R = average(ns.map((j) => average([p, this.vertices[j]])));
            v[i] = mul(add(add(F, mul(R, 2)), mul(p, n - 3)), 1 / n);
          }
        }
      });
    }
    for (const [key, es] of edges) {
      const { a, b } = es[0];
      let point = average([this.vertices[a], this.vertices[b]]);
      if (catmull && es.length === 2)
        point = average([
          this.vertices[a],
          this.vertices[b],
          centers[es[0].face],
          centers[es[1].face],
        ]);
      edgeIndex.set(key, v.length);
      v.push(point);
    }
    centers.forEach((p) => {
      faceIndex.push(v.length);
      v.push(p);
    });
    let faces = [],
      colors = [];
    const ei = (a, b) => edgeIndex.get(a < b ? `${a},${b}` : `${b},${a}`);
    this.faces.forEach((f, fi) => {
      if (!catmull && f.length === 3) {
        let [a, b, c] = f,
          ab = ei(a, b),
          bc = ei(b, c),
          ca = ei(c, a);
        faces.push([a, ab, ca], [b, bc, ab], [c, ca, bc], [ab, bc, ca]);
        for (let i = 0; i < 4; i++) colors.push(this.colors[fi]);
      } else
        f.forEach((a, i) => {
          faces.push([
            a,
            ei(a, f[(i + 1) % f.length]),
            faceIndex[fi],
            ei(f[(i + f.length - 1) % f.length], a),
          ]);
          colors.push(this.colors[fi]);
        });
    });
    return new Mesh(v, faces, colors).compact().triangulate();
  }
}
export function parseSTL(buffer) {
  const view = new DataView(buffer),
    vertices = [],
    faces = [],
    colors = [],
    ids = new Map();
  const vertex = (p) => {
    if (!p.every(Number.isFinite))
      throw Error("STL contains non-finite coordinates.");
    let key = p.map((x) => Math.round(x * 1e7)).join(",");
    if (!ids.has(key)) {
      ids.set(key, vertices.length);
      vertices.push(p);
    }
    return ids.get(key);
  };
  let count = buffer.byteLength >= 84 ? view.getUint32(80, true) : 0;
  if (count > 0 && 84 + count * 50 <= buffer.byteLength) {
    if (count > 200000)
      throw Error("Please use a mesh with fewer than 200,000 triangles.");
    let header = new TextDecoder().decode(new Uint8Array(buffer, 0, 80)),
      materialise = header.includes("COLOR=");
    for (let i = 0; i < count; i++) {
      let off = 84 + i * 50 + 12;
      faces.push(
        [0, 1, 2].map((j) =>
          vertex(
            [0, 1, 2].map((k) => view.getFloat32(off + j * 12 + k * 4, true)),
          ),
        ),
      );
      let attr = view.getUint16(off + 36, true);
      colors.push(
        materialise && !(attr & 32768)
          ? [attr & 31, (attr >> 5) & 31, (attr >> 10) & 31].map((x) =>
              Math.round((x * 255) / 31),
            )
          : [210, 210, 210],
      );
    }
  } else {
    let text = new TextDecoder().decode(buffer),
      matches = [
        ...text.matchAll(
          /vertex\s+([\deE+.-]+)\s+([\deE+.-]+)\s+([\deE+.-]+)/gi,
        ),
      ];
    if (!matches.length || matches.length % 3)
      throw Error("Not a readable binary or ASCII STL.");
    if (matches.length / 3 > 200000) throw Error("Please use a smaller STL.");
    for (let i = 0; i < matches.length; i += 3)
      faces.push(
        matches.slice(i, i + 3).map((m) => vertex(m.slice(1).map(Number))),
      );
  }
  return new Mesh(vertices, faces, colors).validate();
}
export function parseOBJ(text) {
  const v = [],
    vc = [],
    f = [],
    colors = [];
  for (const line of text.split(/\r?\n/)) {
    const [type, ...args] = line.trim().split(/\s+/);
    if (type === "v") {
      v.push(args.slice(0, 3).map(Number));
      vc.push(args.length >= 6 ? args.slice(3, 6).map(Number) : null);
    }
    if (type === "f") {
      const face = args.map((s) => {
        const i = parseInt(s.split("/")[0], 10);
        return i < 0 ? v.length + i : i - 1;
      });
      if (face.some((i) => !v[i]))
        throw Error("OBJ contains invalid vertex references.");
      f.push(face);
      const cs = face.map((i) => vc[i]).filter(Boolean);
      colors.push(
        cs.length
          ? average(cs).map((x) => clampByte(x * 255))
          : [210, 210, 210],
      );
    }
  }
  return new Mesh(v, f, colors).validate().triangulate().validate();
}
const clampByte = (x) => Math.max(0, Math.min(255, Math.round(x)));
export function exportSTL(mesh) {
  mesh.validate();
  const ts = mesh.triangles(),
    buffer = new ArrayBuffer(84 + ts.length * 50),
    view = new DataView(buffer);
  new Uint8Array(buffer).set(
    new TextEncoder().encode("Digital Natives | COLOR="),
  );
  new Uint8Array(buffer, 24, 4).set([210, 210, 210, 255]);
  view.setUint32(80, ts.length, true);
  ts.forEach((t, i) => {
    let off = 84 + i * 50,
      n = mesh.normal(t.face);
    [n, ...t.ids.map((j) => mesh.vertices[j])]
      .flat()
      .forEach((x, k) => view.setFloat32(off + 4 * k, x, true));
    let c = t.color.map((x) => Math.round((x / 255) * 31));
    view.setUint16(off + 48, c[0] | (c[1] << 5) | (c[2] << 10), true);
  });
  return buffer;
}
export function exportOBJ(mesh) {
  return (
    "# Digital Natives\n" +
    mesh.vertices.map((v) => "v " + v.join(" ")).join("\n") +
    "\n" +
    mesh.faces.map((f) => "f " + f.map((i) => i + 1).join(" ")).join("\n") +
    "\n"
  );
}
export function exportVRML(mesh) {
  return (
    "#VRML V2.0 utf8\n# Digital Natives — Matthew Plummer-Fernandez\nShape { geometry IndexedFaceSet { solid FALSE\ncoord Coordinate { point [\n" +
    mesh.vertices.map((v) => v.join(" ")).join(",\n") +
    "\n] }\ncoordIndex [\n" +
    mesh.faces.map((f) => f.join(", ") + ", -1").join(",\n") +
    "\n]\ncolorPerVertex FALSE\ncolor Color { color [\n" +
    mesh.colors.map((c) => c.map((x) => x / 255).join(" ")).join(",\n") +
    "\n] }\n} }\n"
  );
}

// Region subdivision inserts edge points into adjacent untouched polygons too,
// so a partial selection never introduces T-junctions. Returns face ancestry.
export function subdivideRegion(mesh, selected, catmull = false) {
  if (mesh.faces.length + selected.size * 6 > 200000)
    throw Error("Subdivision would exceed the browser mesh limit.");
  const { edges, vertexFaces } = mesh.topology(),
    centers = mesh.faces.map((_, i) => mesh.center(i)),
    v = mesh.vertices.map((p) => [...p]),
    edgeIds = new Map(),
    faceIds = new Map(),
    regionBoundary = new Map();
  const key = (a, b) => (a < b ? `${a},${b}` : `${b},${a}`);
  for (const [k, es] of edges) {
    if (!es.some((e) => selected.has(e.face))) continue;
    const { a, b } = es[0],
      both = es.length === 2 && es.every((e) => selected.has(e.face));
    let p = average([mesh.vertices[a], mesh.vertices[b]]);
    if (catmull && both)
      p = average([
        mesh.vertices[a],
        mesh.vertices[b],
        centers[es[0].face],
        centers[es[1].face],
      ]);
    edgeIds.set(k, v.length);
    v.push(p);
    if (!both)
      for (const [i, j] of [
        [a, b],
        [b, a],
      ]) {
        if (!regionBoundary.has(i)) regionBoundary.set(i, new Set());
        regionBoundary.get(i).add(j);
      }
  }
  if (catmull) {
    const selectedVertices = new Set(
      [...selected].flatMap((i) => mesh.faces[i]),
    );
    for (const i of selectedVertices) {
      const ns = regionBoundary.get(i);
      if (ns?.size === 2) {
        v[i] = add(
          mul(mesh.vertices[i], 0.75),
          mul(
            [...ns].reduce((s, j) => add(s, mesh.vertices[j]), [0, 0, 0]),
            0.125,
          ),
        );
      } else if (!ns) {
        const fs = vertexFaces[i],
          neighbors = new Set();
        for (const fi of fs) {
          const f = mesh.faces[fi],
            at = f.indexOf(i);
          neighbors.add(f[(at + 1) % f.length]);
          neighbors.add(f[(at + f.length - 1) % f.length]);
        }
        const n = fs.length,
          F = average(fs.map((j) => centers[j])),
          R = average(
            [...neighbors].map((j) =>
              average([mesh.vertices[i], mesh.vertices[j]]),
            ),
          );
        v[i] = mul(add(add(F, mul(R, 2)), mul(mesh.vertices[i], n - 3)), 1 / n);
      }
    }
  }
  for (const fi of selected) {
    faceIds.set(fi, v.length);
    v.push(centers[fi]);
  }
  const faces = [],
    colors = [],
    parents = [];
  const emit = (f, fi) => {
    faces.push(f);
    colors.push(mesh.colors[fi]);
    parents.push(fi);
  };
  mesh.faces.forEach((f, fi) => {
    if (!selected.has(fi)) {
      const poly = [];
      f.forEach((a, j) => {
        poly.push(a);
        const mid = edgeIds.get(key(a, f[(j + 1) % f.length]));
        if (mid !== undefined) poly.push(mid);
      });
      emit(poly, fi);
      return;
    }
    const e = f.map((a, j) => edgeIds.get(key(a, f[(j + 1) % f.length])));
    if (!catmull && f.length === 3) {
      emit([f[0], e[0], e[2]], fi);
      emit([f[1], e[1], e[0]], fi);
      emit([f[2], e[2], e[1]], fi);
      emit(e, fi);
    } else
      f.forEach((a, j) =>
        emit([a, e[j], faceIds.get(fi), e[(j + f.length - 1) % f.length]], fi),
      );
  });
  return { mesh: new Mesh(v, faces, colors), parents };
}
