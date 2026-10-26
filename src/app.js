import { exportGLB, exportGLTF } from "./gltf.js";
import { colourLabels, formLabels } from "./parameter-labels.js";
import { stageRecord, workspaceId } from "./stage-store.js";
import {
  Mesh,
  parseSTL,
  parseOBJ,
  exportSTL,
  exportOBJ,
  exportVRML,
} from "./mesh.js";
import { createColorAlgorithm, COLOR_NAMES } from "./colors.js";
import {
  OPERATIONS,
  twistAxis,
  operate,
  adjustColors,
  selectedVertices,
} from "./operations.js";
const $ = (id) => document.getElementById(id),
  tool =
    new URLSearchParams(location.search).get("tool") === "ccc"
      ? "ccc"
      : "coformer";
let mesh,
  original,
  importedColors,
  geometry,
  edgeGeometry,
  app,
  range = null,
  undo = [],
  redo = [],
  seed = 2012,
  revision = 0,
  pendingAppend = false,
  modelName = "vase.stl",
  viewScale = 1,
  cachedBounds,
  cachedEdges = [];
let params = [0, 240, 240, 110, 110, 85, 0, 0],
  form = {
    X1: 100,
    Y1: 100,
    Z1: 100,
    X2: 0,
    Y2: 0,
    Z2: 0,
    S1: 0,
    S2: 0,
    reversal: 1,
  },
  algorithm = 2;
