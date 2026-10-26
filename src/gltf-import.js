import { GLTFLoader } from "../vendor/three/GLTFLoader.js";
import {
  LoadingManager,
  Matrix4,
  Vector3,
} from "../vendor/three/three.core.js";
import { Mesh } from "./mesh.js";

const srgb = (x) =>
  Math.round(
    255 *
      Math.max(
        0,
        Math.min(
          1,
          x <= 0.0031308 ? x * 12.92 : 1.055 * x ** (1 / 2.4) - 0.055,
        ),
      ),
  );
const MAX_BYTES = 100 * 1024 * 1024;

// Keep all dependencies local. Texture maps are deliberately omitted: the editor
// stores one RGB colour per face, not UVs or physically based materials.
export async function parseGLTF(buffer, files = [], unit = "mm") {
  if (buffer.byteLength > MAX_BYTES)
    throw Error("Please use a model smaller than 100 MB.");
  let json, binary;
  const view = new DataView(buffer);
  if (buffer.byteLength >= 12 && view.getUint32(0, true) === 0x46546c67) {
    if (
      view.getUint32(4, true) !== 2 ||
      view.getUint32(8, true) !== buffer.byteLength
    )
      throw Error("Invalid glTF 2.0 GLB header.");
    for (let offset = 12; offset < buffer.byteLength; ) {
      if (offset + 8 > buffer.byteLength) throw Error("Incomplete GLB chunk.");
      const size = view.getUint32(offset, true),
        type = view.getUint32(offset + 4, true);
      offset += 8;
      if (offset + size > buffer.byteLength)
        throw Error("Incomplete GLB data.");
      if (type === 0x4e4f534a)
        json = JSON.parse(
          new TextDecoder().decode(buffer.slice(offset, offset + size)),
        );
      if (type === 0x004e4942) binary = buffer.slice(offset, offset + size);
      offset += size;
    }
  } else json = JSON.parse(new TextDecoder().decode(buffer));
  if (!json || json.asset?.version !== "2.0")
    throw Error("Please use a glTF 2.0 model.");
  const allowed = [
    "KHR_mesh_quantization",
    "EXT_mesh_gpu_instancing",
    "KHR_materials_unlit",
  ];
  const unsupported = (json.extensionsRequired || []).filter(
    (x) => !allowed.includes(x),
  );
  if (unsupported.length)
    throw Error(
      `Unsupported glTF extension: ${unsupported.join(", ")}. Re-export as an uncompressed GLB with standard materials.`,
    );
  if (
    (json.meshes || []).some((m) =>
      m.primitives.some((p) => p.extensions?.KHR_draco_mesh_compression),
    ) ||
    (json.bufferViews || []).some((v) => v.extensions?.EXT_meshopt_compression)
  )
    throw Error(
      "Compressed meshes are not supported yet. Re-export as an uncompressed GLB.",
    );
  const warnings = [];
  if (json.textures?.length)
    warnings.push("Texture maps omitted; base and vertex colours retained.");
  if (json.animations?.length || json.skins?.length)
    warnings.push("Imported as a static mesh in its initial pose.");
  if (
    (json.materials || []).some(
      (m) =>
        (m.alphaMode && m.alphaMode !== "OPAQUE") ||
        Object.keys(m.extensions || {}).some(
          (x) => x !== "KHR_materials_unlit",
        ),
    )
  )
    warnings.push(
      "Transparency and advanced materials converted to solid face colours.",
    );
  json.materials = (json.materials || []).map((m) => ({
    pbrMetallicRoughness: {
      baseColorFactor: m.pbrMetallicRoughness?.baseColorFactor || [1, 1, 1, 1],
      metallicFactor: 0,
      roughnessFactor: 1,
    },
    doubleSided: true,
  }));
  delete json.images;
  delete json.textures;
  delete json.samplers;
  delete json.animations;
  const urls = [];
  let total = buffer.byteLength;
  try {
    for (const b of json.buffers || []) {
      let data;
      if (!b.uri) {
        if (!binary) throw Error("Missing GLB binary data.");
        data = binary;
      } else if (b.uri.startsWith("data:")) continue;
      else {
        const name = decodeURIComponent(b.uri).split("/").pop();
        const matches = Array.from(files).filter((f) => f.name === name);
        if (matches.length !== 1)
          throw Error(
            `Select the glTF and its companion file “${name}” together, or export a single GLB.`,
          );
        total += matches[0].size;
        if (total > MAX_BYTES)
          throw Error("Please use model files totalling less than 100 MB.");
        data = await matches[0].arrayBuffer();
      }
      const url = URL.createObjectURL(new Blob([data]));
      urls.push(url);
      b.uri = url;
    }
    const manager = new LoadingManager();
    manager.setURLModifier((url) => {
      if (urls.includes(url) || url.startsWith("data:")) return url;
      throw Error("Only selected local model files can be loaded.");
    });
    const gltf = await new GLTFLoader(manager).parseAsync(json, "");
    const scene = gltf.scene;
    if (!scene) throw Error("This glTF has no scene.");
    scene.updateMatrixWorld(true);
    scene.traverse((o) => {
      if (o.isSkinnedMesh) o.skeleton.update();
    });
    const vertices = [],
      faces = [],
      colors = [];
    const scale = { mm: 1000, cm: 100, m: 1 }[unit];
    if (!scale) throw Error("Unsupported model unit.");
    const position = new Vector3(),
      instance = new Matrix4(),
      matrix = new Matrix4();
    scene.traverse((o) => {
      if (!o.isMesh) {
        if (o.isLine || o.isPoints) warnings.push("Lines and points omitted.");
        return;
      }
      const g = o.geometry,
        attr = g.attributes.position;
      if (!attr) return;
      const count = g.index ? g.index.count : attr.count;
      const instances = o.isInstancedMesh ? o.count : 1;
      if (faces.length + Math.floor(count / 3) * instances > 200000)
        throw Error("Mesh exceeds the 200,000-face browser limit.");
      for (let n = 0; n < instances; n++) {
        matrix.copy(o.matrixWorld);
        if (o.isInstancedMesh) {
          o.getMatrixAt(n, instance);
          matrix.multiply(instance);
        }
        const reflected = matrix.determinant() < 0;
        for (let i = 0; i + 2 < count; i += 3) {
          const ids = [0, 1, 2].map((k) =>
            g.index ? g.index.getX(i + k) : i + k,
          );
          if (reflected) [ids[1], ids[2]] = [ids[2], ids[1]];
          const face = [],
            rgb = [0, 0, 0];
          const group = g.groups.find(
            (x) => i >= x.start && i < x.start + x.count,
          );
          const material = Array.isArray(o.material)
            ? o.material[group?.materialIndex || 0]
            : o.material;
          const base = material?.color;
          for (const id of ids) {
            o.getVertexPosition(id, position).applyMatrix4(matrix);
            face.push(vertices.length);
            vertices.push([
              position.x * scale,
              -position.z * scale,
              position.y * scale,
            ]);
            const c = g.attributes.color;
            for (let k = 0; k < 3; k++)
              rgb[k] +=
                (((c ? c.getComponent(id, k) : 1) *
                  (base ? [base.r, base.g, base.b][k] : 1)) /
                  3) *
                (o.instanceColor ? o.instanceColor.getComponent(n, k) : 1);
          }
          faces.push(face);
          colors.push(rgb.map(srgb));
        }
      }
    });
    if (!faces.length) throw Error("No triangle mesh found in this glTF.");
    return {
      mesh: new Mesh(vertices, faces, colors).validate().weld().validate(),
      warnings: [...new Set(warnings)],
    };
  } finally {
    urls.forEach((url) => URL.revokeObjectURL(url));
  }
}
