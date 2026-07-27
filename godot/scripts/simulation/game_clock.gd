class_name GameClock
extends RefCounted

var _current_time: GameTime
var last_error := ""
func _init(initial_minutes: int = 0) -> void: _current_time = GameTime.new(initial_minutes)
func get_current_time() -> GameTime: return _current_time.duplicate_time()
func get_total_minutes() -> int: return _current_time.total_minutes
func advance_minutes(minutes: int) -> bool:
	last_error = ""
	if minutes < 0: last_error = "Cannot advance game time by a negative amount."; push_error(last_error); return false
	_current_time.total_minutes += minutes; return true
func advance_hours(hours: int) -> bool: return advance_minutes(hours * GameTime.MINUTES_PER_HOUR) if hours >= 0 else advance_minutes(-1)
func advance_days(days: int) -> bool: return advance_minutes(days * GameTime.MINUTES_PER_DAY) if days >= 0 else advance_minutes(-1)
