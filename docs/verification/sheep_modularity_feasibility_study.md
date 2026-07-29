# Tiny Flock Sheep — Modularity Feasibility Study

Date: 2026-07-29
Scope: feasibility study + one controlled modularity experiment, per the assignment brief. No production changes were made. No genetics, AI, or gameplay code was touched.

## 1. Verdict

**GOOD BASE WITH MODIFICATIONS**, leaning toward **EXCELLENT BASE** for color/pattern genetics specifically.

The existing sheep can become the modular base for Tiny Flock's genetics system. The single biggest finding: **the model's color pattern is already baked as vertex colors on a single mesh, and that vertex-color boundary is 100% clean against the mesh's 52 disconnected geometry islands** — every island is either purely "wool" (light) or purely "point" (dark), with zero mixed islands. This means the wool/points split the genome design needs was, in effect, already latent in the source asset. A controlled experiment (Phase 5) separated the mesh along exactly that boundary, assigned independent test materials, and confirmed rigging and all 14 animations survive intact.

The one real weakness is the armature: it is not a conventional anatomical FK chain. Most limb/body bones parent directly to a central hub bone (`center_ctrl_04`) rather than to anatomically adjacent bones. This doesn't threaten the existing animations (they still play perfectly), but it makes certain future proportion-based genetics (leg length, build) more work than they'd be on a standard rig, because sibling bones don't cascade position changes to each other.

## 2. Blender asset audit (from scripts, not assumptions)

Full detail: see `blender/sheep/tools/phase2_audit.py` output and `PROGRESS_LOG.md`. Headline facts, all verified against the working file, not the brief's hypothesis:

- **Mesh**: one object (`Object_9` in the source import), 872 vertices, 1032 triangles, one UV map, one color attribute (`Color`, per-corner byte color), zero shape keys, one modifier (Armature). No image textures anywhere in the file — all surface color comes from the vertex color attribute.
- **Material**: one material (`Animal_3081_Textured`), node graph is `Color Attribute → Mix (Multiply) → Base Color → Principled BSDF`. The vertex color is multiplied by a flat (0.8, 0.8, 0.8) constant and used directly as base color. No PBR texture maps at all — this is a fully vertex-color-driven shading model.
- **Armature**: 32 bones, all `use_deform = True` (no separate control-bone layer). Hierarchy is a hub-and-spoke: `_rootJoint → Armature_01 → root_02 → all_ctrl_03 → center_ctrl_04`, and from `center_ctrl_04` nearly every limb/body bone (pelvis, tail, spine, chest, neck, head, both arms, both legs) branches directly, in parallel, rather than chaining anatomically (e.g. `foot` does not parent to `leg`, `leg` does not parent to `thigh`). The **head** sub-hierarchy is the one anatomical exception: `eye_L`, `eye_R`, `mouth`, `ear_L`, `ear_R` are proper children of `head_014`. Vertex groups exactly match all 32 bone names — standard skinning, no orphaned groups.
- **Animation**: 14 actions confirmed present and named exactly as expected (`bush_hide, eat, idle, jump, jump_1..4, look, run, shake, sleep, trot, walk`), each also pushed down to its own NLA track. FPS 24. 23–30 of the 32 bones are animated per clip (the un-animated ones are the static hub bones). Blender 5.2's new "slotted actions" API (fcurves moved behind `layers/strips/channelbags`) required a small compatibility shim in the audit script — noted here in case a future session hits the same `AttributeError: 'Action' object has no attribute 'fcurves'`.
- **Transforms**: mesh and armature both sit at identity location/rotation/scale. Bind-pose mesh dimensions ≈ 0.66 × 1.41 × 1.04 m, reasonably close to the previously-reported Godot-side dimensions (0.67 × 1.12 × 1.37 m) once axis remapping between glTF/Blender/Godot is accounted for; the small remaining differences are consistent with bind-pose vs. reported pose rather than any asset drift.
- **Unexpected object**: an unparented `Icosphere` mesh (42 verts, no material, no vertex groups, ~2 m across, centered on the sheep, visible in both viewport and render) exists in the source GLB. It is **not** part of the Sketchfab import hierarchy (every real sheep part traces back to `Sketchfab_model`; the Icosphere sits outside that chain entirely) and has no animation, weights, or material. It reads as inert leftover cruft, not a functional part of the asset. It was left untouched everywhere in this study (hidden only transiently during renders) — flagging it here as a candidate for cleanup in a future production pass, not touching it now per the non-destructive rule.

