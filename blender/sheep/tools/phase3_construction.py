"""
Phase 3 - Determine how the sheep is built: connected geometry islands,
vertex color usage, material node graph wiring, and the mystery Icosphere.
Run with:
  blender --background --factory-startup --python phase3_construction.py -- <working_blend>
"""
import bpy
import bmesh
import sys
import json
from collections import Counter

argv = sys.argv
argv = argv[argv.index("--") + 1:] if "--" in argv else []
working_blend = argv[0]

bpy.ops.wm.open_mainfile(filepath=working_blend)

result = {}
scene = bpy.context.scene

main_obj = bpy.data.objects.get("Object_9")
result["main_mesh_found"] = main_obj is not None

if main_obj:
    me = main_obj.data
    bm = bmesh.new()
    bm.from_mesh(me)
    bm.verts.ensure_lookup_table()

    # connected-component (island) detection over vertex/edge graph
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
    islands.sort(key=len, reverse=True)
    result["island_count"] = len(islands)
    result["island_sizes"] = [len(isl) for isl in islands]

    # cross-reference each island's vertices against vertex groups (dominant group)
    island_group_summary = []
    vgroups = main_obj.vertex_groups
    for isl in islands[:10]:  # cap detail to first 10 islands
        group_weight_totals = Counter()
        for vidx in isl:
            v = me.vertices[vidx]
            for g in v.groups:
                group_weight_totals[vgroups[g.group].name] += g.weight
        top_groups = group_weight_totals.most_common(5)
        island_group_summary.append({
            "island_size": len(isl),
            "sample_vert_indices": isl[:5],
            "top_vertex_groups_by_weight": top_groups,
        })
    result["island_group_summary"] = island_group_summary
    bm.free()

    # vertex color attribute inspection
    color_info = {}
    for ca in me.color_attributes:
        color_info["name"] = ca.name
        color_info["domain"] = ca.domain
        color_info["data_type"] = ca.data_type
        colors = []
        if ca.domain == 'POINT':
            colors = [tuple(round(c, 3) for c in d.color) for d in ca.data]
        else:  # CORNER
            colors = [tuple(round(c, 3) for c in d.color) for d in ca.data]
        color_info["sample_count"] = len(colors)
        counter = Counter(colors)
        most_common = counter.most_common(15)
        color_info["distinct_color_count"] = len(counter)
        color_info["most_common_colors"] = [{"rgba": list(c), "count": n} for c, n in most_common]
    result["vertex_color_attribute"] = color_info

    # material node graph wiring
    mat = main_obj.material_slots[0].material if main_obj.material_slots else None
    graph = {"nodes": [], "links": []}
    if mat and mat.use_nodes:
        for n in mat.node_tree.nodes:
            node_entry = {"name": n.name, "type": n.type}
            if n.type == 'VERTEX_COLOR':
                node_entry["layer_name"] = n.layer_name
            if n.type == 'MIX':
                node_entry["data_type"] = getattr(n, "data_type", None)
                node_entry["blend_type"] = getattr(n, "blend_type", None)
                try:
                    node_entry["inputs"] = [
                        {"name": i.name, "default_value": list(i.default_value) if hasattr(i.default_value, "__len__") else i.default_value}
                        for i in n.inputs
                    ]
                except Exception as e:
                    node_entry["inputs_error"] = str(e)
            graph["nodes"].append(node_entry)
        for link in mat.node_tree.links:
            graph["links"].append({
                "from_node": link.from_node.name,
                "from_socket": link.from_socket.name,
                "to_node": link.to_node.name,
                "to_socket": link.to_socket.name,
            })
    result["material_node_graph"] = graph

# Icosphere investigation
ico = bpy.data.objects.get("Icosphere")
if ico:
    result["icosphere"] = {
        "hide_viewport": ico.hide_viewport,
        "hide_render": ico.hide_render,
        "hide_get": ico.hide_get(),
        "location": list(ico.location),
        "dimensions": list(ico.dimensions),
        "has_animation_data": ico.animation_data is not None,
        "material_slots": len(ico.material_slots),
        "parent": ico.parent.name if ico.parent else None,
        "users_scene": len(ico.users_scene),
    }

# Object_8 (empty child of armature) investigation
obj8 = bpy.data.objects.get("Object_8")
if obj8:
    result["object_8"] = {
        "type": obj8.type,
        "parent": obj8.parent.name if obj8.parent else None,
        "parent_type": obj8.parent_type,
        "parent_bone": getattr(obj8, "parent_bone", None),
        "location": list(obj8.location),
        "children": [c.name for c in obj8.children],
    }

print("PHASE3_RESULT_JSON=" + json.dumps(result))