const status = (text, error = false) => {
  $("status").textContent = text;
  $("status").style.color = error ? "#b52615" : "";
};
const snapshot = () => ({
  mesh: mesh.clone(),
  params: [...params],
  form: { ...form },
  algorithm,
  seed,
  range: range ? [...range] : null,
  modelName,
});
function applySnapshot(s) {
  mesh = s.mesh.clone();
  params = [...s.params];
  form = { ...s.form };
  algorithm = s.algorithm;
  seed = s.seed;
  range = s.range ? [...s.range] : null;
  modelName = s.modelName;
  sync();
  rebuild();
}
function remember() {
  undo.push(snapshot());
  while (undo.length > 15) undo.shift();
  redo = [];
}
function transaction(fn, message = "Updated") {
  const before = snapshot();
  try {
    fn();
    mesh.validate();
    undo.push(before);
    while (undo.length > 15) undo.shift();
    redo = [];
    rebuild();
    status(message);
  } catch (e) {
    applySnapshot(before);
    status(e.message, true);
  }
}
function sync() {
  params.forEach((v, i) => {
    const id = "P" + (i + 1);
    $(id).value = v;
    $(id + "-value").value = v;
  });
  for (const k of ["Z1", "Z2", "S1", "S2"]) {
    $(k).value = form[k];
    $(k + "-value").value = form[k];
  }
  $("algorithm").value = algorithm;
  $("reverse").checked = form.reversal < 0;
  updateColourLabels();
  updateFormLabels($("operation").value);
}
function recolor() {
  const dims = mesh.dimensions();
  const fn = createColorAlgorithm((...v) => app.noise(...v), seed);
  mesh.colors = mesh.faces.map((_, i) =>
    fn(
      ...mesh.center(i),
      mesh.area(i),
      tool === "coformer" ? 2 : algorithm,
      params,
      dims,
    ),
  );
}
function rebuild() {
  if (!app || !mesh) return;
  if (geometry) app.freeGeometry(geometry);
  if (edgeGeometry) app.freeGeometry(edgeGeometry);
  geometry = new p5.Geometry();
  const triangles = mesh.triangles();
  for (const t of triangles) {
    const n = mesh.normal(t.face),
      base = geometry.vertices.length;
    for (const j of t.ids) {
      geometry.vertices.push(new p5.Vector(...mesh.vertices[j]));
      geometry.vertexNormals.push(new p5.Vector(...n));
      geometry.vertexColors.push(...t.color.map((c) => c / 255), 1);
    }
    geometry.faces.push([base, base + 1, base + 2]);
  }
  geometry.gid = "mesh-" + ++revision;
  edgeGeometry = null;
  cachedBounds = mesh.bounds();
  cachedEdges = [...mesh.topology().edges.values()].map((es) => [
    mesh.vertices[es[0].a],
    mesh.vertices[es[0].b],
  ]);
  $("model-name").textContent = modelName;
  $("stats").textContent =
    `${mesh.vertices.length.toLocaleString()} vertices / ${mesh.faces.length.toLocaleString()} faces`;
  $("undo").disabled = !undo.length;
  $("redo").disabled = !redo.length;
  $("selection-info").textContent = range
    ? `${selectedVertices(mesh, range).size.toLocaleString()} vertices selected between ${range[0]}–${range[1]}% height`
    : "All vertices selected";
  app.redraw();
}
function fit() {
  if (!mesh) return;
  const b = mesh.bounds();
  viewScale = (Math.min(app.width, app.height) * 0.65) / Math.max(...b.size, 1);
  app.camera(0, 0, app.height / (2 * Math.tan(Math.PI / 6)), 0, 0, 0, 0, 1, 0);
  app.redraw();
}
async function load(buffer, name, append = false, files = []) {
  const isGLTF = /\.(glb|gltf)$/i.test(name);
  const result = isGLTF
    ? await (
        await import("./gltf-import.js")
      ).parseGLTF(buffer, files, $("gltf-units").value)
    : null;
  const incoming = result
    ? result.mesh
    : name.toLowerCase().endsWith(".obj")
      ? parseOBJ(new TextDecoder().decode(buffer))
      : parseSTL(buffer);
  if (append && mesh) {
    transaction(() => {
      mesh.append(incoming);
      range = null;
      if (!isGLTF) recolor();
    }, "Model appended");
  } else {
    mesh = incoming;
    modelName = name;
    original = mesh.clone();
    importedColors = mesh.colors.map((c) => [...c]);
    undo = [];
    redo = [];
    range = null;
    if (!isGLTF) recolor();
    rebuild();
    fit();
    status("Ready. Open a model or explore the original sample.");
  }
  if (result)
    status(
      ["Imported glTF geometry and face colours.", ...result.warnings].join(
        " ",
      ),
    );
}
function save(data, name, type = "application/octet-stream") {
  const blob = new Blob([data], { type }),
    url = URL.createObjectURL(blob),
    a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
  status("Saved " + name);
}
function run(name) {
  updateFormLabels(name);
  transaction(
    () => {
      mesh = operate(mesh, name, form, (...v) => app.noise(...v), seed, range);
      if (Object.hasOwn(OPERATIONS, name)) {
        mesh.ground();
        range = null;
      }
      if (name === "cropBase") mesh.ground();
      recolor();
    },
    "Applied " + (OPERATIONS[name] || name),
  );
}
function button(parent, label, fn) {
  let b = document.createElement("button");
  b.textContent = label;
  b.addEventListener("click", fn);
  $(parent).append(b);
}
function slider(parent, name, value, min, max, update) {
  const label = document.createElement("label");
  label.className = "slider";
  const caption = document.createElement("span");
  caption.id = name + "-label";
  caption.textContent = name;
  label.append(caption);
  const r = document.createElement("input");
  r.type = "range";
  r.id = name;
  r.min = min;
  r.max = max;
  r.value = value;
  const n = document.createElement("input");
  n.type = "number";
  n.id = name + "-value";
  n.min = min;
  n.max = max;
  n.value = value;
  n.setAttribute("aria-label", name + " value");
  r.setAttribute("aria-label", name);
  label.append(r, n);
  $(parent).append(label);
  let saved = false;
  const start = () => {
    if (mesh && !saved) {
      remember();
      saved = true;
    }
  };
  r.addEventListener("pointerdown", start);
  for (const el of [r, n]) {
    el.addEventListener("input", () => {
      start();
      const raw = Number(el.value);
      if (!Number.isFinite(raw)) return;
      const v = Math.round(Math.max(min, Math.min(max, raw)));
      r.value = n.value = v;
      update(v);
    });
    el.addEventListener("change", () => {
      saved = false;
    });
  }
}
function labelParameters(ids, labels, disableUnused = false) {
  ids.forEach((id, i) => {
    const caption = $(id + "-label");
    caption.replaceChildren();
    const name = document.createElement("span");
    name.textContent = labels[i];
    const code = document.createElement("small");
    code.textContent = id;
    caption.append(name, code);
    const unused = labels[i] === "Unused";
    caption.parentElement.classList.toggle("unused", unused);
    for (const control of [$(id), $(id + "-value")]) {
      control.setAttribute(
        "aria-label",
        labels[i] +
          " (" +
          id +
          ")" +
          (control.type === "number" ? " value" : ""),
      );
      if (disableUnused) control.disabled = unused;
    }
  });
}
function updateColourLabels() {
  const { labels, note } = colourLabels(algorithm);
  labelParameters(
    params.map((_, i) => "P" + (i + 1)),
    labels,
    true,
  );
  $("colour-help").textContent = note;
}
function updateFormLabels(name) {
  const { labels, note } = formLabels(name);
  labelParameters(["Z1", "Z2", "S1", "S2"], labels);
  $("form-help").textContent = note;
}
const packStage = () => ({
  ...snapshot(),
  original,
  importedColors,
  operation: $("operation").value,
});
let changingStage = false;
async function changeStage(target, transfer = false) {
  if (!mesh || changingStage) return;
  changingStage = true;
  try {
    status(
      transfer
        ? "Moving this model to colouring…"
        : "Keeping your work while switching stages…",
    );
    const id = workspaceId();
    await stageRecord(id + ":" + tool, packStage());
    if (transfer) {
      const current = mesh.clone();
      await stageRecord(id + ":ccc", {
        ...packStage(),
        mesh: current,
        original: current,
        importedColors: current.colors,
        range: null,
        transferred: true,
      });
    }
    location.assign("?tool=" + target);
  } catch (e) {
    changingStage = false;
    status(
      "Could not switch stages: " +
        e.message +
        ". Save a session to keep your work.",
      true,
    );
  }
}
async function restoreStage() {
  try {
    const s = await stageRecord(workspaceId() + ":" + tool);
    if (!s) return false;
    const restored = new Mesh(
      s.mesh.vertices,
      s.mesh.faces,
      s.mesh.colors,
    ).validate();
    original = new Mesh(
      s.original.vertices,
      s.original.faces,
      s.original.colors,
    ).validate();
    importedColors = s.importedColors;
    undo = [];
    redo = [];
    if (s.operation && OPERATIONS[s.operation])
      $("operation").value = s.operation;
    applySnapshot({ ...s, mesh: restored });
    fit();
    status(
      s.transferred
        ? "Model received from co_former. Choose an algorithm or adjust the colour controls."
        : "Your " +
            (tool === "ccc" ? "colouring" : "form") +
            " work is restored.",
    );
    return true;
  } catch (e) {
    status("Could not restore the stage: " + e.message, true);
    return false;
  }
}
$("tool-title").textContent = tool === "ccc" ? "_c_c_c_" : "co_former";
document.title = `${tool === "ccc" ? "ccc" : "co_former"} — Digital Natives`;
$(`${tool}-tab`).classList.add("active");
$("intro").textContent =
  tool === "ccc"
    ? "Colour as an algorithm. Explore the original gradients, noise and face-based colour experiments."
    : "Transform, cut and rebuild. A browser restoration of the original fff / co_former sketch.";
