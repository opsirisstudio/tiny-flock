"""
Phase 8 - export the modularity-test file to a clearly-named TEST GLB.
Never touches the production GLB. Godot-4.x-appropriate glTF export settings:
Y-up, skinning, all NLA-track animations, materials.
Run with:
  blender --background --factory-startup --python phase8_export.py -- <test_blend> <out_glb>
"""
import bpy
import sys
import json

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
test_blend = argv[0]
out_glb = argv[1]

bpy.ops.wm.open_mainfile(filepath=test_blend)

result = {}
before_actions = [a.name for a in bpy.data.actions]
result["actions_before_export"] = before_actions

bpy.ops.export_scene.gltf(
    filepath=out_glb,
    export_format='GLB',
    export_yup=True,
    use_selection=False,
    export_animations=True,
    export_nla_strips=True,
    export_force_sampling=True,
    export_skins=True,
    export_morph=True,
    export_materials='EXPORT',
    export_apply=False,
)

result["exported_path"] = out_glb
import os
result["file_exists"] = os.path.isfile(out_glb)
result["file_size"] = os.path.getsize(out_glb) if result["file_exists"] else None

print("PHASE8_RESULT_JSON=" + json.dumps(result))
