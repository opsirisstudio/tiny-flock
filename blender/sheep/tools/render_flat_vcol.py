"""
Flat, shadeless render of raw vertex colors (Workbench, no lighting variance)
to distinguish genuine painted markings from lighting/shadow artifacts.
Run with:
  blender --background --factory-startup --python render_flat_vcol.py -- <working_blend> <out_png>
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

bpy.ops.wm.open_mainfile(filepath=working_blend)
scene = bpy.context.scene

main_obj = bpy.data.objects.get("Object_9")
ico = bpy.data.objects.get("Icosphere")
if ico:
    ico.hide_render = True

scene.frame_set(1)

min_co = mathutils.Vector((float('inf'),) * 3)
max_co = mathutils.Vector((float('-inf'),) * 3)
for v in main_obj.data.vertices:
    wc = main_obj.matrix_world @ v.co
    min_co.x, min_co.y, min_co.z = min(min_co.x, wc.x), min(min_co.y, wc.y), min(min_co.z, wc.z)
    max_co.x, max_co.y, max_co.z = max(max_co.x, wc.x), max(max_co.y, wc.y), max(max_co.z, wc.z)
center = (min_co + max_co) / 2
size = max_co - min_co
radius = max(size.x, size.y, size.z, 0.1)

cam_data = bpy.data.cameras.new("AuditCam")
cam_obj = bpy.data.objects.new("AuditCam", cam_data)
scene.collection.objects.link(cam_obj)
azim = math.radians(35)
elev = math.radians(20)
dist = radius * 4.2
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

scene.render.engine = 'BLENDER_WORKBENCH'
scene.display.shading.light = 'FLAT'
scene.display.shading.color_type = 'VERTEX'
scene.display.shading.show_shadows = False
scene.display.shading.show_cavity = False
scene.render.resolution_x = 900
scene.render.resolution_y = 900
scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = out_png

os.makedirs(os.path.dirname(out_png), exist_ok=True)
bpy.ops.render.render(write_still=True)
print("RENDER_DONE=" + out_png)