$("colour-panel").hidden = tool !== "ccc";
$("guides-control").hidden = tool !== "coformer";
$("guide-legend").hidden = tool !== "coformer";
$("form-panel").hidden = tool !== "coformer";
$("edges").checked = tool === "coformer";
$("continue-colouring").hidden = tool !== "coformer";
$("continue-colouring").onclick = () => changeStage("ccc", true);
for (const stage of ["coformer", "ccc"])
  $(stage + "-tab").onclick = (e) => {
    e.preventDefault();
    if (stage !== tool) changeStage(stage);
  };
for (const [id, name] of Object.entries(COLOR_NAMES)) {
  $("algorithm").add(new Option(`${id.padStart(2, "0")} / ${name}`, id));
}
for (const [id, name] of Object.entries(OPERATIONS))
  $("operation").add(new Option(name, id));
params.forEach((v, i) =>
  slider("colour-sliders", "P" + (i + 1), v, 0, i >= 6 ? 100 : 255, (x) => {
    params[i] = x;
    if (mesh) {
      recolor();
      rebuild();
    }
  }),
);
for (const k of ["Z1", "Z2", "S1", "S2"])
  slider("form-sliders", k, form[k], 0, 100, (v) => {
    form[k] = v;
    app?.redraw();
  });
updateColourLabels();
updateFormLabels($("operation").value);
$("operation").onchange = () => updateFormLabels($("operation").value);
$("algorithm").value = algorithm;
$("algorithm").onchange = () =>
  transaction(
    () => {
      algorithm = Number($("algorithm").value);
      updateColourLabels();
      recolor();
    },
    COLOR_NAMES[Number($("algorithm").value)],
  );
