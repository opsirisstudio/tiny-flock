# Sheep visuals architecture (first proof of concept)

This is the smallest possible visual proof of concept: one imported sheep GLB, wrapped in a game-owned scene, with its baked animations made controllable through a small typed API. It intentionally implements none of Milestone 5 husbandry, no AI, no genetics-to-visual mapping, and no polished environment.

Everything under **CONFIRMED** below was verified by actually running the project in Godot 4.7.1 (`--headless -s`, plus one direct editor launch) on 2026-07-29, not by reading files or guessing from binary substrings. Static inspection alone had previously produced some incorrect guesses (see "What static inspection got wrong," below); those have been corrected here.

## Source asset vs. game-owned wrapper (CONFIRMED)

`res://assets/models/sheep/base/sheep_-_animated_low_poly.glb` is treated as replaceable source art and is never edited directly. `res://scenes/sheep/sheep.tscn` (`Sheep`, root `Node3D`) instances that GLB unmodified under a `VisualRoot` child and adds Tiny Flock's own nodes around it: `BodyCollision` (`StaticBody3D`) for where the sheep physically occupies space, and `InteractionArea` (`Area3D`, slightly larger) for future click/pet/pickup detection. No domain state lives on or inside the GLB.

The root is a plain `Node3D`, not `CharacterBody3D` — nothing moves yet.

## Imported GLB: authoritative structure (CONFIRMED)

Root node: `Node3D` named `Sketchfab_Scene`. Full chain down to the working parts:

```
Sketchfab_Scene (Node3D)
└─ Sketchfab_model (Node3D)
   └─ 554347f3c1254ef09ea2220dd7404ae7_fbx (Node3D)
      └─ Object_2 (Node3D)
         └─ RootNode (Node3D)
            ├─ Animal_3081 (Node3D, empty — no children, no mesh)
            ├─ Animal_3081_Rig (Node3D)
            │  └─ Object_6 (Node3D)
            │     ├─ Skeleton3D
            │     │  └─ Object_9 (MeshInstance3D)
            │     └─ Object_8 (Node3D, empty)
            └─ AnimationPlayer
```

The asset's internal names (`Sketchfab_model`, `554347f3c1254ef09ea2220dd7404ae7_fbx`, `Animal_3081*`, `Object_2/6/8/9`) confirm this is a Sketchfab-hosted, generically-named animal rig/animation pack, not an asset custom-made for "sheep" — the mesh and rig are literally named "Animal_3081." This explains the awkward animation-name prefixing below. `Animal_3081` (a sibling of the actually-used `Animal_3081_Rig`) is a dead/empty node with no mesh or children — an import artifact, not something to reference.

`SheepAnimationController` finds the `AnimationPlayer` and `Skeleton3D` by recursive type search rather than hardcoding this path, specifically because it is this deep and pipeline-specific.

## Animation inventory (CONFIRMED)

`AnimationPlayer.get_animation_list()` returns exactly 14 clips, each prefixed `Animal_3081_Rig|Animal_3081_Rig|Animal_3081_Rig|` (Godot's importer disambiguation prefix — the underlying source clip names, e.g. "idle," were plain, but Godot repeats the rig's node-path chain in front of each on import). All 14 have `loop_mode = LOOP_NONE` at the resource level and 68 animation tracks each (one clip drives ~30 of the 32 bones with position/rotation/scale keys).

| Clip (suffix after the prefix) | Duration | Loop (resource) | Apparent use | Notes |
|---|---|---|---|---|
| bush_hide | 6.200s | None | hiding/ducking pose | longest clip |
| eat | 6.667s | None | grazing/eating | |
| idle | 4.000s | None | standing idle | |
| jump | 2.300s | None | full jump | |
| jump_1 | 0.400s | None | jump segment/variant | short — likely a takeoff/landing sub-clip |
| jump_2 | 0.267s | None | jump segment/variant | shortest clip |
| jump_3 | 0.133s | None | jump segment/variant | |
| jump_4 | 1.000s | None | jump segment/variant | |
| look | 4.000s | None | head look-around | |
| run | 1.067s | None | run cycle | |
| shake | 2.333s | None | body shake | plausibly reusable for a "wet/startled shake" reaction later |
| sleep | 4.000s | None | sleeping | |
| trot | 1.067s | None | trot cycle | |
| walk | 1.067s | None | walk cycle | |

