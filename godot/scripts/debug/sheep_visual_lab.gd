extends Node3D

## Developer-facing lab scene for inspecting the imported sheep GLB: does it
## render, do its animations play cleanly, does it sit on the ground. This
## is a laboratory, not gameplay — it only drives SheepVisualController's
## public API, never the instanced model directly.

@onready var sheep: SheepVisualController = %Sheep
@onready var animation_buttons: VBoxContainer = %AnimationButtons
@onready var current_label: Label = %CurrentAnimationLabel
@onready var camera: Camera3D = $Camera3D

var _demo_timer: Timer
var _demo_index := 0

func _ready() -> void:
	camera.look_at(sheep.global_position + Vector3(0, 0.56, 0), Vector3.UP)
	_populate_animation_buttons()
	_update_current_label()
	_demo_timer = Timer.new()
	_demo_timer.wait_time = 2.0
	_demo_timer.timeout.connect(_on_demo_tick)
	add_child(_demo_timer)

## Buttons are generated from the real AnimationPlayer, never hardcoded, so
## this lab stays correct no matter what the source GLB is replaced with.
func _populate_animation_buttons() -> void:
	for animation_id: String in sheep.get_animation_controller().get_available_animations():
		var button := Button.new()
		button.text = animation_id
		button.pressed.connect(_on_animation_button_pressed.bind(animation_id))
		animation_buttons.add_child(button)

func _on_animation_button_pressed(animation_id: String) -> void:
	sheep.get_animation_controller().play_animation(animation_id)
	_update_current_label()

func _on_stop_pressed() -> void:
	sheep.get_animation_controller().stop_animation()
	_update_current_label()

func _on_replay_pressed() -> void:
	sheep.get_animation_controller().replay_current()
	_update_current_label()

func _on_auto_demo_toggled(enabled: bool) -> void:
	if enabled: _demo_timer.start()
	else: _demo_timer.stop()

func _on_demo_tick() -> void:
	var names := sheep.get_animation_controller().get_available_animations()
	if names.is_empty(): return
	_demo_index = (_demo_index + 1) % names.size()
	sheep.get_animation_controller().play_animation(names[_demo_index])
	_update_current_label()

func _update_current_label() -> void:
	var current := sheep.get_animation_controller().get_current_animation()
	current_label.text = "Current animation: %s" % (current if not current.is_empty() else "(stopped)")