## 3. How the sheep is actually built

The mesh is **not** one continuous surface — it's 52 disconnected geometry islands (a "puff of blobs" construction typical of stylized low-poly fur), ranging from two large multi-bone-weighted torso/head blobs (201 and 146 verts) down to many small single-digit-vertex accent islands (ear tips, hoof caps, an eye highlight, etc.).

Cross-referencing every island against the vertex-color pattern (Phase 3b) gave an unambiguous result:

| | count |
|---|---|
| Pure-wool islands (light) | 15 |
| Pure-point islands (dark) | 37 |
| Mixed islands | **0** |

No island straddles the wool/point color boundary. This is classification **D** from the brief's Phase 3 options (already differentiated through vertex data) *and* it turns out **A** (separate mesh islands) is also trivially available, because the geometry was never welded across that boundary to begin with.

Visual confirmation: a flat, shadeless render of the raw vertex colors (Workbench, no lighting) shows a clean cream/white wool body with a grey-brown face patch (with a dark pupil) and dark hooves — classic "points" marking, nothing painted onto the haunch. A separate lit Cycles render *does* show a dark patch near the haunch, but that is a lighting/self-shadow artifact from the overlapping puffy wool islands under directional light, not a vertex-color marking — confirmed by comparing the two render modes side by side. Worth knowing about for future lighting setups but not a modularity concern.

## 4. Wool separation result

**Feasible, and executed.** Because the wool/point color boundary maps exactly onto the pre-existing island boundary, `Wool` and `FaceLegPoints` were split into two real mesh objects with zero geometry cutting, zero vertex duplication beyond the expected split (499 + 373 = 872, exactly the original count), and zero risk of bleeding one region's color into the other.

This was Option A from the brief (separate mesh object), chosen over Option B (material-only split) because it was proven safe and it additionally unlocks geometry-level features B can't provide — most importantly, independent wool visibility/scale for the shorn-sheep system (Section 9).

## 5. Body/point material result

**Confirmed.** After separation, each object was assigned an obviously-artificial, independently-controlled test material: `Material_Wool_Test` (neon green) and `Material_Points_Test` (hot magenta). Rendered side by side against the original, the split is exact and clean — no bleed, no missing faces, no color leaking across the boundary. See `blender/sheep/renders/test_split_idle_f1.png` vs. `original_idle_f1.png`.

For production, a shader-driven approach (existing vertex color, or a plain per-object color uniform, feeding two independently-exposed "Wool Color" and "Point Color" parameters) is recommended over hard-coded per-sheep material duplication — see Section 10 and Section 13.

## 6. Rig preservation result

Both post-split objects retain:
- All 32 original vertex groups, by name, with weights untouched (verified programmatically, not just "group exists").
- The Armature modifier, correctly configured, on both objects.
- No change whatsoever to the armature itself — bones, hierarchy, and rest pose are bit-for-bit what they were after Phase 1 import.

## 7. Animation regression result (all 14 clips)