**No baked root motion.** For `walk`, `run`, `trot`, and `idle`, the topmost animated bone (`root_02`) has exactly one position key at `(0,0,0)` for the whole clip — the body doesn't translate; these are pure in-place cycles. That's good for a future locomotion system (no fighting baked movement), but also means feet-sliding risk depends entirely on the game matching its movement speed to each cycle's implied pace — not something that can be confirmed without watching it move on screen next to actual world-space translation.

**None of the 14 clips loop by default** (`Animation.loop_mode == LOOP_NONE` on all of them). Continuous idle/walk cycling will need either `Animation.loop_mode` set at runtime before playback, or re-triggering `play()` on the `AnimationPlayer`'s `animation_finished` signal. Not implemented in this proof of concept — noted for the next experiment.

**Playback sanity-checked, not eyeballed.** All 14 clips were played end-to-end headlessly, sampling every bone's global transform at 5 points across each clip's duration; none produced NaN/Inf or wildly out-of-range values. That rules out an obviously broken/exploding rig, but it is not the same as watching it render — no GUI screenshot of the sheep was possible this session (see "What could not be verified," below).

### Semantic alias fix (CONFIRMED bug, now fixed)

The original `ANIMATION_ALIASES` table (written before runtime access existed) guessed bare names like `"idle"`. Runtime testing proved `is_animation_available("idle") == false` and every `play_idle()`/`play_walk()`/etc. helper silently failed. Fixed by isolating the real prefix in one constant (`_CLIP_PREFIX`) in `sheep_animation_controller.gd`; all 5 semantic helpers (`idle`, `walk`, `run`, `eat`, `sleep`) now resolve correctly, reconfirmed by direct headless test.

## Skeleton (CONFIRMED)

`Skeleton3D` at `.../Animal_3081_Rig/Object_6/Skeleton3D`, 32 bones.

| idx | name | parent | idx | name | parent |
|---|---|---|---|---|---|
| 0 | `_rootJoint` | — (root) | 16 | `eye_R_016` | head_014 |
| 1 | `Armature_01` | _rootJoint | 17 | `mouth_017` | head_014 |
| 2 | `root_02` | Armature_01 | 18 | `ear_L_018` | head_014 |
| 3 | `all_ctrl_03` | root_02 | 19 | `ear_R_019` | head_014 |
| 4 | `center_ctrl_04` | all_ctrl_03 | 20 | `shoulder_L_020` | center_ctrl_04 |
| 5 | `pelvis_05` | center_ctrl_04 | 21 | `uparm_L_021` | center_ctrl_04 |
| 6 | `tail_06` | pelvis_05 | 22 | `arm_L_022` | center_ctrl_04 |
| 7 | `thigh_L_07` | center_ctrl_04 | 23 | `hand_L_023` | center_ctrl_04 |
| 8 | `leg_L_08` | center_ctrl_04 | 24 | `shoulder_R_024` | center_ctrl_04 |
| 9 | `foot_L_09` | center_ctrl_04 | 25 | `uparm_R_025` | center_ctrl_04 |
| 10 | `toe_L_010` | center_ctrl_04 | 26 | `arm_R_026` | center_ctrl_04 |
| 11 | `spine_011` | center_ctrl_04 | 27 | `hand_R_027` | center_ctrl_04 |
| 12 | `chest_012` | center_ctrl_04 | 28 | `thigh_R_028` | center_ctrl_04 |
| 13 | `neck_013` | center_ctrl_04 | 29 | `leg_R_00` | center_ctrl_04 |
| 14 | `head_014` | center_ctrl_04 | 30 | `foot_R_029` | center_ctrl_04 |
| 15 | `eye_L_015` | head_014 | 31 | `toe_R_030` | center_ctrl_04 |

**Important, non-obvious finding:** this is *not* an anatomical FK chain. `leg_L_08` is not a child of `thigh_L_07`; `foot_L_09` is not a child of `leg_L_08`. Almost every limb, spine, chest, neck, and head bone is parented directly to the single `center_ctrl_04` hub bone. Only eyes/mouth/ears (children of `head_014`) and the tail (child of `pelvis_05`) have real parent-child relationships. This works fine for the baked clips above (every bone's absolute pose is explicitly keyframed per clip, so hierarchy depth doesn't matter for playback), but it means hand-posing a *new* animation in Godot's keyframe editor — e.g. rotating a thigh bone — will **not** drag the rest of that leg along via inheritance; each bone in a "chain" has to be posed independently. No ears or tail get independent tracks in the sampled clips, but the bones exist and are individually addressable.

