# Porting ccc and co_former

## Source of truth

The preserved source is Matthew Plummer-Fernandez's working `P22/ccc` and `P22/fff` folders, copied on 26 October 2026. Both identify their lineage as initiated in 2012 and updated in 2016; the folders also contain later outputs. This is a restoration of these working versions, not a claim to reconstruct the precise 2012 release.

The bundled HE_Mesh identifies itself as **1.81** (`version = 9` in library.properties), not the 2019 release. The original Java code, ControlP5, toxiclibs and HE_Mesh are retained locally. The legacy JARs and reference documentation are deliberately git-ignored; the browser does not load or redistribute them.

## Architecture

- `src/colors.js`: direct translation of all 36 numbered cases (0–35) in `ccc/algocolor.pde`. Original algorithm names and P1–P8 parameters are retained. `fff` uses case 2, its original gradient formula.
- `src/math.js`: vector operations, colour conversion and seeded random generator.
- `src/mesh.js`: indexed polygon mesh, derived edge adjacency/boundaries, face centres/normals/areas, clipping, subdivision and file formats.
- `src/operations.js`: co_former formula translations and reconstructions of the HE_Mesh operations they call.
- `src/app.js`: two interfaces on the same geometry layer; p5.js WebGL display, file inputs, history and sessions.
- `vendor/p5.min.js`: unmodified, pinned p5.js 1.11.11; no network requests are needed at runtime.

This is a project-specific JavaScript implementation, not a complete HE_Mesh port and not a fork of the unrelated 2019 source tree. HE_Mesh's historical contribution remains credited.

## Working features

Both tools open binary/ASCII STL, OBJ, GLB and glTF; display and orbit a mesh; append another model; save geometry as OBJ, full face colours as VRML, or Materialise-colour binary STL; save a PNG; undo/redo up to 15 edits; and save/reopen a complete JSON session. Original ccc `notes.txt` parameters can be opened, and new compatible colour notes exported. Models and files remain local.

ccc includes all 36 colour modes, contrast, saturation, brighten-brights, hue shifts, colour pair/neighbour and planar subdivision. Its original eight numeric parameter names remain available.

co_former includes the active named transformations: wave, cavity, wide base, natives patch, cup2, scaleZExpo, toastieStretch, flip, mirror, quattro, fatslab, printerHeadSlip, scaleSelection, spikes, perlin and perlinForward2. It also includes Z-region selection, top/base crop, twist, sine twist, smooth, planar/Catmull–Clark/fractal subdivision, cup, bellbase, trumpet, axis movement/rotation/scaling and uniform scaling. Selection is based on face centres and collects their vertices, as in the original.

## Fidelity and deliberate changes

This release is functional, but **has not been validated as bit-for-bit or image-for-image identical to a running Processing 2.2 / HE_Mesh 1.81 installation**. No Java runtime was available in the working environment. The original files are preserved for that comparison.

1. **Colour formulas:** translated from the source, not visually approximated. Randomness uses a reproducible JavaScript generator and p5 noise rather than Processing's random state. Mesh face iteration order can differ. Stochastic patterns therefore differ, even with the same nominal seed. HSB conversion/rounding can also differ at channel boundaries.
2. **Integer division and odd rotations:** `cup2` retains `S1/100` integer division; the old `cup` retains `81/100 = 0`; twist-axis integer divisions and sine-twist integer Z1 division are preserved. `flip` retains the source's 180-radian rotation and 1.7 scaling. These effects have not silently been changed to more conventional formulas.
3. **Geometry engine:** JavaScript indexed polygons and derived edge adjacency replace HE_Mesh halfedges. Plane cuts are uncapped, as the original requested. Mirror/quattro weld shared seams and maintain face winding. Quattro omits the source's apparent extra duplicate polygon-soup copy. Printer slip constructs the intended one-unit bridge; it does not reproduce the old duplicate-vertex bookkeeping or global face reversal.
4. **Subdivision and smoothing:** planar and Catmull–Clark use their standard constructions. Region planar subdivision splits adjacent edges to avoid T-junctions. Smooth uses a self-plus-neighbours Laplacian average. These are reconstructed operations, not verified translations of the HE_Mesh 1.81 implementations. Fractal subdivision is a deterministic two-pass, height-weighted Catmull–Clark interpretation; the old loop's sequential face mutation/order dependence is not reproduced.
5. **Spikes:** reconstructed as face-centre apices displaced by normal and relative face area. It expresses the original `chamfer(1)` extrusion intent, but exact HE_Mesh extrusion equivalence remains to be checked.
6. **Selections and UI:** Z1/Z2 select a height region; selected vertices are used by the deformation tools. Whole-mesh operations (mirror, cavity, spikes, Catmull–Clark etc.) retain their whole-mesh scope. The unused X/Y selection sliders were removed; explicit axis scale buttons use S1 instead of the old scaling-mode sliders. The selected height region is shown in orange. Empty menu slots were removed; the old `six` fall-through duplicated fatslab and has no separate entry.
7. **Colour refresh:** browser recolouring recomputes dimensions and maximum face area. The old sketch cached some of those values at construction. This avoids stale colour scaling after edits but changes colours for those edited meshes. Colour-pair and neighbour use the first neighbour in the new adjacency order.
8. **Exports:** colour STL follows Materialise's 5-bit-per-channel convention, with standard consistent winding; VRML retains full RGB face colour in current model coordinates. The original save shortcuts rotated/flipped the mesh before VRML export; this port does not. OBJ exports geometry only. All polygons are triangulated for STL. The old exporter silently used only three vertices of each face.
9. **History and safety:** multi-step undo replaces the single-copy undo; operations producing empty/non-finite geometry roll back. Subdivision/import limits protect the browser. A saved session preserves mesh, colours, parameters, seed and original reset state; camera position and undo history are not saved.
10. **Experimental OBJ colour blending:** vertex RGB import is supported, but the original hard-coded vertex-key-offset blending methods (`setColors2` / `setColors3`) are not reproduced. Imported colours can be restored explicitly in ccc after resetting the mesh. OBJ materials, textures, and MTL files are not supported.

