class_name SheepVisualController
extends Node3D

## Public-facing API for a Tiny Flock sheep's visual representation.
## Game/domain code should talk to THIS class, never to the instanced GLB
## or its internal node structure. This is also the seam where a future
## genetics-to-visual mapping (wool color, scale, markings, ...) will plug
## in; no such mapping is implemented yet, only the seam.

@onready var animation_controller: SheepAnimationController = %VisualRoot

func get_animation_controller() -> SheepAnimationController:
	return animation_controller

## Demonstrates that wool/body color is reachable as a material parameter
## without touching the source GLB. Not wired to genetics yet — the caller
## picks the color explicitly. Duplicates materials per-instance so tinting
## one sheep never affects the shared imported resource or other sheep.
func set_wool_tint(color: Color) -> void:
	var mesh_instance := _find_mesh_instance(animation_controller)
	if mesh_instance == null or mesh_instance.mesh == null: return
	for surface: int in mesh_instance.mesh.get_surface_count():
		var material := mesh_instance.get_active_material(surface)
		if material is BaseMaterial3D:
			var tinted := material.duplicate() as BaseMaterial3D
			tinted.albedo_color = color
			mesh_instance.set_surface_override_material(surface, tinted)

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D: return node
	for child in node.get_children():
		var found := _find_mesh_instance(child)
		if found != null: return found
	return null
