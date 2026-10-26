// glTF 2.0: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html
// Export-only conversion: working geometry and colours are never modified.
const linear = (byte) => {
  const s = byte / 255;
  return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
};
export function buildGLTF(
  mesh,
  { name = "Digital Natives", unit = "mm" } = {},
) {
  mesh.validate();
  const scale = { mm: 0.001, cm: 0.01, m: 1 }[unit];
  if (!scale) throw Error("Unsupported model unit.");
  const triangles = mesh.triangles(),
    count = triangles.length * 3;
  const binary = new ArrayBuffer(count * 36),
    data = new DataView(binary);
  const min = [Infinity, Infinity, Infinity],
    max = [-Infinity, -Infinity, -Infinity];
  let index = 0;
  for (const t of triangles) {
    const normal = mesh.normal(t.face),
      n = Math.hypot(...normal)
        ? [normal[0], normal[2], -normal[1]]
        : [0, 1, 0];
    const colour = t.color.map(linear);
    for (const id of t.ids) {
      const [x, y, z] = mesh.vertices[id],
        position = [x * scale, z * scale, -y * scale].map(Math.fround);
      if (!position.every(Number.isFinite))
        throw Error("Coordinates exceed glTF precision.");
      for (let k = 0; k < 3; k++) {
        min[k] = Math.min(min[k], position[k]);
        max[k] = Math.max(max[k], position[k]);
        data.setFloat32(index * 12 + k * 4, position[k], true);
        data.setFloat32(count * 12 + index * 12 + k * 4, n[k], true);
        data.setFloat32(count * 24 + index * 12 + k * 4, colour[k], true);
      }
      index++;
    }
  }
  const json = {
    asset: { version: "2.0", generator: "Digital Natives — ccc / co_former" },
    scene: 0,
    scenes: [{ nodes: [0] }],
    nodes: [{ mesh: 0, name }],
    meshes: [
      {
        name,
        primitives: [
          {
            attributes: { POSITION: 0, NORMAL: 1, COLOR_0: 2 },
            material: 0,
            mode: 4,
          },
        ],
      },
    ],
    materials: [
      {
        name: "Face colours",
        doubleSided: true,
        pbrMetallicRoughness: {
          baseColorFactor: [1, 1, 1, 1],
          metallicFactor: 0,
          roughnessFactor: 1,
        },
      },
    ],
    buffers: [{ byteLength: binary.byteLength }],
    bufferViews: [0, 1, 2].map((i) => ({
      buffer: 0,
      byteOffset: i * count * 12,
      byteLength: count * 12,
      target: 34962,
    })),
    accessors: [
      { bufferView: 0, componentType: 5126, count, type: "VEC3", min, max },
      { bufferView: 1, componentType: 5126, count, type: "VEC3" },
      { bufferView: 2, componentType: 5126, count, type: "VEC3" },
    ],
    extras: {
      sourceUnits: unit,
      sourceUpAxis: "Z",
      description:
        "Face colours preserved as linear vertex colours; coordinates converted to metres and Y-up.",
    },
  };
  return { json, binary };
}
export function exportGLB(mesh, options) {
  const { json, binary } = buildGLTF(mesh, options),
    encoded = new TextEncoder().encode(JSON.stringify(json)),
    jsonSize = Math.ceil(encoded.length / 4) * 4;
  const output = new ArrayBuffer(12 + 8 + jsonSize + 8 + binary.byteLength),
    view = new DataView(output),
    bytes = new Uint8Array(output);
  view.setUint32(0, 0x46546c67, true);
  view.setUint32(4, 2, true);
  view.setUint32(8, output.byteLength, true);
  view.setUint32(12, jsonSize, true);
  view.setUint32(16, 0x4e4f534a, true);
  bytes.fill(32, 20, 20 + jsonSize);
  bytes.set(encoded, 20);
  const offset = 20 + jsonSize;
  view.setUint32(offset, binary.byteLength, true);
  view.setUint32(offset + 4, 0x004e4942, true);
  bytes.set(new Uint8Array(binary), offset + 8);
  return output;
}
export function exportGLTF(mesh, options) {
  const { json, binary } = buildGLTF(mesh, options),
    bytes = new Uint8Array(binary);
  let text = "";
  for (let i = 0; i < bytes.length; i += 8192)
    text += String.fromCharCode(...bytes.subarray(i, i + 8192));
  json.buffers[0].uri = "data:application/octet-stream;base64," + btoa(text);
  return JSON.stringify(json, null, 2);
}