No horn bones exist. No separate mesh regions for ears/tail either — they're part of the single skinned mesh, just individually-addressable via their bones.

## Materials and mesh (CONFIRMED)

Exactly **one** `MeshInstance3D` (`Object_9`), **one** surface, **one** material (`StandardMaterial3D`, resource name `Animal_3081_Textured`):

- `shading_mode = PER_PIXEL` (normally lit — **not** unlit; an earlier static-inspection guess said "possibly unlit," which was wrong)
- `albedo_color = (0.906, 0.906, 0.906, 1.0)` — a light, near-white/grey base tint
- `albedo_texture = null` — **confirmed no texture**, despite the material being named "Textured." Flat/solid color only.
- `roughness = 1.0`, `metallic = 0.0`, `normal_enabled = false`

There is no separate wool material, no separate face/leg material, no separate eyes mesh, and no horns. The whole sheep — body and any implied "wool" — is one mesh with one flat-colored material.

**Mesh bounding box** (identity transform, i.e. exactly as it sits in `sheep.tscn` today): position `(-0.336, 0.0, -0.580)`, size `(0.672, 1.119, 1.367)` — so the model spans roughly 0.67m wide, 1.12m tall, 1.37m long, and **the bottom of the bounding box sits at world Y = 0.0** — feet are already at ground level with no vertical offset needed in the wrapper. This is a real-world-ish scale, not literally tiny; worth an art/design look later, but not something this proof of concept should force a decision on.

Model forward direction was **not** confirmed — that requires actually looking at it (see below).

### `set_wool_tint()` behavior (CONFIRMED)

Tested directly: calling `set_wool_tint(Color(1,0,0))` duplicates the one existing material and successfully changes its `albedo_color`. Because there is only one mesh and one material on this asset, **it tints the entire sheep, not just "wool."** This is not a bug in the code — there is no separate wool-only material or mesh region to target. Per the instructions for this task, the behavior is left unchanged and documented as a limitation rather than built out further: a real wool-only tint needs either a second material (with the mesh split into wool/skin regions) or a texture mask, neither of which this asset has today.

## Collision (CONFIRMED fix)

The original placeholder capsules (radius 0.25–0.35, height 0.6–0.8, centered at Y=0.3) covered less than half the model's actual height once the real bounding box was measured (model top is at Y≈1.12; the old capsule topped out at Y=0.6). Replaced with `BoxShape3D`s sized directly from the measured AABB: `BodyCollision` uses `(0.75, 1.2, 1.45)` centered at `(0, 0.56, 0.1)`; `InteractionArea` uses a slightly larger `(0.95, 1.5, 1.8)` at the same center. Still intentionally rough — not precision collision, just now actually sized from the real asset instead of a guess.

## What static inspection got wrong

Before Godot access was available, raw byte-scanning of the binary `.glb` (no glTF/JSON tool was available) produced a few incorrect guesses, now corrected: it suggested the material might be `KHR_materials_unlit` (it's actually normal `PER_PIXEL` shading); it could not determine exact animation names (they're the 14 above, not simple words like "idle" — those words exist only as suffixes after a long prefix); and it couldn't determine bone names, node hierarchy, or scale at all. Binary substring scanning on this session's tooling was also observed to be non-deterministic (repeated queries for the same string sometimes returned different results within the same conversation) — it should not be trusted as a source of fact going forward. The one thing static inspection got right: no Mixamo rig, no embedded texture images.

## What could not be verified this session

