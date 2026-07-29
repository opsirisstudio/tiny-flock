# Sheep Blender Work — Progress Log

Append-only. Newest entry at the bottom. Read this file, and
`docs/verification/sheep_modularity_feasibility_study.md`, before doing
anything else in a new session — do not assume prior claims are still true;
re-verify via script.

---

## 2026-07-29 — Session 1: Modularity feasibility study + one experiment

**Environment (re-verify each session, do not assume):**
- Blender: `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe` — Blender 5.2.0 LTS. Not on PATH; use the full path or re-locate with `Get-ChildItem "C:\Program Files\Blender Foundation" -Recurse -Filter blender.exe`.
- No Godot editor/CLI binary was found on this machine (checked common install locations, `Get-Command godot`, and Downloads). Godot-side verification could not be automated. Re-check in future sessions in case Godot gets installed.
- This session ran via Desktop Commander (real Windows shell) because the sandboxed Linux bash tool failed to start (disk space). The file tools (Read/Write/Edit) and Desktop Commander share the same real filesystem — paths under `C:\Users\creol\...` are real, not sandboxed.
- Blender 5.2 changed the Action data API: `action.fcurves` no longer exists directly; fcurves now live behind `action.layers[].strips[].channelbags[].fcurves` ("slotted actions"). All scripts in `blender/sheep/tools/` already handle this with a fallback helper (`get_action_fcurves`). If you hit `AttributeError: 'Action' object has no attribute 'fcurves'` in a new script, copy that pattern.
- `Material.use_nodes` and `World.use_nodes` throw a `DeprecationWarning` in 5.2 (removal planned for 6.0) but still work. Harmless, just noisy in stdout.

