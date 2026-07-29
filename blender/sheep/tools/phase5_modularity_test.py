"""
Phase 4/5 modularity experiment.
Opens the (untouched) working file fresh, classifies the loose islands
of Object_9 by vertex-color luminance (wool=light vs points=dark - proven
100% clean in Phase 3b: zero mixed islands), separates the mesh along that
existing boundary into two objects, assigns each an obviously-artificial
test material, and saves the result as a NEW test .blend file. The working
file and source GLB are never written to.
Run with:
  blender --background --factory-startup --python phase5_modularity_test.py -- <working_blend> <out_test_blend>
"""
import bpy
import bmesh
import sys
import json

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
working_blend = argv[0]
out_test_blend = argv[1]

bpy.ops.wm.open_mainfile(filepath=working_blend)

result = {"steps": []}

main_obj = bpy.data.objects.get("Object_9")
me = main_obj.data
ca = me.color_attributes.get("Color")


def luminance(c):
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


poly_lum = []
for p in me.polygons:
    lums = [luminance(ca.data[li].color) for li in p.loop_indices]
    poly_lum.append(sum(lums) / len(lums))

LUM_THRESHOLD = 0.5
dark_faces = [i for i, l in enumerate(poly_lum) if l < LUM_THRESHOLD]
light_faces = [i for i, l in enumerate(poly_lum) if l >= LUM_THRESHOLD]
result["dark_face_count"] = len(dark_faces)
result["light_face_count"] = len(light_faces)

# --- select dark ("points") faces on the object, then separate ---
bpy.context.view_layer.objects.active = main_obj
for o in bpy.data.objects:
    o.select_set(False)
main_obj.select_set(True)

bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='DESELECT')
bpy.ops.object.mode_set(mode='OBJECT')
for i in dark_faces:
    me.polygons[i].select = True
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.separate(type='SELECTED')
bpy.ops.object.mode_set(mode='OBJECT')
result["steps"].append("separated dark(point) faces from light(wool) faces")

new_objs = [o for o in bpy.data.objects if o.type == 'MESH' and o.name not in ("Object_9", "Icosphere")]
result["new_objects_after_separate"] = [o.name for o in new_objs]
points_obj = new_objs[0] if new_objs else None

wool_obj = main_obj
wool_obj.name = "Wool_Test"
wool_obj.data.name = "Wool_Test_Mesh"
if points_obj:
    points_obj.name = "FaceLegPoints_Test"
    points_obj.data.name = "FaceLegPoints_Test_Mesh"


def rig_check(obj):
    mods = [m.type for m in obj.modifiers]
    return {
        "name": obj.name,
        "vertex_count": len(obj.data.vertices),
        "vertex_group_count": len(obj.vertex_groups),
        "vertex_group_names": [vg.name for vg in obj.vertex_groups],
        "modifiers": mods,
        "has_armature_modifier": "ARMATURE" in mods,
    }

result["wool_obj_rig_check"] = rig_check(wool_obj)
if points_obj:
    result["points_obj_rig_check"] = rig_check(points_obj)

mat_wool = bpy.data.materials.new("Material_Wool_Test")
mat_wool.use_nodes = True
bsdf = mat_wool.node_tree.nodes.get("Principled BSDF")
if bsdf:
    bsdf.inputs["Base Color"].default_value = (0.05, 1.0, 0.05, 1.0)  # neon green
wool_obj.data.materials.clear()
wool_obj.data.materials.append(mat_wool)
for p in wool_obj.data.polygons:
    p.material_index = 0

if points_obj:
    mat_points = bpy.data.materials.new("Material_Points_Test")
    mat_points.use_nodes = True
    bsdf2 = mat_points.node_tree.nodes.get("Principled BSDF")
    if bsdf2:
        bsdf2.inputs["Base Color"].default_value = (1.0, 0.0, 0.85, 1.0)  # hot magenta
    points_obj.data.materials.clear()
    points_obj.data.materials.append(mat_points)
    for p in points_obj.data.polygons:
        p.material_index = 0

result["steps"].append("assigned Material_Wool_Test (neon green) and Material_Points_Test (hot magenta)")

bpy.ops.wm.save_as_mainfile(filepath=out_test_blend)
result["saved_test_path"] = out_test_blend
result["steps"].append(f"saved test file: {out_test_blend}")

print("PHASE5_RESULT_JSON=" + json.dumps(result))
