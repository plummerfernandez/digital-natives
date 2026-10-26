import { Mesh, subdivideRegion } from "./mesh.js";
import {
  add,
  sub,
  mul,
  average,
  rotate,
  map,
  seededRandom,
  hsvToRGB,
  rgbToHSV,
} from "./math.js";
// Shared with the viewport so the displayed axis matches the actual rotation.
export function twistAxis(S1 = 0, S2 = 0) {
  const origin = [Math.trunc(S2 / 4), 0, 0];
  return { origin, direction: [Math.trunc(S1 / 2) - origin[0], 0, 200] };
}

export const OPERATIONS = {
  wave: "Wave",
  cavity: "Cavity",
  wideBase: "Wide base",
  patch: "Natives patch",
  cup2: "Cup 2",
  scaleZExpo: "Scale Z exponentially",
  toastie: "Toastie stretch",
  flip: "Flip (legacy 180 radians)",
  mirror: "Mirror",
  quattro: "Quattro",
  fatslab: "Fat slab",
  printerSlip: "Printer head slip",
  scaleSelection: "Scale selection",
  spikes: "Spikes",
  perlin: "Perlin",
  perlinForward2: "Perlin forward 2",
};
export function selectedVertices(mesh, range = null) {
  if (!range) return new Set(mesh.vertices.map((_, i) => i));
  const h = mesh.bounds().objectHeight,
    ids = new Set();
  mesh.faces.forEach((f, i) => {
    const z = mesh.center(i)[2];
    if (z > (range[0] * h) / 100 && z < (range[1] * h) / 100)
      f.forEach((j) => ids.add(j));
  });
  return ids;
}
export function operate(
  mesh,
  name,
  p = {},
  noise = () => 0.5,
  seed = 2012,
  range = null,
) {
  let m = mesh.clone();
  const { objectHeight: h, objectWidth: w } = m.bounds(),
    S1 = p.S1 ?? 0,
    S2 = p.S2 ?? 0,
    Z1 = p.Z1 ?? 100,
    Z2 = p.Z2 ?? 0,
    rev = p.reversal ?? 1,
    selected = selectedVertices(m, range),
    random = seededRandom(seed);
  const each = (fn) => {
    for (const i of selected) m.vertices[i] = fn([...m.vertices[i]], i);
  };
  const height = h || 1;
  switch (name) {
    case "wave":
      each(([x, y, z]) => [
        x + (Math.sin((z / height) * Math.PI * 10) * S1) / 100,
        y,
        z,
      ]);
      break;
    case "wideBase":
      m.vertices = m.vertices.map(([x, y, z]) =>
        z <= h / 10
          ? [x * (2 - z / (height * 0.1)), y * (2 - z / (height * 0.1)), z]
          : [x, y, z],
      );
      break;
    case "cup2":
      each(([x, y, z]) => {
        let s = Math.trunc(S1 / 100) + Math.sin(z / height + S2);
        return [x * s, y * s, z];
      });
      break;
    case "cup":
      each(([x, y, z]) => {
        let s = Math.sin(z / height + 61);
        return [x * s, y * s, z];
      });
      break;
    case "scaleZExpo":
      each(([x, y, z]) => [x, y, z * ((1.01 * z) / height + 0.5)]);
      break;
    case "toastie":
      m.vertices = m.vertices.map(([x, y, z]) => [
        x + (x > 0 ? w / 4 : -w / 4),
        y,
        z,
      ]);
      break;
    case "flip": {
      const c = average(m.vertices);
      m.vertices = m.vertices.map((v) => rotate(v, 180, c, [-1, 0, 0]));
      const center = average(m.vertices);
      m.vertices = m.vertices.map((v) => add(center, mul(sub(v, center), 1.7)));
      break;
    }
    case "fatslab":
      m.vertices = m.vertices.map(([x, y, z]) => [x, y, z <= 4 ? z - 10 : z]);
      break;
    case "scaleSelection":
      each(([x, y, z]) => [x, y, z * 1.1]);
      break;
    case "twist":
      each((v) =>
        rotate(
          v,
          v[2] * 0.005 * rev,
          twistAxis(S1, S2).origin,
          twistAxis(S1, S2).direction,
        ),
      );
      break;
    case "sineTwist":
      m.vertices = m.vertices.map((v) =>
        rotate(
          v,
          v[2] *
            -0.002 *
            rev *
            Math.sin((v[2] / height) * Math.PI + Math.trunc(Z1 / 100) * h),
        ),
      );
      break;
    case "trumpet":
      each(([x, y, z]) => {
        let s = (1.01 * z) / height + 0.5;
        return [x * s, y * s, z];
      });
      break;
    case "bellbase": {
      let top = 0;
      for (const i of selected) top = Math.max(top, m.vertices[i][2]);
      each(([x, y, z]) => {
        let strength = map(S1, 0, 100, 0.1, 1),
          s =
            map(
              Math.cos(
                ((z / (top || 1)) * map(S2, 0, 100, 0, 0.5) * 180) / Math.PI,
              ) * strength,
              -1,
              1,
              1,
              1.5,
            ) * map(z, 0, top || 1, 0.5, 0);
        return [x * (1 + s), y * (1 + s), z];
      });
      break;
    }
    case "perlin":
      each((v) => {
        const ns = S2 * 0.002,
          strength = map(S1, 0, 100, 0.1, 1),
          n = map(noise(...mul(v, ns)), 0, 1, -strength, strength);
        return mul(v, 1 + n);
      });
      break;
    case "perlinForward2": {
      let strength = random(1, 1.3),
        offset = random(-100, 100);
      each(([x, y, z]) => [
        x,
        y < 0 && y > -10000
          ? y * map(noise(x, y - offset, z) / strength, 0, 1, 0.9, 1.4)
          : y,
        z,
      ]);
      break;
    }
    case "cropTop":
      m = m.clip(2, (Z1 / 100) * h, false);
      break;
    case "cropBase":
      m = m.clip(2, (Z2 / 100) * h, true);
      break;
    case "mirror":
    case "quattro": {
      m = m.clip(0, 0, true);
      if (name === "quattro") m = m.clip(1, 0, true);
      const original = m.clone(),
        reflect = (sx, sy) => {
          const a = original.clone();
          a.vertices = a.vertices.map(([x, y, z]) => [sx * x, sy * y, z]);
          if (sx * sy < 0) a.faces = a.faces.map((f) => f.reverse());
          return a;
        };
      m.append(reflect(-1, 1));
      if (name === "quattro") m.append(reflect(1, -1)).append(reflect(-1, -1));
      m.weld();
      break;
    }
    case "cavity": {
      const { neighbors } = m.topology(),
        start = Math.floor(random(m.faces.length));
      let remove = new Set();
      const walk = (fi, depth) => {
        for (const n of neighbors[fi])
          if (depth === 0 || Math.trunc(random(10)) > 3) {
            remove.add(n);
            if (depth < 3) walk(n, depth + 1);
          }
      };
      walk(start, 0);
      for (let i = 0; i < Math.trunc(S1 / 10); i++) {
        const next = new Set(remove);
        for (const f of remove) for (const n of neighbors[f]) next.add(n);
        remove = next;
      }
      m.removeFaces(remove);
      break;
    }
    case "patch": {
      const boundary = m
        .topology()
        .boundary.filter((e) => m.vertices[e.a][2] - 1 < h / 3);
      if (boundary.length) {
        let apex = m.vertices.length;
        m.vertices.push([0, 0, 0]);
        for (const e of boundary) {
          m.faces.push([e.b, e.a, apex]);
          m.colors.push([210, 210, 210]);
        }
      }
      break;
    }
    case "printerSlip": {
      const cut = (Z1 / 100) * h,
        lower = m.clip(2, cut, false),
        upper = m.clip(2, cut, true),
        boundary = upper.topology().boundary;
      upper.vertices.forEach((v) => (v[2] += 1));
      for (const e of boundary) {
        const a = upper.vertices[e.a],
          b = upper.vertices[e.b],
          ai = upper.vertices.length;
        upper.vertices.push([a[0], a[1], a[2] - 1], [b[0], b[1], b[2] - 1]);
        upper.faces.push([e.b, e.a, ai], [e.b, ai, ai + 1]);
        upper.colors.push([210, 210, 210], [210, 210, 210]);
      }
      m = lower.append(upper).weld();
      break;
    }
    case "spikes": {
      const areas = m.faces.map((_, i) => m.area(i)),
        max = areas.reduce((a, b) => Math.max(a, b), 1e-10),
        faces = [],
        colors = [];
      m.faces.forEach((f, i) => {
        const apex = m.vertices.length;
        m.vertices.push(
          add(
            m.center(i),
            mul(m.normal(i), (((areas[i] / max) * S1) / 5) * -rev),
          ),
        );
        f.forEach((a, j) => {
          faces.push([a, f[(j + 1) % f.length], apex]);
          colors.push(m.colors[i]);
        });
      });
      m.faces = faces;
      m.colors = colors;
      break;
    }
    case "smooth": {
      const { vertexNeighbors } = m.topology(),
        old = m.vertices.map((v) => [...v]);
      each((v, i) =>
        average([old[i], ...[...vertexNeighbors[i]].map((j) => old[j])]),
      );
      break;
    }
    case "subdivide":
      if (range) {
        const fs = new Set();
        m.faces.forEach((f, i) => {
          const z = m.center(i)[2];
          if (z > (range[0] * h) / 100 && z < (range[1] * h) / 100) fs.add(i);
        });
        m = subdivideRegion(m, fs, false).mesh.triangulate();
      } else m = m.subdivide(false);
      break;
    case "catmull":
      m = m.subdivide(true);
      break;
    case "fractal": {
      let levels = m.faces.map((_, i) =>
        Math.max(
          0,
          Math.min(2, Math.trunc((m.center(i)[2] / (height * 0.7)) * 2)),
        ),
      );
      for (let pass = 0; pass < 2; pass++) {
        const fs = new Set(levels.flatMap((n, i) => (n > pass ? [i] : [])));
        if (!fs.size) continue;
        const result = subdivideRegion(m, fs, true);
        levels = result.parents.map((i) => levels[i]);
        m = result.mesh;
      }
      m = m.triangulate();
      break;
    }
    case "moveX":
    case "moveY":
    case "moveZ": {
      let axis = { moveX: 0, moveY: 1, moveZ: 2 }[name];
      each((v) => {
        v[axis] += rev;
        return v;
      });
      break;
    }
    case "rotateX":
    case "rotateY":
    case "rotateZ": {
      let axis = { rotateX: [1, 0, 0], rotateY: [0, 1, 0], rotateZ: [0, 0, 1] }[
        name
      ];
      m.vertices = m.vertices.map((v) =>
        rotate(v, (rev * Math.PI) / 20, [0, 0, 0], axis),
      );
      break;
    }
    case "scaleX":
    case "scaleY":
    case "scaleZ":
    case "scaleAll": {
      const c = average(m.vertices),
        factor = map(S1, 0, 100, 0.2, 2),
        axis = { scaleX: 0, scaleY: 1, scaleZ: 2 }[name];
      m.vertices = m.vertices.map((v) =>
        v.map((x, i) =>
          name === "scaleAll" || i === axis ? c[i] + (x - c[i]) * factor : x,
        ),
      );
      break;
    }
    default:
      throw Error("Unknown operation: " + name);
  }
  m.validate();
  return m;
}
export function adjustColors(mesh, operation, seed = 2012) {
  const m = mesh.clone(),
    random = seededRandom(seed);
  if (operation === "pair" || operation === "neighbor") {
    const { neighbors } = m.topology();
    m.faces.forEach((_, i) => {
      const n = [...neighbors[i]][0];
      if (n !== undefined) m.colors[n] = [...m.colors[i]];
    });
    return m;
  }
  const hsv = m.colors.map(rgbToHSV);
  let lo = 255,
    hi = 0;
  for (const c of hsv) {
    lo = Math.min(lo, c[2]);
    hi = Math.max(hi, c[2]);
  }
  m.colors = hsv.map(([h, s, b]) => {
    if (operation === "contrast" && hi !== lo) b = map(b, lo, hi, 0, 255);
    if (operation === "saturate" && s <= 245 && b < 155 && random(1) > 0.4)
      s += 10;
    if (operation === "brighten" && b > 150 && b <= 245) b += 10;
    if (operation === "hueUp" && h <= 250) h += 2;
    if (operation === "hueDown" && h <= 250) h -= 2;
    return hsvToRGB(h, s, b);
  });
  return m;
}
