class_name SheepAnimationController
extends Node3D

## Controls playback of whatever animations happen to live inside the
## imported sheep GLB. This is the ONLY script allowed to know the raw,
## possibly-awkward clip names baked into the source art asset.
## Everything else in the game should call play_animation()/play_idle()/etc.
## and never reach into the instanced model's AnimationPlayer directly.
##
## If the source GLB is ever replaced, only ANIMATION_ALIASES below and the
## AnimationPlayer discovery in _ready() should need attention.

## Godot's importer prefixes this asset's clip names with the rig's node
## path chain (source: a Sketchfab-hosted "Animal_3081" rig/animation pack,
## confirmed by direct Godot runtime inspection on 2026-07-29 with Godot
## 4.7.1). Isolated here so only this one constant needs updating if the
## asset is replaced.
const _CLIP_PREFIX := "Animal_3081_Rig|Animal_3081_Rig|Animal_3081_Rig|"

## Semantic id -> raw clip names to try, in order. A semantic helper (like
## play_idle) only succeeds if one of its candidates actually exists in the
## currently loaded asset; nothing here is asserted to exist. Confirmed
## against the real AnimationPlayer at runtime (see docs/architecture/sheep_visuals.md).
const ANIMATION_ALIASES := {
	"idle": [_CLIP_PREFIX + "idle"],
	"walk": [_CLIP_PREFIX + "walk"],
	"run": [_CLIP_PREFIX + "run"],
	"eat": [_CLIP_PREFIX + "eat"],
	"sleep": [_CLIP_PREFIX + "sleep"],
}

var _animation_player: AnimationPlayer = null

func _ready() -> void:
	_animation_player = _find_animation_player(self)
	if _animation_player == null: push_warning("SheepAnimationController: no AnimationPlayer found under %s" % get_path())

## Names exactly as the imported asset defines them. Nothing hardcoded.
func get_available_animations() -> PackedStringArray:
	return _animation_player.get_animation_list() if _animation_player != null else PackedStringArray()

func is_animation_available(animation_id: String) -> bool:
	return _animation_player != null and _animation_player.has_animation(animation_id)

func play_animation(animation_id: String) -> bool:
	if not is_animation_available(animation_id): return false
	_animation_player.play(animation_id)
	return true

func stop_animation() -> void:
	if _animation_player != null: _animation_player.stop()

func replay_current() -> void:
	var current := get_current_animation()
	if not current.is_empty(): play_animation(current)

func get_current_animation() -> String:
	return _animation_player.current_animation if _animation_player != null and _animation_player.is_playing() else ""

## Resolves a semantic id to whichever candidate clip name actually exists
## in this asset, or "" if none of the candidates are present.
func resolve_semantic_animation(semantic_id: String) -> String:
	for candidate: String in ANIMATION_ALIASES.get(semantic_id, []):
		if is_animation_available(candidate): return candidate
	return ""

## Semantic helpers are only provided for ids that have candidates above.
## They silently no-op (return false) if the asset doesn't contain a match
## rather than inventing or forcing a mapping.
func play_idle() -> bool: return _play_semantic("idle")
func play_walk() -> bool: return _play_semantic("walk")
func play_run() -> bool: return _play_semantic("run")
func play_eat() -> bool: return _play_semantic("eat")
func play_sleep() -> bool: return _play_semantic("sleep")

func _play_semantic(semantic_id: String) -> bool:
	var resolved := resolve_semantic_animation(semantic_id)
	return play_animation(resolved) if not resolved.is_empty() else false

## Recursive so this never depends on exactly where the glTF importer put
## the AnimationPlayer inside the instanced model.
func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer: return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null: return found
	return null
