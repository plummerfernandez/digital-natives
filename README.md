# Digital Natives — ccc & co_former

A working browser restoration of Matthew Plummer-Fernandez's Processing tools, initiated in 2012. **ccc** explores algorithmic face colour; **co_former**, previously named **fff**, deforms and reconstructs meshes.

The source of this restoration is the working P22 archive with HE_Mesh **1.81**. Original sketches are preserved in `archive/processing/`. The browser version runs on p5.js and a small shared JavaScript geometry engine; it is not a complete port of HE_Mesh.

## Run locally

Double-click **Start Digital Natives.command** on this Mac. It opens the app in your browser; keep its terminal window open while working and press Control-C there to stop it.

Alternatively, with Node.js 20 or later installed:

```sh
node server.js
```

Open http://localhost:8080 . Start in **co_former** (1 · form), then move to **ccc** (2 · colour). No build step, Java, Processing installation, package installation or internet connection is needed to use the app. Do not simply double-click index.html: browser security requires a local web server for modules and sample files.

If port 8080 is already in use, run `PORT=8081 node server.js` and visit http://localhost:8081 . The server listens only on the local machine and does not serve the archive directory.

## Working with the tools

- Start with the original vase or box, or open your own STL / OBJ / GLB / glTF. Appending adds another model in its original coordinates.
- Drag to orbit, scroll to zoom, Shift-drag to pan; **Fit view** restores the camera.
- In **ccc**, choose one of the original 36 colour algorithms and adjust P1–P8. Labels change with the algorithm (RGB, hue/saturation, noise, etc.); the original P numbers remain underneath. Unused parameters are greyed out. Colour changes are immediate. **New variation** changes the random seed. **Imported colours** restores the original file colours when topology is unchanged.
- In **co_former**, pick a transformation, adjust S1/S2 and click **Apply**. Z1/Z2 set the region for **Select Z region** and the crop planes. Live crop planes follow Z1 (blue) and Z2 (brown). The purple twist axis follows S1 (tilt) and S2 (offset). **Guides** at the bottom of the viewport toggles these overlays independently of mesh edges; press `g` for the same toggle. Mirror/quattro also show their cutting planes. Selected regions are shown in orange. Deformation, cutting and subdivision have undo/redo.
- **GLB · colour model** is the recommended single-file export for modern 3D viewers. **glTF · colour model** provides a self-contained JSON alternative. Both preserve flat face colours and convert the Z-up model to Y-up. Choose the source model units (millimetres by default) to set physical scale correctly. Viewer lighting may differ from the editor.
- **Colour STL** keeps the historical Materialise colour convention (support varies between viewers). **Colour VRML** preserves full face RGB. **OBJ geometry** exports geometry without colour.
- **Save session** stores the full working mesh and settings. Reopen it to continue. Use **Continue to colouring →** to send the current co_former mesh directly into ccc, preserving geometry and colours without exporting a file. This starts a new colouring stage from that mesh, replacing any previous colouring draft in this tab. The two stage tabs keep separate working drafts locally when you switch between them. Save a session before closing the browser; stage drafts are a convenience, not a backup.
- Original `ccc/screenshots/*notes.txt` files can be loaded through **Open session / notes**. They restore colour settings; they do not contain geometry.
- Keyboard shortcuts outside input fields: `s` STL, `d` VRML, `a` screenshot, `o` open, `z` undo, `l` edges, `.` fit view, Enter apply co_former operation.

Files are processed locally; nothing is uploaded. Imports and subdivisions are limited to 200,000 faces. Crops/cavity can intentionally leave holes, so an exported mesh is not automatically print-ready.

## Fidelity

All colour algorithms and the active deformation formulas have been ported. Mesh operations formerly supplied by HE_Mesh have been reconstructed. This is **a functional first browser restoration, not certified exact parity** with the old Java runtime. See [porting notes](docs/PORTING.md) for deliberate fixes, experimental features and differences—including stochastic patterns, fractal subdivision and export orientation.

## Tests

```sh
node --test tests/*.test.js
```

Browser regression tests require Playwright (`npm install --no-save playwright`) and Chrome/Chromium. Start the server, then run:

```sh
node tests/browser.mjs
node tests/workflow.mjs
```

Set `CHROME_PATH` or `PLAYWRIGHT_MODULE` if they are installed in a nonstandard location. The browser tests write evidence into git-ignored `test-results/`.

## Repository and credits

The project is ready to add as a local repository in GitHub Desktop. Nothing has been published. `archive/local-libraries/` holds the copied legacy dependencies locally and is git-ignored. `docs/source-manifest.json` records the source files and SHA-256 checksums.

The code is released under **MIT** and the vase/box sample models under **CC BY 4.0**. Historical notices remain in the preserved Processing source; the current grant and third-party exclusions are explained in [licensing and credits](docs/LICENSING.md). p5.js is distributed with its own licence. HE_Mesh is by Frederik Vanhoutte; the original sketches also used toxiclibs and ControlP5.

## Website release

The website copy lives at `MPFWebsite/works/digital-natives/tools/`, linked from the existing project page. To update the copied browser app and downloadable source archive after edits:

```sh
python3 scripts/sync-website.py ../MPFWebsite
```

The sync copies only the browser runtime, sample models, documentation and licences; no Java binaries, private files or repository metadata. The generated source ZIP also includes the app tests and the redistributable Processing reference files. Changes are local until the website repository is published. See `docs/DEPLOYMENT.md`.

### GLB / glTF import

Open one model, selecting any companion `.bin` files together with a `.gltf`. Embedded GLB and glTF files also work. The importer combines scene meshes, applies node/instance transforms and converts glTF metres to the selected model units (millimetres by default). Imported base colours and vertex colours are retained as one RGB colour per triangle (vertex colours are averaged in linear space). Coincident vertices are welded for mesh operations.

Textures/UVs, transparency and advanced material effects are not retained. Animation is imported as a static initial pose. Cameras, lights, lines and points are not editable mesh content. Draco/Meshopt compression and unsupported required extensions produce an explanatory error: re-export an uncompressed GLB. Limits: 100 MB of selected model data and 200,000 triangles. Model dependencies are resolved only from selected local files or embedded data; no remote model URLs are fetched.

The importer uses Three.js 0.180.0 (MIT), loaded only when opening a glTF. See `vendor/three/LICENSE`.