$("reroll").onclick = () =>
  transaction(() => {
    seed++;
    recolor();
  }, "New colour variation");
for (const [name, label] of Object.entries({
  contrast: "Contrast",
  saturate: "Saturate",
  brighten: "Brighten brights",
  hueDown: "Hue −",
  hueUp: "Hue +",
  pair: "Colour pair",
  neighbor: "Colour neighbour",
}))
  button("colour-actions", label, () =>
    transaction(() => {
      mesh = adjustColors(mesh, name, seed);
    }, label),
  );
button("colour-actions", "Subdivide", () => run("subdivide"));
button("selection-actions", "Select all", () => {
  range = null;
  rebuild();
});
button("selection-actions", "Select Z region", () => {
  range = [Math.min(form.Z1, form.Z2), Math.max(form.Z1, form.Z2)];
  rebuild();
});
button("selection-actions", "Crop top", () => run("cropTop"));
button("selection-actions", "Crop base", () => run("cropBase"));
for (const [name, label] of Object.entries({
  twist: "Twist",
  sineTwist: "Sine twist",
  smooth: "Smooth",
  subdivide: "Planar subdivision",
  catmull: "Catmull–Clark",
  fractal: "Fractal subdivision",
  cup: "Cup",
  bellbase: "Bell base",
  trumpet: "Trumpet",
}))
  button("form-actions", label, () => run(name));
for (const axis of ["X", "Y", "Z"]) {
  button("position-actions", "Move " + axis, () => run("move" + axis));
  button("position-actions", "Rotate " + axis, () => run("rotate" + axis));
  button("position-actions", "Scale " + axis, () => run("scale" + axis));
}
button("position-actions", "Scale all (S1)", () => run("scaleAll"));
$("apply").onclick = () => run($("operation").value);
$("reverse").onchange = () => (form.reversal = $("reverse").checked ? -1 : 1);
$("undo").onclick = () => {
  if (!undo.length) return;
  redo.push(snapshot());
  applySnapshot(undo.pop());
  status("Undone");
};
$("redo").onclick = () => {
  if (!redo.length) return;
  undo.push(snapshot());
  applySnapshot(redo.pop());
  status("Redone");
};
$("reset").onclick = () =>
  transaction(() => {
    mesh = original.clone();
    range = null;
    recolor();
    fit();
  }, "Model reset");
$("original-colors").onclick = () =>
  transaction(() => {
    if (
      mesh.faces.length !== importedColors.length ||
      mesh.faces.some(
        (f, i) =>
          f.length !== original.faces[i].length ||
          f.some((v, j) => v !== original.faces[i][j]),
      )
    )
      throw Error("Reset the model before restoring its imported colours.");
    mesh.colors = importedColors.map((c) => [...c]);
  }, "Imported colours restored");
