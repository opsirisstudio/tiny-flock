"""
Phase 1 - Protect the current asset.
Imports a fresh copy of the source GLB into a clean scene and saves
as the new working .blend file. Does NOT touch the source GLB.
Run with:
  blender --background --factory-startup --python phase1_import.py -- <src_glb> <out_blend>
"""
import bpy
import sys
import os
import json

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
src_glb = argv[0]
out_blend = argv[1]

result = {"steps": []}

# 1. Clear the default startup scene entirely (cube, camera, light, etc.)
bpy.ops.wm.read_factory_settings(use_empty=True)
result["steps"].append("cleared to empty factory scene")

# 2. Import the source GLB fresh
if not os.path.isfile(src_glb):
    result["error"] = f"source glb not found: {src_glb}"
    print("PHASE1_RESULT_JSON=" + json.dumps(result))
    sys.exit(1)

bpy.ops.import_scene.gltf(filepath=src_glb)
result["steps"].append(f"imported glb: {src_glb}")

# 3. Enumerate top-level objects
objs = []
for obj in bpy.context.scene.objects:
    entry = {
        "name": obj.name,
        "type": obj.type,
        "parent": obj.parent.name if obj.parent else None,
    }
    if obj.type == 'MESH':
        entry["material_slots"] = [ms.material.name if ms.material else None for ms in obj.material_slots]
        entry["vertex_count"] = len(obj.data.vertices)
        entry["has_animation_data"] = obj.animation_data is not None
    if obj.type == 'ARMATURE':
        entry["bone_count"] = len(obj.data.bones)
        entry["has_animation_data"] = obj.animation_data is not None
    objs.append(entry)
result["objects"] = objs

# 4. Enumerate actions present after import (imported animations)
actions = [a.name for a in bpy.data.actions]
result["actions"] = actions
result["action_count"] = len(actions)

# 5. Materials
materials = [m.name for m in bpy.data.materials]
result["materials"] = materials

# 6. Save as new working file (never overwrite source GLB path)
os.makedirs(os.path.dirname(out_blend), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=out_blend)
result["steps"].append(f"saved working file: {out_blend}")
result["saved_path"] = out_blend

print("PHASE1_RESULT_JSON=" + json.dumps(result))