**What exists on disk after this session:**
- `godot/assets/models/sheep/base/sheep_-_animated_low_poly.glb` — **PRODUCTION, UNTOUCHED**. Verified byte-identical size and modified-timestamp before and after the whole session.
- `blender/sheep/tiny_flock_sheep_working.blend` — protected working copy. Fresh GLB import into an empty scene, saved once (Phase 1), never resaved since. This is the file to open (read-only, then `save_as` to a new name) for any future exploratory work — do not resave to this path except in a deliberate "update the working copy" step.
- `blender/sheep/tiny_flock_sheep_modularity_test.blend` — the ONE experiment performed: `Object_9` (single mesh) separated into `Wool_Test` (500 verts) + `FaceLegPoints_Test` (373 verts) along the pre-existing, 100%-clean vertex-color island boundary, each given an obviously-fake test material (neon green / hot magenta). Rig and all 14 animations verified intact on both resulting objects.
- `blender/sheep/tiny_flock_sheep_modularity_test.glb` — exported from the test file (Y-up, skins, all NLA animations, materials). Re-imported into a clean Blender scene as a round-trip sanity check: passed (2 meshes, 1 armature/32 bones, 14 actions, 2 materials all present).
- `godot/assets/models/sheep/_modularity_test/tiny_flock_sheep_modularity_test.glb` — copy of the above placed in the Godot project for **manual** verification (opening the actual editor) since no Godot binary was available here. Production sheep folder (`.../sheep/base/`) untouched.
- `blender/sheep/renders/` — `original_idle_f1.png` (lit, original single-material sheep), `original_flat_vertexcolor_v2.png` (flat/shadeless raw vertex-color pass — the ground-truth reference for the wool/points pattern), `test_split_idle_f1.png` (lit, post-split, neon test colors), `regression/regression_<action>_f<frame>.png` × 14 (one representative frame per animation on the split file, all passed numerical + visual spot-check).
- `blender/sheep/tools/` — reusable headless scripts, safe to rerun as-is against the *current* working/test files (they take file paths as CLI args, they don't hardcode session-specific stuff beyond object names `Object_9`/`Object_6`/`Icosphere` from the source GLB, which are stable since they come from the untouched source file):
  - `phase1_import.py <src_glb> <out_blend>` — fresh import + save.
  - `phase2_audit.py <working_blend>` — full mesh/armature/animation/material/transform audit, prints `PHASE2_RESULT_JSON=`.
  - `phase3_construction.py <working_blend>` — bmesh island detection + vertex color inspection + material node graph dump + Icosphere/Object_8 investigation, prints `PHASE3_RESULT_JSON=`.
  - `phase3b_island_color.py <working_blend>` — classifies every island as pure-wool/pure-point/mixed by vertex-color luminance, prints `PHASE3B_RESULT_JSON=`. (Result was 15 pure-wool / 37 pure-point / **0 mixed**.)
  - `phase5_modularity_test.py <working_blend> <out_test_blend>` — performs the actual separation + test materials + save-as. This is the experiment.
  - `phase7_regression.py <test_blend> <render_dir>` — samples all actions for NaN/exploding values, renders one frame per action.
  - `phase8_export.py <test_blend> <out_glb>` — Godot-4-appropriate glTF export.
  - `phase8b_verify_export.py <test_glb>` — re-imports a GLB fresh into an empty scene to sanity-check counts.
  - `render_still.py <working_blend> <out_png> <frame> [action_name]` — generic framed still render for the **unsplit** file (single object `Object_9`).
  - `render_flat_vcol.py <working_blend> <out_png>` — Workbench flat/shadeless raw-vertex-color render, for distinguishing real paint from lighting artifacts.
  - Note: there's also a `render_test_still.py` variant used mid-session for the **split** file (frames both `Wool_Test`+`FaceLegPoints_Test`) that was NOT copied into `tools/` — if you need it again, it's identical to `render_still.py` except it loops over all non-Icosphere mesh objects for the bounding-box calc instead of assuming a single `Object_9`. Trivial to recreate if needed.

**Key findings (see full report for detail/reasoning):**
1. Source mesh is 872 verts / 1032 tris, ONE object, ONE material, no image textures — all color comes from a per-corner vertex color attribute named `Color`, multiplied by a flat grey constant in the shader.
2. Mesh is NOT one continuous surface — 52 disconnected geometry islands (chunky low-poly "puff" construction).
3. Every single island is either 100% light (wool) or 100% dark (points) colored — **zero mixed islands**. This is why the separation experiment was safe and clean.
4. Armature: 32 bones, hub-and-spoke (most limb/body bones parent directly to `center_ctrl_04` in parallel, NOT to each other) except the head sub-hierarchy (`eye_L/R`, `mouth`, `ear_L/R` properly child `head_014`). This is unusual but the existing 14 animations all still work fine — the risk this creates is for FUTURE proportion-editing genetics (leg length especially), not for anything done in this study.
5. An unparented, unmaterialed `Icosphere` object (~2m, centered on the sheep) exists in the source file, outside the real Sketchfab hierarchy. Inert cruft, left untouched. Worth a cleanup pass someday, not touched this session.
6. Mesh separation (Wool vs FaceLegPoints) + independent test materials: proven safe. Rig (32 vertex groups + Armature modifier) intact on both halves. All 14 animations regression-tested (NaN/explode check + representative-frame render) with zero problems.
7. Godot round-trip: GLB-level round-trip through Blender's own importer confirmed clean. Actual Godot-editor-level verification NOT done (no Godot binary on this machine) — flagged as needing manual check.

**Verdict**: GOOD BASE WITH MODIFICATIONS (leaning EXCELLENT for color/pattern genetics specifically). Full 25-locus genome mapping, shorn-sheep recommendation, modular art roadmap, and performance assessment are all written up in `docs/verification/sheep_modularity_feasibility_study.md`.

**Recommended next step** (see report Section 16 for full reasoning): build a shader-parameter-driven material system on the test split file — per-instance shader parameters for Wool Color / Point Color rather than per-sheep unique materials — and wire up 2 real loci (WBC + PNT) end to end as a proof of the actual genetics-to-art pipeline, re-running the same animation-regression check afterward.

**Not done / explicitly out of scope this session** (per the brief): no genetics implementation, no AI/movement/husbandry code, no production horns/markings/lambs/elders, no armature rebuild, no shorn-sheep production system, no shader system beyond the test materials described above. If a future session is asked to do any of these, that's new work, not a continuation of this one.