Godot is not registered as an app this session's screen-control tooling recognizes (it's a portable download, not Start-Menu-installed), so no screenshot of the running scene was possible — only headless/CLI verification. That means the following are still genuinely unconfirmed and need a human look in the editor:
- Whether the model visually looks correct (color, shading, silhouette) when rendered.
- Model forward-facing direction.
- Whether any animation visually deforms oddly (numerically the bone transforms stay finite and bounded, which is a good sign, but that's not the same as watching it).
- Whether feet visibly slide during walk/run/trot at whatever speed the game eventually drives them.
- Camera framing quality in `sheep_visual_lab.tscn` (numerically retargeted to look at the model's measured center, Y=0.56, but not eyeballed).

## Likely genetics-to-visual mapping strategy (updated with real data)

- **Material tint (color)**: confirmed reachable and working (`set_wool_tint`), but — now confirmed — it recolors the *entire* sheep, not wool specifically, because there's only one material. A real "wool color vs. skin/face color" genetic split needs new art (a second material or a texture mask), not just code.
- **Scale**: overall body size maps naturally to a uniform scale on `VisualRoot`/`SheepModel`; nothing about the confirmed structure blocks this.
- **Bone-level proportions (legs, ears)**: technically possible — every relevant bone (`thigh_L_07`, `leg_L_08`, `ear_L_018`, etc.) is individually addressable in the `Skeleton3D` — but because the rig isn't a true FK chain, scaling e.g. a single leg bone will scale that bone's own segment only, not the whole leg uniformly; each leg segment would need independent scaling. Feasible, but fiddlier than a normal FK rig.
- **Blend shapes**: none exist on `Object_9` (not inspected for shape-key count directly, but the mesh/import pipeline gives no indication of any) — would require a remodel.
- **Modular meshes** (horns, alternate ears): not present today (no horn bones, no separate mesh regions) — new art required.
- **Textures/markings**: not possible today — no texture at all is bound to the material. New art required.

## Wool vs. freshly-shorn visuals (unchanged: analysis only, still not implemented)

Given the confirmed single-mesh, single-material, no-texture structure, the most realistic near-term option is a **second wool mesh/shell** authored separately in Blender and toggled visible/invisible, or an **alternate shorn mesh** swapped in — not a material trick, since there's no wool-specific material to manipulate, and not a blend shape, since none exist on the current mesh.

## Pickup-animation feasibility (updated with real data)

The confirmed flat bone hierarchy (almost everything parented to `center_ctrl_04`, not to its anatomical neighbor) makes hand-keyframing a new "panic kick" pose inside Godot's animation editor more tedious than a typical rig — each leg segment needs independent posing since there's no FK inheritance down the leg. This reinforces authoring any new pickup pose in Blender against the source rig rather than in Godot. None of the 14 confirmed clips is a "held in the air, legs kicking" pose; the closest reusable material is `shake` (2.333s, a full-body shake that could inform a "startled" reaction) and the four short `jump_*` segments (0.13–1.0s), which are fast but are jump-related, not panic-specific. `AnimationTree` blending remains a reasonable way to get personality-flavored variants (frantic vs. frozen vs. brief-panic-then-relax) from one authored base pose without needing five full separate clips.

## Performance notes

Confirmed via headless test: all 14 clips play cleanly with no per-frame script cost beyond the debug lab's optional 2-second auto-demo `Timer`; nothing uses `_process()`. Single mesh/single material keeps per-sheep cost minimal. `set_wool_tint()` duplicates one material per tinted instance (confirmed: exactly one `StandardMaterial3D` duplicate per call) — fine at the counts this milestone cares about, worth watching at 25–50 simultaneous tinted sheep since materials won't be shared. Poly count and actual render/GPU cost were not measured (no GUI rendering access this session); worth a look once the model can be seen on screen. The project renders in `gl_compatibility` mode; nothing added here changes that.

## Unrelated issue discovered (not fixed — out of scope for this task)

Running Godot headlessly regenerates `.godot/uid_cache.bin`, a gitignored binary cache. `tools/static_verify.py`'s `res://` reference scan (`GODOT.rglob("*")` at line 37) reads *every* file under `godot/`, including this binary cache, as text via regex. Its current byte content happens to coincidentally spell something that regex-matches as a broken `res://` reference, so `static_verify.py` currently fails with `missing res://scripts/debug/flock_archive_lab.gd#<binary noise> referenced by .../.godot/uid_cache.bin` — unrelated to sheep visuals or any code in this proof of concept. Confirmed by temporarily excluding `.godot/` from the same scan logic: with it excluded, everything related to this proof of concept (and the rest of the repo) passes with zero bad references, zero missing scene handlers, zero missing unique nodes, and `git diff --check` clean. Not fixed here per this task's scope (fix only what's directly related to the visual prototype); a real fix would exclude `.godot/`, `.import`, and other engine-generated cache paths from that scan.

## What remains deliberately unimplemented

Sheep AI, pathfinding, wandering, flocking, feeding/petting/pickup/grooming/washing/shearing gameplay, any genetics-to-visual mapping, breeding/pregnancy/lamb/elder visuals, personality behavior, sound, polished environment art, inventory, economy, and any new persistence version. `sheep_visual_lab.tscn` is a laboratory scene, not a level, and is not wired into `run/main_scene`.
