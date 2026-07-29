"""
Generic still-frame renderer for the (unsplit) working sheep file
(single mesh object "Object_9").
Run with:
  blender --background --factory-startup --python render_still.py -- <working_blend> <out_png> <frame> [action_name]
Frames the main mesh, hides the Icosphere for the shot, sets the given
action active on the armature (if provided) and evaluates the given
frame, then renders a simple 3/4 view still with Cycles.
"""
import bpy
import sys
import os
import math
import mathutils

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
working_blend = argv[0]
out_png = argv[1]
frame = int(argv[2])
action_name = argv[3] if len(argv) > 3 else None

bpy.ops.wm.open_mainfile(filepath=working_blend)
scene = bpy.context.scene

main_obj = bpy.data.objects.get("Object_9")
arm_obj = bpy.data.objects.get("Object_6")
ico = bpy.data.objects.get("Icosphere")
if ico:
    ico.hide_render = True

if action_name and arm_obj:
    act = bpy.data.actions.get(action_name)
    if act:
        if arm_obj.animation_data is None:
            arm_obj.animation_data_create()
        arm_obj.animation_data.action = act

scene.frame_set(frame)

min_co = mathutils.Vector((float('inf'),) * 3)
max_co = mathutils.Vector((float('-inf'),) * 3)
depsgraph = bpy.context.evaluated_depsgraph_get()
eval_obj = main_obj.evaluated_get(depsgraph)
me_eval = eval_obj.to_mesh()
for v in me_eval.vertices:
    world_co = eval_obj.matrix_world @ v.co
    min_co.x, min_co.y, min_co.z = min(min_co.x, world_co.x), min(min_co.y, world_co.y), min(min_co.z, world_co.z)
    max_co.x, max_co.y, max_co.z = max(max_co.x, world_co.x), max(max_co.y, world_co.y), max(max_co.z, world_co.z)
eval_obj.to_mesh_clear()
center = (min_co + max_co) / 2
size = max_co - min_co
radius = max(size.x, size.y, size.z, 0.1)

cam_data = bpy.data.cameras.new("AuditCam")
cam_obj = bpy.data.objects.new("AuditCam", cam_data)
scene.collection.objects.link(cam_obj)
azim = math.radians(35)
elev = math.radians(20)
dist = radius * 2.6
cam_pos = center + mathutils.Vector((
    dist * math.cos(elev) * math.sin(azim),
    -dist * math.cos(elev) * math.cos(azim),
    dist * math.sin(elev) + size.z * 0.15,
))
cam_obj.location = cam_pos
direction = (center - cam_pos)
cam_obj.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
cam_data.lens = 50
scene.camera = cam_obj

key = bpy.data.lights.new("Key", type='SUN')
key.energy = 3.0
key_obj = bpy.data.objects.new("Key", key)
scene.collection.objects.link(key_obj)
key_obj.rotation_euler = (math.radians(55), 0, math.radians(35))

fill = bpy.data.lights.new("Fill", type='SUN')
fill.energy = 1.2
fill_obj = bpy.data.objects.new("Fill", fill)
scene.collection.objects.link(fill_obj)
fill_obj.rotation_euler = (math.radians(70), 0, math.radians(-120))

world = bpy.data.worlds.new("AuditWorld")
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs[0].default_value = (0.75, 0.8, 0.85, 1.0)
    bg.inputs[1].default_value = 1.0
scene.world = world

scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.render.resolution_x = 900
scene.render.resolution_y = 900
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = out_png

os.makedirs(os.path.dirname(out_png), exist_ok=True)
bpy.ops.render.render(write_still=True)
print("RENDER_DONE=" + out_png)