All 14 actions were replayed on the split test file. For each clip, bone pose-matrix translations and evaluated mesh vertex world positions were sampled at the start, middle, and end frame and checked for NaN/Inf or "exploding" values (>24 m from origin, a generous multiple of the sheep's own ~1.2 m scale).

**Result: 14/14 PASS, zero problems detected.**

A representative frame from every clip was also rendered (`blender/sheep/renders/regression/`); spot-checked `walk`, `jump`, `sleep`, and `shake` visually — deformation stays fully cohesive between the Wool and FaceLegPoints objects across dramatic poses (curled sleep pose, mid-air jump tuck, open-mouth shake), with no detachment, no lag between the two objects, no exploded geometry.

## 8. Godot round-trip result

A Godot project exists at `godot/` (Godot 4.7, `gl_compatibility` renderer per `project.godot`), and the production sheep's existing `.import` file was inspected for reference (standard scene importer, skins/animation/materials all default-enabled, `animation/fps=30` note: source clips are authored at 24 fps and get retimed to the project's 30 fps import setting — pre-existing behavior, unrelated to this experiment).

**No Godot editor/CLI binary was found on this machine**, so the actual in-editor import step could not be automated or verified here. What *was* done:
- The test GLB was exported with Godot-4-appropriate glTF settings (Y-up, skinning on, all NLA-track animations baked and exported, materials exported) and **re-imported fresh into a clean Blender scene** as an independent sanity check: 2 mesh objects (500 + 373 verts, matching the split), 1 armature (32 bones), 14 actions, and both test materials all round-tripped correctly through the GLB format itself.
- The test GLB was placed at `godot/assets/models/sheep/_modularity_test/tiny_flock_sheep_modularity_test.glb` — a clearly separate, non-production location. The production `sheep_-_animated_low_poly.glb` was never touched.

**What still needs manual verification** (requires opening the actual Godot editor, which this session could not do): confirming the editor's own import inspector shows 2 separate mesh surfaces with independently assignable materials, confirming the Skeleton3D and AnimationPlayer come through with all 14 clips playable, and eyeballing the two neon test colors in the 3D viewport. Given the file round-tripped cleanly through Blender's own importer and follows the same glTF structure Godot already successfully imports today, this is expected to just work, but "expected" is not "confirmed."

## 9. Genome visualization matrix (all 25 loci)

Classification is based on the actual verified asset structure above, not assumption. "Object(s)" indicates which of the two now-separable meshes (or the armature) a locus would touch.

| Locus | Effect | Implementation type | Difficulty | New art? | Notes |
|---|---|---|---|---|---|
| PNT | black vs brown points | Material parameter | Tiny | No | Point Color uniform on FaceLegPoints |
| PDL | point dilution | Material parameter | Tiny | No | Lighten/desaturate multiplier on PNT |
| WBC | wool base color | Material parameter | Tiny | No | Wool Color uniform on Wool |
| WDL | wool dilution | Material parameter | Tiny | No | Same mechanism as PDL, on Wool |
| WRM | wool warmth/tone | Material parameter | Small | No | Hue-temperature blend added to WBC |
| GRY | graying (age-dependent) | Material parameter (+ shader noise for a convincing scatter) | Small–Medium | No | Flat lighten = small; scattered graying = medium |
| CRL | curl (tight/wavy/straight) | Shape key | Medium | Yes | Sculpted on Wool object only — safe, isolated |
| FLF | fluffiness (cloud/fluffy/sleek) | Shape key | Medium | Yes | Wool object only; may share an axis with CRL |
| LEN | wool length | Uniform/non-uniform scale of Wool object | Tiny–Small | No | Same mechanism reused for shearing (Sec. 9) |
| PPG | gates PPT expression | N/A (logic-only) | N/A | No | No independent visual |
| PPT | point pattern (mask/blaze/eye_patch/socks) | Vertex color variant (hand-painted, per pattern) | Medium | Yes | Isolated to FaceLegPoints object |
| WPG | gates WPT expression | N/A (logic-only) | N/A | No | No independent visual |
| WPT | wool pattern (patches/speckles/saddle/roan) | Combination: procedural shader (speckles/roan) + authored mask (patches/saddle) | Medium–Large | Partial | Speckle/roan = no new art (noise); patches/saddle = new masks |
| AMT | marking extent (minimal/moderate/extensive) | Material parameter | Small | No | Blend-threshold on whichever PPT/WPT mask is active |
| SIZ | overall size | Uniform scale (armature root) | Tiny | No | Matches the brief's own suggested approach |
| BLD | build (slim/standard/round) | Bone transform (scale) | Small | No (maybe) | Torso bones already multi-weight-blend the big islands; extreme values may want a shape-key touch-up |
| LEG | leg length | Bone transform (scale) | Medium–Large | No | Complicated *specifically* by the hub-and-spoke rig — sibling leg bones don't cascade, so a clean "shorter leg" needs coordinated offsets across thigh/leg/foot/toe, not a single scale |
| FAC | face shape (6 variants) | Shape key, coordinated across 2 objects | Medium–Large | Yes | Face patch lives on FaceLegPoints, surrounding fur on Wool — both need matching shape keys |
| EAR | ear style (upright/side/floppy) | Bone transform (rotation) | Tiny–Small | No | Dedicated `ear_L`/`ear_R` bones already exist |
| ERS | ear size | Bone transform (scale) | Tiny | No | Ears are also already-clean separate islands |
| HRN | horns present (h/h only) | Modular mesh | Medium | Yes | No horn geometry or attachment point exists today |
| HSH | horn shape (tiny/curled/spiral) | Modular mesh (small fixed library) | Medium–Large | Yes | 2–3 authored variants recommended, not continuous blending |
| LAV | lavender tint | Material parameter | Tiny | No | Same mechanism as WRM |
| ROS | rose tint | Material parameter | Tiny | No | Same mechanism as WRM |
| STR | star marking (none/small/large) | Material mask / shader (procedural preferred) | Medium | Mostly No | Procedural forehead shape scales continuously with the incomplete inheritance; needs one authored mask position, not per-size art |

