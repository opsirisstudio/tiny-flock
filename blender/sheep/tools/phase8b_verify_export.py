"""
Phase 8b - sanity check an exported TEST GLB by re-importing it fresh
into an empty scene and confirming mesh/armature/material/animation counts.
Run with:
  blender --background --factory-startup --python phase8b_verify_export.py -- <test_glb>
"""
import bpy
import sys
import json

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
test_glb = argv[0]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=test_glb)

result = {}
result["mesh_objects"] = [
    {"name": o.name, "vertex_count": len(o.data.vertices), "materials": [m.material.name if m.material else None for m in o.material_slots]}
    for o in bpy.context.scene.objects if o.type == 'MESH'
]
result["armatures"] = [
    {"name": o.name, "bone_count": len(o.data.bones)}
    for o in bpy.context.scene.objects if o.type == 'ARMATURE'
]
result["actions"] = [a.name for a in bpy.data.actions]
result["action_count"] = len(bpy.data.actions)
result["materials"] = [m.name for m in bpy.data.materials]

print("PHASE8B_RESULT_JSON=" + json.dumps(result))
