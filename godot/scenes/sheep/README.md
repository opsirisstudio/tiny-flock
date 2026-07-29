# Sheep scenes

`sheep.tscn` is the first Tiny Flock sheep wrapper: it instances the source GLB at res://assets/models/sheep/base/sheep_-_animated_low_poly.glb under `VisualRoot` and adds game-owned collision/interaction nodes around it. See `docs/architecture/sheep_visuals.md` for the full design note, and `scenes/debug/sheep_visual_lab.tscn` for the developer test scene. Domain logic (genetics, personality, etc.) still lives entirely under `scripts/sheep/` and is not referenced from here.
