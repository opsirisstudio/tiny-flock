"""
Phase 3b - classify each connected-geometry island as pure-wool, pure-point,
or mixed, based on per-corner vertex color luminance. Answers whether the
existing loose islands align cleanly with the wool/points color boundary
(relevant to Phase 4 wool-separation feasibility).
Run with:
  blender --background --factory-startup --python phase3b_island_color.py -- <working_blend>
"""
import bpy
import bmesh
import sys
import json

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
working_blend = argv[0]

bpy.ops.wm.open_mainfile(filepath=working_blend)

main_obj = bpy.data.objects.get("Object_9")
me = main_obj.data
ca = me.color_attributes.get("Color")


def luminance(c):
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


poly_lum = []
for p in me.polygons:
    lums = [luminance(ca.data[li].color) for li in p.loop_indices]
    poly_lum.append(sum(lums) / len(lums))

vert_to_polys = {}
for p in me.polygons:
    for vi in p.vertices:
        vert_to_polys.setdefault(vi, []).append(p.index)

bm = bmesh.new()
bm.from_mesh(me)
bm.verts.ensure_lookup_table()

visited = set()
islands = []
for v in bm.verts:
    if v.index in visited:
        continue
    stack = [v]
    island = []
    while stack:
        cur = stack.pop()
        if cur.index in visited:
            continue
        visited.add(cur.index)
        island.append(cur.index)
        for e in cur.link_edges:
            other = e.other_vert(cur)
            if other.index not in visited:
                stack.append(other)
    islands.append(island)
bm.free()

LUM_THRESHOLD = 0.5  # rough wool(light) vs point(dark) split
classification = []
for isl in islands:
    poly_set = set()
    for vidx in isl:
        poly_set.update(vert_to_polys.get(vidx, []))
    lums = [poly_lum[pi] for pi in poly_set]
    if not lums:
        continue
    light_count = sum(1 for l in lums if l >= LUM_THRESHOLD)
    dark_count = len(lums) - light_count
    if light_count == len(lums):
        cls = "pure_wool"
    elif dark_count == len(lums):
        cls = "pure_point"
    else:
        cls = "mixed"
    classification.append({
        "vert_count": len(isl),
        "poly_count": len(poly_set),
        "light_polys": light_count,
        "dark_polys": dark_count,
        "classification": cls,
        "avg_luminance": round(sum(lums) / len(lums), 3),
    })

classification.sort(key=lambda e: e["vert_count"], reverse=True)
summary = {
    "island_count": len(classification),
    "pure_wool_islands": sum(1 for c in classification if c["classification"] == "pure_wool"),
    "pure_point_islands": sum(1 for c in classification if c["classification"] == "pure_point"),
    "mixed_islands": sum(1 for c in classification if c["classification"] == "mixed"),
    "mixed_island_detail": [c for c in classification if c["classification"] == "mixed"],
    "all_islands": classification,
}

print("PHASE3B_RESULT_JSON=" + json.dumps(summary))