$("open").onclick = () => {
  pendingAppend = false;
  $("file").click();
};
$("append").onclick = () => {
  pendingAppend = true;
  $("file").click();
};
const modelFeedback = (text, error = false) => {
  status(text, error);
};
let modelLoading = false;
async function modelTask(label, action) {
  if (modelLoading) return;
  modelLoading = true;
  for (const id of ["open", "append", "load-sample"]) $(id).disabled = true;
  modelFeedback(label);
  try {
    // Give the browser a chance to show progress before decoding the model.
    await new Promise((resolve) =>
      requestAnimationFrame(() => setTimeout(resolve, 0)),
    );
    await action();
    modelFeedback($("status").textContent);
  } catch (e) {
    const message = /fetch|importing a module|module script/i.test(e.message)
      ? "Could not load the importer. Check the local preview is running, then refresh this page and try again."
      : e.message;
    modelFeedback("Could not open model: " + message, true);
  } finally {
    modelLoading = false;
    for (const id of ["open", "append", "load-sample"]) $(id).disabled = false;
  }
}
$("file").onchange = async () => {
  const files = Array.from($("file").files);
  const models = files.filter((f) => /\.(glb|gltf|stl|obj)$/i.test(f.name));
  if (models.length !== 1 && files.length) {
    modelFeedback(
      "Select one model, plus any glTF companion .bin files.",
      true,
    );
    $("file").value = "";
    return;
  }
  const f = models[0],
    append = pendingAppend;
  if (f)
    await modelTask("Opening " + f.name + "…", async () => {
      await load(await f.arrayBuffer(), f.name, append, files);
      status("Opened " + f.name + ". " + $("status").textContent);
    });
  $("file").value = "";
};
$("load-sample").onclick = async () => {
  const name = $("sample").value;
  await modelTask("Loading sample " + name + "…", async () => {
    const r = await fetch("assets/" + name);
    if (!r.ok) throw Error("Could not load sample.");
    await load(await r.arrayBuffer(), name);
    status(
      "Loaded sample " + name + ". Use Open model to choose your own file.",
    );
  });
};
const filename = (ext) =>
  `${tool}-${new Date().toISOString().replace(/[:.]/g, "-")}.${ext}`;
for (const [id, exporter, mime] of [
  ["glb", exportGLB, "model/gltf-binary"],
  ["gltf", exportGLTF, "model/gltf+json"],
]) {
  $(id).onclick = () => {
    try {
      save(
        exporter(mesh, { name: modelName, unit: $("gltf-units").value }),
        filename(id),
        mime,
      );
    } catch (e) {
      status("Export failed: " + e.message, true);
    }
  };
}
$("stl").onclick = () => save(exportSTL(mesh), filename("stl"));
$("vrml").onclick = () => save(exportVRML(mesh), filename("wrl"), "model/vrml");
$("obj").onclick = () => save(exportOBJ(mesh), filename("obj"), "text/plain");
$("png").onclick = () => {
  app.redraw();
  app.saveCanvas(filename("png").replace(/\.png$/, ""), "png");
};
$("project").onclick = () =>
  save(
    JSON.stringify(
      {
        format: "digital-natives-session",
        version: 1,
        tool,
        ...snapshot(),
        original,
        importedColors,
      },
      null,
      2,
    ),
    filename("json"),
    "application/json",
  );
$("parameters").onclick = () =>
  save(
    [
      "cc = " + algorithm,
      ...params.map((v, i) => "P" + (i + 1) + " = " + v),
    ].join("\n") + "\n",
    filename("txt"),
    "text/plain",
  );