**Summary**: 15 of 25 loci need zero new art (pure material parameters or bone transforms). 2 are logic-only gates with no visual footprint of their own. The remaining 8 (CRL, FLF, PPT, WPT-patches/saddle, FAC, HRN, HSH, STR-if-not-procedural) need some amount of new authored art, and every one of them is now isolated to either the Wool object, the FaceLegPoints object, or a genuinely new modular attachment — none of them require touching the armature's problematic hub bones or the animation data.

## 10. Shorn-sheep recommendation

The game already tracks `wool_growth` as a continuous, clamped `0.0`–`1.0` float (`WoolGrowthService`, per `docs/architecture/wool_growth.md`), with meshes/animations explicitly noted as deferred in that doc. The mesh separation proven in this study is the direct enabler for that visual layer:

**Recommended**: drive a non-uniform scale of the (now-separate) Wool object directly from `wool_growth`, clamped to a small non-zero minimum (e.g. 0.1–0.15) rather than scaling fully to zero, so a freshly-shorn sheep reads as "dramatically smaller and slightly ridiculous" (per the brief's own goal) rather than as a floating, wool-less skeleton. This is continuous (matches the existing float exactly, no banding), requires zero new art, and cannot affect the FaceLegPoints or armature at all since the objects are now independent.

**Optional future polish**: a shape-key blend between "full wool" and "shorn stubble" silhouettes would look more natural than a literal scale-to-small (avoids a slightly balloon-deflating look at low values), but this is a nice-to-have, not a blocker, and can be layered on top of the scale-driven system later without redoing the split.

## 11. Modular art roadmap

| Feature | Blender-authored (new art) needed? | Mechanism |
|---|---|---|
| Horns (absent/small/large/curled) | Yes | New modular mesh(es) + new attachment point on/near `head_014` |
| Ears (floppy/upright/size) | No | Existing dedicated bones, rotation + scale |
| Body build (small/average/chunky) | No (maybe touch-up) | Bone scale on torso bones |
| Legs (short/average/long) | No, but real rigging effort | Coordinated multi-bone scale, complicated by hub rig |
| Face proportion | Yes | Shape keys, coordinated across Wool + FaceLegPoints |
| Wool (smooth/curly/fluffy/short/long) | Length: No. Curl/fluffy: Yes | Length = scale; curl/fluffy = shape keys, isolated to Wool |
| Markings (patches/star/rare) | Partial | Speckle/roan/star = procedural (no art); patches/saddle/discrete PPT types = hand-painted vertex color masks |

## 12. Performance assessment (10 / 25 / 50 sheep)

- **Geometry**: 872 tris per sheep (unchanged total, just now split across 2 objects). 10 sheep ≈ 8.7k tris, 25 ≈ 21.8k, 50 ≈ 43.6k — trivial for any target, including the project's `gl_compatibility` mobile-oriented renderer.
- **Draw calls**: the split takes each sheep from 1 draw call to 2 (Wool + FaceLegPoints), before any modular attachments. Adding horns for the subset of sheep that have them adds a 3rd. At 50 sheep with horns that's up to 150 draw calls for bodies alone — still comfortably fine on desktop, worth keeping an eye on for the `gl_compatibility` mobile path specifically, but not a blocker.
- **Material instancing — the one real watch point**: every sheep needs its own wool/point colors from its own genome. Naively creating a unique `Material` resource per sheep per part (up to 100 unique materials at 50 sheep) would work functionally but wastes memory and can break batching, which matters more under `gl_compatibility`. **Recommendation**: use one shared shader per part (Wool, FaceLegPoints) and drive per-sheep color via Godot 4's per-instance shader parameters (`GeometryInstance3D.set_instance_shader_parameter`) rather than unique material resources. This keeps material count constant regardless of flock size.
- **Shape keys / bones**: currently zero shape keys, 32 bones. Even after adding the handful of shape keys recommended above (CRL, FLF, FAC ×2 objects — a small, deliberately-capped set per the anti-overengineering rule), this stays well inside normal real-time budgets.
- **Verdict**: 10 and 25 sheep are trivial at every level. 50 sheep is still geometrically trivial; the only thing that needs a deliberate architecture decision before scaling that far is the shared-shader / per-instance-parameter approach to materials, not the modularity work itself.

## 13. Files created

- `blender/sheep/tiny_flock_sheep_working.blend` — protected working copy (fresh GLB import, Phase 1)
- `blender/sheep/tiny_flock_sheep_modularity_test.blend` — the split/test file (Phase 5)
- `blender/sheep/tiny_flock_sheep_modularity_test.glb` — test export (Phase 8)
- `godot/assets/models/sheep/_modularity_test/tiny_flock_sheep_modularity_test.glb` — copy placed for Godot-side manual verification (Phase 9)
- `blender/sheep/tools/` — 8 reusable headless scripts (phase1_import.py, phase2_audit.py, phase3_construction.py, phase3b_island_color.py, phase5_modularity_test.py, phase7_regression.py, phase8_export.py, phase8b_verify_export.py, render_still.py, render_flat_vcol.py)
- `blender/sheep/renders/` — before/after and regression-test stills
- `blender/sheep/PROGRESS_LOG.md`
- `docs/verification/sheep_modularity_feasibility_study.md` — this report

## 14. Files modified

None. No existing repository file was edited.

## 15. Source-asset confirmation

`godot/assets/models/sheep/base/sheep_-_animated_low_poly.glb` was checked before and after this entire study: identical size (1,381,176 bytes) and identical last-modified timestamp throughout. **Confirmed untouched.**

## 16. Recommended next experiment (one only)

Build the shader-parameter-driven material system described in Sections 5, 9, and 12 on the *test* split file: expose Wool Color and Point Color as per-instance shader parameters (not per-sheep unique materials), wire a couple of genome loci (start with WBC + PNT, the two cheapest/highest-value loci) to those parameters from a small standalone test scene, and confirm the same animation-regression + Godot-import checks still pass end to end. This is the natural, lowest-risk next step that starts proving out the *actual* genetics pipeline rather than just the geometry split — and it's the piece that was flagged as the one real performance watch point, so proving it out early is worth prioritizing.