## Verification

Run `node --test tests/*.test.js` for mesh, colour, import/export and transformation checks. They include original vase input, classic gradient known values, source wave equation, input immutability, plane intersections, symmetry, boundary topology, STL colour round-trip and all active transformations.

`tests/browser.mjs` exercises the actual p5/WebGL interface: all colour modes, transformations, selection, undo/redo, import, exports, and session restoration. It requires Playwright and a Chrome/Chromium executable; see README.

Next archival validation: run the original Java sketches, use identical imported meshes and settings, compare deterministic vertex coordinates and colours, then review stochastic and topology effects visually with the artist. Saved original screenshots alone do not identify every input mesh and operation sequence.

## Stage 2

The tools are integrated into the local MPFWebsite checkout at `/works/digital-natives/tools/`, linked from the existing artwork page. See DEPLOYMENT.md for synchronisation and publication instructions.

## Contextual controls and stage workflow

Parameter labels now describe each algorithm's actual formulas, while retaining P1–P8 in files and in small labels. Controls unused by the selected colour algorithm are disabled without discarding their values. Form labels follow the selected transformation or the last tool action. No formula or numeric range was changed by this interface update.

co_former is stage 1 and the default landing view; ccc is stage 2. Continue to colouring copies the current indexed mesh and face colours exactly into ccc. Its reset model becomes that transferred mesh. IndexedDB stores the two drafts under a workspace identifier scoped to this browser tab. Switching stage tabs preserves separate drafts; a new explicit transfer replaces the previous colouring draft. There is no upload, STL round-trip, welding or automatic recolouring during transfer. Undo history and camera position are not transferred. Downloaded sessions remain the durable save option.

## GLB / glTF exports

Both use glTF 2.0 with a single mesh, scene and non-metallic rough material. Triangle vertices are duplicated to preserve flat face colour and normals. RGB colours are converted from sRGB to glTF's linear COLOR_0 values. Coordinates and normals rotate from Z-up to Y-up (x,z,-y); user-selected source units convert coordinates to metres. No mesh mutation, centring, resizing-to-fit or geometry repair is applied. The double-sided material keeps intentionally open/cropped surfaces visible. GLB contains JSON and binary chunks; .gltf embeds the binary buffer as a data URI, so either download is self-contained. Legacy STL remains available.

Exports from both the exporter functions and real browser buttons passed Khronos glTF Validator 2.0.0-dev.3.10 with zero errors and warnings. Both formats also loaded through Three.js GLTFLoader 0.180.0; vertex count, linear colour values, upright orientation, scale and source immutability were checked. The validator remains a test tool. Three.js GLTFLoader 0.180.0 is now also bundled for import, loaded on demand.

## GLB / glTF imports

GLB, embedded glTF and glTF with selected local binary companions are supported. Default-scene geometry is combined, node and instance transforms applied, and the initial pose of skinned/morph meshes baked into a static mesh. Coordinates convert from Y-up metres to Z-up selected model units. Negative transforms reverse triangle winding. Coincident vertices are welded for the editing engine. Vertex colours are averaged per triangle in linear space, multiplied by material/instance colour and converted to sRGB. These imported colours are displayed immediately without applying a colouring algorithm.

Texture maps and UVs are omitted; animations, transparency and advanced surface effects are not retained. Unsupported required extensions and Draco/Meshopt compression receive explicit errors. The UI reports relevant simplifications. External buffers must be selected locally; the loader cannot fetch remote model dependencies.

Regression checks cover colour/scale/orientation round trips, welding, transforms, material colours, missing buffers, omitted textures and malformed/compressed input. Actual browser checks passed in both the standalone and website copies: file selection, stage transfer, GLB export/reimport, companion buffers and preservation of the existing model when import fails.