$("restore").onclick = () => $("session-file").click();
$("session-file").onchange = async () => {
  try {
    const f = $("session-file").files[0];
    if (!f) return;
    if (f.size > 100 * 1024 * 1024)
      throw Error("Session exceeds 100 MB limit.");
    const text = await f.text();
    if (f.name.toLowerCase().endsWith(".txt")) {
      const found = {};
      for (const match of text.matchAll(/^(cc|P[1-8])\s*=\s*(-?\d+)\s*$/gm))
        found[match[1]] = Number(match[2]);
      if (
        !Object.hasOwn(found, "cc") ||
        !COLOR_NAMES[found.cc] ||
        Array.from({ length: 8 }, (_, i) => "P" + (i + 1)).some(
          (k) => !Number.isFinite(found[k]),
        )
      )
        throw Error("Not a complete original ccc notes file.");
      transaction(() => {
        algorithm = found.cc;
        params = params.map((_, i) =>
          Math.max(0, Math.min(i >= 6 ? 100 : 255, found["P" + (i + 1)])),
        );
        sync();
        recolor();
      }, "Original ccc parameters restored");
      return;
    }
    const s = JSON.parse(text);
    if (s.format !== "digital-natives-session" || s.version !== 1)
      throw Error("Unrecognised session file.");
    if (s.tool !== tool)
      throw Error(
        `Open this session in the ${s.tool === "ccc" ? "ccc" : "co_former"} tab.`,
      );
    if (
      !Array.isArray(s.params) ||
      s.params.length !== 8 ||
      !s.params.every(Number.isFinite) ||
      !Number.isInteger(s.algorithm) ||
      !COLOR_NAMES[s.algorithm] ||
      !Number.isFinite(s.seed) ||
      !s.form ||
      !Object.values(s.form).every(Number.isFinite)
    )
      throw Error("Invalid session parameters.");
    const restored = new Mesh(
        s.mesh.vertices,
        s.mesh.faces,
        s.mesh.colors,
      ).validate(),
      base = new Mesh(
        s.original.vertices,
        s.original.faces,
        s.original.colors,
      ).validate();
    if (
      !restored.colors.every(
        (c) =>
          c.length === 3 &&
          c.every((x) => Number.isFinite(x) && x >= 0 && x <= 255),
      )
    )
      throw Error("Invalid session colours.");
    original = base;
    importedColors = s.importedColors || base.colors;
    undo = [];
    redo = [];
    applySnapshot({ ...s, mesh: restored });
    fit();
    status("Session restored");
  } catch (e) {
    status(e.message, true);
  }
  $("session-file").value = "";
};
$("fit").onclick = fit;
for (const id of ["edges", "lights", "guides"])
  $(id).onchange = () => {
    $("guide-legend").hidden = tool !== "coformer" || !$("guides").checked;
    app.redraw();
  };
function drawGuides(p, b) {
  const width = Math.max(b.size[0] * 1.3, 5);
  const depth = Math.max(b.size[1] * 1.3, 5);
  const [cx, cy] = b.center;
  const gl = p.drawingContext;
  const hadDepth = gl.isEnabled(gl.DEPTH_TEST);
  p.push();
  p.noLights();
  // These are overlays: retain visibility through the model without changing it.
  gl.disable(gl.DEPTH_TEST);
  const plane = (points, rgb) => {
    p.fill(...rgb, 16);
    p.stroke(...rgb, 210);
    p.strokeWeight(1.2);
    p.beginShape();
    points.forEach((v) => p.vertex(...v));
    p.endShape(p.CLOSE);
  };
  const horizontal = (z, rgb) =>
    plane(
      [
        [cx - width / 2, cy - depth / 2, z],
        [cx + width / 2, cy - depth / 2, z],
        [cx + width / 2, cy + depth / 2, z],
        [cx - width / 2, cy + depth / 2, z],
      ],
      rgb,
    );
  // Crop operations use percentages of height measured from world Z=0.
  // Do not add the bounding-box minimum: that would misrepresent the cut.
  horizontal((form.Z1 / 100) * b.objectHeight, [0, 145, 180]);
  horizontal((form.Z2 / 100) * b.objectHeight, [165, 100, 38]);
  const { origin, direction } = twistAxis(form.S1, form.S2);
  const length = Math.hypot(...direction);
  const n = direction.map((v) => v / length);
  // Centre the visible portion of the infinite axis near the model.
  const t = b.center.reduce((sum, v, i) => sum + (v - origin[i]) * n[i], 0);
  const radius = Math.max(...b.size, 10) * 0.8;
  const point = (distance) => origin.map((v, i) => v + n[i] * distance);
  p.stroke(131, 66, 191, 240);
  p.strokeWeight(2);
  p.line(...point(t - radius), ...point(t + radius));
  p.strokeWeight(5);
  p.point(...origin);
  p.point(...point(t + radius));
  const operation = $("operation").value;
  if (operation === "mirror" || operation === "quattro") {
    plane(
      [
        [0, cy - depth / 2, b.min[2]],
        [0, cy + depth / 2, b.min[2]],
        [0, cy + depth / 2, b.max[2]],
        [0, cy - depth / 2, b.max[2]],
      ],
      [190, 80, 145],
    );
    if (operation === "quattro")
      plane(
        [
          [cx - width / 2, 0, b.min[2]],
          [cx + width / 2, 0, b.min[2]],
          [cx + width / 2, 0, b.max[2]],
          [cx - width / 2, 0, b.max[2]],
        ],
        [190, 80, 145],
      );
  }
  if (range) {
    p.noFill();
    p.stroke(238, 86, 47, 170);
    p.strokeWeight(1);
    p.push();
    const low = (range[0] / 100) * b.objectHeight,
      high = (range[1] / 100) * b.objectHeight;
    p.translate(cx, cy, (low + high) / 2);
    p.box(b.size[0] * 1.03, b.size[1] * 1.03, high - low);
    p.pop();
  }
  if (hadDepth) gl.enable(gl.DEPTH_TEST);
  p.pop();
}

