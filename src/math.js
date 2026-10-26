export const map = (x, a, b, c, d) =>
  a === b ? c : c + ((x - a) * (d - c)) / (b - a);
export const clamp = (x, a = 0, b = 255) =>
  Math.max(a, Math.min(b, Number.isNaN(x) ? 0 : x));
export function seededRandom(seed = 2012) {
  let s = seed >>> 0;
  return (a = 1, b) => {
    s = (Math.imul(s, 1664525) + 1013904223) >>> 0;
    let n = s / 4294967296;
    return b === undefined ? n * a : a + n * (b - a);
  };
}
export function hsvToRGB(h, s, v) {
  h = (clamp(h) / 255) * 6;
  s = clamp(s) / 255;
  v = clamp(v);
  let i = Math.floor(h),
    f = h - i,
    p = v * (1 - s),
    q = v * (1 - f * s),
    t = v * (1 - (1 - f) * s);
  return [
    [v, t, p],
    [q, v, p],
    [p, v, t],
    [p, q, v],
    [t, p, v],
    [v, p, q],
  ][i % 6].map((x) => Math.floor(clamp(x)));
}
export function rgbToHSV([r, g, b]) {
  let max = Math.max(r, g, b),
    min = Math.min(r, g, b),
    d = max - min,
    h = 0;
  if (d) {
    if (max === r) h = ((g - b) / d + 6) % 6;
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
  }
  return [(h / 6) * 255, max ? (d / max) * 255 : 0, max];
}
export function createColorAPI() {
  let mode = "RGB";
  return {
    RGB: "RGB",
    HSB: "HSB",
    colorMode: (m) => (mode = m),
    color: (...args) => {
      let [r, g, b] = args;
      if (args.length === 1)
        return Array.isArray(r)
          ? [...r]
          : [r, r, r].map((x) => Math.floor(clamp(x)));
      return mode === "HSB"
        ? hsvToRGB(r, g, b)
        : [r, g, b].map((x) => Math.floor(clamp(x)));
    },
    red: (c) => c[0],
    green: (c) => c[1],
    blue: (c) => c[2],
    lerpColor: (a, b, t) =>
      a.map((v, i) => Math.floor(clamp(v + (b[i] - v) * clamp(t, 0, 1)))),
  };
}
export const add = (a, b) => a.map((x, i) => x + b[i]);
export const sub = (a, b) => a.map((x, i) => x - b[i]);
export const mul = (a, s) => a.map((x) => x * s);
export const dot = (a, b) => a.reduce((s, x, i) => s + x * b[i], 0);
export const cross = (a, b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
export const length = (a) => Math.hypot(...a);
export const unit = (a) => mul(a, 1 / (length(a) || 1));
export const average = (a) =>
  mul(
    a.reduce((s, v) => add(s, v), [0, 0, 0]),
    1 / (a.length || 1),
  );
export function rotate(v, angle, origin = [0, 0, 0], axis = [0, 0, 1]) {
  const p = sub(v, origin),
    n = unit(axis),
    c = Math.cos(angle),
    s = Math.sin(angle);
  return add(
    origin,
    add(add(mul(p, c), mul(cross(n, p), s)), mul(n, dot(n, p) * (1 - c))),
  );
}
