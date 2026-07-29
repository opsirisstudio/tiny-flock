"""
Phase 7 - animation regression test across all actions on the SPLIT
modularity-test file. For each action: sample bone pose matrices at several
frames and check for NaN/Inf/exploding values; sample evaluated mesh vertex
world positions similarly; render one representative mid-action frame.
Run with:
  blender --background --factory-startup --python phase7_regression.py -- <test_blend> <render_dir>
"""
import bpy
import sys
import os
import math
import json
import mathutils

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
test_blend = argv[0]
render_dir = argv[1]
os.makedirs(render_dir, exist_ok=True)

bpy.ops.wm.open_mainfile(filepath=test_blend)
scene = bpy.context.scene

arm_obj = bpy.data.objects.get("Object_6")
mesh_objs = [o for o in scene.objects if o.type == 'MESH' and o.name != 'Icosphere']
ico = bpy.data.objects.get("Icosphere")
if ico:
    ico.hide_render = True

if arm_obj.animation_data is None:
    arm_obj.animation_data_create()

ORIG_RADIUS = 1.2  # meters, generous vs ~0.66x1.4x1.0 model
EXPLODE_LIMIT = ORIG_RADIUS * 20

min_co = mathutils.Vector((-0.4, -0.8, 0.0))
max_co = mathutils.Vector((0.4, 0.8, 1.1))
center = (min_co + max_co) / 2
size = max_co - min_co
radius = max(size.x, size.y, size.z, 0.1)

cam_data = bpy.data.cameras.new("AuditCam")
cam_obj = bpy.data.objects.new("AuditCam", cam_data)
scene.collection.objects.link(cam_obj)
azim = math.radians(35)
elev = math.radians(20)
dist = radius * 3.0
cam_pos = center + mathutils.Vector((
    dist * math.cos(elev) * math.sin(azim),
    -dist * math.cos(elev) * math.cos(azim),
    dist * math.sin(elev) + size.z * 0.15,
))
cam_obj.location = cam_pos
cam_obj.rotation_euler = (center - cam_pos).to_track_quat('-Z', 'Y').to_euler()
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
scene.cycles.samples = 24
scene.render.resolution_x = 500
scene.render.resolution_y = 500
scene.render.image_settings.file_format = 'PNG'

depsgraph = bpy.context.evaluated_depsgraph_get()

results = []
for action in bpy.data.actions:
    arm_obj.animation_data.action = action
    fr = action.frame_range
    frames_to_sample = sorted(set([
        int(fr[0]),
        int((fr[0] + fr[1]) / 2),
        int(fr[1]),
    ]))
    action_result = {"name": action.name, "frame_range": [fr[0], fr[1]], "frames_checked": [], "status": "OK", "problems": []}

    mid_frame = frames_to_sample[len(frames_to_sample) // 2]

    for fnum in frames_to_sample:
        scene.frame_set(fnum)
        depsgraph.update()
        frame_report = {"frame": fnum, "bad_bones": [], "bad_mesh_objects": []}

        for pb in arm_obj.pose.bones:
            m = pb.matrix
            loc = m.translation
            vals = [loc.x, loc.y, loc.z]
            if any(math.isnan(v) or math.isinf(v) for v in vals):
                frame_report["bad_bones"].append({"bone": pb.name, "issue": "NaN/Inf", "loc": vals})
            elif any(abs(v) > EXPLODE_LIMIT for v in vals):
                frame_report["bad_bones"].append({"bone": pb.name, "issue": "exploding", "loc": vals})

        for mobj in mesh_objs:
            eval_obj = mobj.evaluated_get(depsgraph)
            me_eval = eval_obj.to_mesh()
            bad = 0
            for v in me_eval.vertices:
                wc = eval_obj.matrix_world @ v.co
                if any(math.isnan(c) or math.isinf(c) for c in wc):
                    bad += 1
                elif any(abs(c) > EXPLODE_LIMIT for c in wc):
                    bad += 1
            eval_obj.to_mesh_clear()
            if bad:
                frame_report["bad_mesh_objects"].append({"object": mobj.name, "bad_vertex_count": bad})

        if frame_report["bad_bones"] or frame_report["bad_mesh_objects"]:
            action_result["status"] = "PROBLEM"
            action_result["problems"].append(frame_report)
        action_result["frames_checked"].append(fnum)

    scene.frame_set(mid_frame)
    safe_name = action.name.split("|")[-1]
    out_png = os.path.join(render_dir, f"regression_{safe_name}_f{mid_frame}.png")
    scene.render.filepath = out_png
    bpy.ops.render.render(write_still=True)
    action_result["rendered_frame"] = mid_frame
    action_result["rendered_path"] = out_png

    results.append(action_result)

summary = {
    "action_count": len(results),
    "all_ok": all(r["status"] == "OK" for r in results),
    "results": results,
}
print("PHASE7_RESULT_JSON=" + json.dumps(summary))
