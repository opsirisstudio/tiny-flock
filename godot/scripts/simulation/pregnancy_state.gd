class_name PregnancyState
extends Resource

@export var is_pregnant := true
@export var other_parent_id := ""
@export var conception_game_minute := 0
@export var due_game_minute := 0
@export var expected_litter_seed := 0
func validate() -> bool: return is_pregnant and not other_parent_id.is_empty() and conception_game_minute >= 0 and due_game_minute >= conception_game_minute
func to_dictionary() -> Dictionary: return {"is_pregnant":is_pregnant, "other_parent_id":other_parent_id, "conception_game_minute":conception_game_minute, "due_game_minute":due_game_minute, "expected_litter_seed":expected_litter_seed}
static func from_dictionary(data: Dictionary) -> PregnancyState:
	if data.is_empty(): return null
	var state := PregnancyState.new(); state.is_pregnant = bool(data.get("is_pregnant", false)); state.other_parent_id = str(data.get("other_parent_id", "")); state.conception_game_minute = int(data.get("conception_game_minute", -1)); state.due_game_minute = int(data.get("due_game_minute", -1)); state.expected_litter_seed = int(data.get("expected_litter_seed", 0)); return state if state.validate() else null