new p5((p) => {
  app = p;
  p.setup = () => {
    const container = $("canvas-container");
    p.setAttributes("antialias", true);
    const canvas = p.createCanvas(
      container.clientWidth,
      container.clientHeight,
      p.WEBGL,
    );
    canvas.parent(container);
    p.pixelDensity(Math.min(devicePixelRatio, 2));
    p.noiseSeed(2012);
    p.frameRate(30);
    p.perspective(Math.PI / 3, p.width / p.height, 1, 100000);
    canvas.elt.addEventListener("wheel", (e) => e.preventDefault(), {
      passive: false,
    });
    restoreStage().then((restored) => {
      if (!restored) $("load-sample").click();
    });
  };
  p.draw = () => {
    p.background(230);
    if (!mesh || !geometry) return;
    p.orbitControl(1, 1, 0.7);
    const b = cachedBounds;
    p.push();
    p.scale(viewScale);
    p.rotateX(Math.PI / 2);
    p.translate(-b.center[0], -b.center[1], -b.center[2]);
    if ($("lights").checked) {
      p.ambientLight(160);
      p.directionalLight(95, 95, 95, 0.5, 0.8, -1);
      p.directionalLight(50, 50, 50, -0.7, -0.3, 0.5);
    }
    p.noStroke();
    p.model(geometry);
    if ($("edges").checked) {
      p.noLights();
      p.stroke(70, 70, 70, 100);
      p.strokeWeight(0.7);
      p.beginShape(p.LINES);
      for (const [a, b] of cachedEdges) {
        p.vertex(...a);
        p.vertex(...b);
      }
      p.endShape();
    }
    if (tool === "coformer" && $("guides").checked) {
      drawGuides(p, b);
    }
    p.pop();
  };
  p.windowResized = () => {
    const c = $("canvas-container");
    p.resizeCanvas(c.clientWidth, c.clientHeight);
    fit();
  };
  p.keyPressed = () => {
    if (
      ["INPUT", "SELECT", "TEXTAREA"].includes(document.activeElement.tagName)
    )
      return;
    const key = p.key.toLowerCase();
    if (key === "z") $("undo").click();
    if (key === "s") $("stl").click();
    if (key === "d") $("vrml").click();
    if (key === "a") $("png").click();
    if (key === "o") $("open").click();
    if (key === ".") fit();
    if (key === "l") {
      $("edges").checked = !$("edges").checked;
    }
    if (key === "g" && tool === "coformer") {
      $("guides").checked = !$("guides").checked;
      $("guides").dispatchEvent(new Event("change"));
    }
    if (key === "enter" && tool === "coformer") $("apply").click();
  };
});
// Read-only diagnostics for local regression tests and troubleshooting.
window.digitalNatives = {
  get mesh() {
    return mesh;
  },
  get state() {
    return { tool, params, form, algorithm, seed, range };
  },
  get ready() {
    return !!geometry;
  },
};
