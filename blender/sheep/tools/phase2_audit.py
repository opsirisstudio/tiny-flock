"""
Phase 2 - Full Blender asset audit of the working file.
Run with:
  blender --background --factory-startup --python phase2_audit.py -- <working_blend>
Prints one line: PHASE2_RESULT_JSON={...}
"""
import bpy
import sys
import os
import json
import mathutils

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
working_blend = argv[0]

bpy.ops.wm.open_mainfile(filepath=working_blend)

result = {}
scene = bpy.context.scene
result["fps"] = scene.render.fps
result["frame_start"] = scene.frame_start
result["frame_end"] = scene.frame_end

# ---------- MESH AUDIT ----------
meshes = []
for obj in scene.objects:
    if obj.type != 'MESH':
        continue
    me = obj.data
    entry = {
        "object_name": obj.name,
        "mesh_name": me.name,
        "parent": obj.parent.name if obj.parent else None,
        "vertex_count": len(me.vertices),
        "edge_count": len(me.edges),
        "polygon_count": len(me.polygons),
        "triangle_estimate": sum(max(0, len(p.vertices) - 2) for p in me.polygons),
        "material_slots": [ms.material.name if ms.material else None for ms in obj.material_slots],
        "uv_maps": [uv.name for uv in me.uv_layers],
        "color_attributes": [ca.name for ca in me.color_attributes] if hasattr(me, "color_attributes") else [],
        "vertex_groups": [vg.name for vg in obj.vertex_groups],
        "shape_keys": [sk.name for sk in me.shape_keys.key_blocks] if me.shape_keys else [],
        "modifiers": [{"name": m.name, "type": m.type} for m in obj.modifiers],
        "use_auto_smooth": getattr(me, "use_auto_smooth", None),
        "location": list(obj.location),
        "rotation_euler_deg": [round(v * 57.29578, 3) for v in obj.rotation_euler],
        "scale": list(obj.scale),
        "dimensions": list(obj.dimensions),
    }
    meshes.append(entry)
result["meshes"] = meshes

# ---------- ARMATURE AUDIT ----------
armatures = []
for obj in scene.objects:
    if obj.type != 'ARMATURE':
        continue
    arm = obj.data
    bones = []
    for b in arm.bones:
        bones.append({
            "name": b.name,
            "parent": b.parent.name if b.parent else None,
            "children": [c.name for c in b.children],
            "use_deform": b.use_deform,
            "head_local": [round(v, 4) for v in b.head_local],
            "tail_local": [round(v, 4) for v in b.tail_local],
        })
    # constraints on pose bones
    pose_constraints = {}
    for pb in obj.pose.bones:
        if pb.constraints:
            pose_constraints[pb.name] = [c.type for c in pb.constraints]
    armatures.append({
        "object_name": obj.name,
        "armature_name": arm.name,
        "parent": obj.parent.name if obj.parent else None,
        "bone_count": len(arm.bones),
        "deform_bone_count": sum(1 for b in arm.bones if b.use_deform),
        "root_bones": [b.name for b in arm.bones if b.parent is None],
        "bones": bones,
        "pose_bone_constraints": pose_constraints,
        "location": list(obj.location),
        "rotation_euler_deg": [round(v * 57.29578, 3) for v in obj.rotation_euler],
        "scale": list(obj.scale),
    })
result["armatures"] = armatures

# ---------- ANIMATION AUDIT ----------
def get_action_fcurves(action):
    """Blender 4.4+ moved fcurves behind layers/strips/channelbags (slotted actions).
    Fall back to legacy action.fcurves if present."""
    fcurves = []
    legacy = getattr(action, "fcurves", None)
    if legacy is not None and len(legacy) > 0:
        return list(legacy)
    for layer in getattr(action, "layers", []):
        for strip in layer.strips:
            for cb in getattr(strip, "channelbags", []):
                fcurves.extend(list(cb.fcurves))
    return fcurves

actions = []
for a in bpy.data.actions:
    fr = a.frame_range
    fcs = get_action_fcurves(a)
    fcurve_bones = set()
    for fc in fcs:
        dp = fc.data_path
        if dp.startswith('pose.bones["'):
            bone_name = dp.split('"')[1]
            fcurve_bones.add(bone_name)
    slot_names = [s.name_display if hasattr(s, "name_display") else s.name for s in getattr(a, "slots", [])]
    actions.append({
        "name": a.name,
        "frame_start": fr[0],
        "frame_end": fr[1],
        "fcurve_count": len(fcs),
        "bones_animated": sorted(fcurve_bones),
        "bones_animated_count": len(fcurve_bones),
        "slots": slot_names,
    })
result["actions"] = actions
result["action_count"] = len(actions)

nla_tracks = []
for obj in scene.objects:
    if obj.animation_data and obj.animation_data.nla_tracks:
        for t in obj.animation_data.nla_tracks:
            nla_tracks.append({
                "object": obj.name,
                "track_name": t.name,
                "strip_count": len(t.strips),
                "strips": [s.name for s in t.strips],
            })
result["nla_tracks"] = nla_tracks

# ---------- MATERIALS AUDIT ----------
materials = []
for m in bpy.data.materials:
    mat_entry = {
        "name": m.name,
        "use_nodes": m.use_nodes,
        "node_types": [],
        "image_textures": [],
        "base_color": None,
    }
    if m.use_nodes:
        for n in m.node_tree.nodes:
            mat_entry["node_types"].append(n.type)
            if n.type == 'TEX_IMAGE' and n.image:
                mat_entry["image_textures"].append(n.image.name)
            if n.type == 'BSDF_PRINCIPLED':
                try:
                    bc = n.inputs['Base Color'].default_value
                    mat_entry["base_color"] = [round(v, 3) for v in bc]
                except Exception:
                    pass
    materials.append(mat_entry)
result["materials"] = materials

# ---------- IMAGES ----------
result["images"] = [{"name": img.name, "filepath": img.filepath, "size": list(img.size)} for img in bpy.data.images]

# ---------- WORLD BOUNDING BOX (all mesh objects combined, world space) ----------
min_co = mathutils.Vector((float('inf'),) * 3)
max_co = mathutils.Vector((float('-inf'),) * 3)
for obj in scene.objects:
    if obj.type != 'MESH':
        continue
    for corner in obj.bound_box:
        world_co = obj.matrix_world @ mathutils.Vector(corner)
        min_co.x, min_co.y, min_co.z = min(min_co.x, world_co.x), min(min_co.y, world_co.y), min(min_co.z, world_co.z)
        max_co.x, max_co.y, max_co.z = max(max_co.x, world_co.x), max(max_co.y, world_co.y), max(max_co.z, world_co.z)
result["world_bounding_box"] = {
    "min": [round(v, 4) for v in min_co],
    "max": [round(v, 4) for v in max_co],
    "size": [round(max_co[i] - min_co[i], 4) for i in range(3)],
}

print("PHASE2_RESULT_JSON=" + json.dumps(result))
