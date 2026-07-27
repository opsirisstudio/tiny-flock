class_name GameTime
extends RefCounted

const MINUTES_PER_HOUR := 60
const HOURS_PER_DAY := 24
const MINUTES_PER_DAY := MINUTES_PER_HOUR * HOURS_PER_DAY
var total_minutes := 0

func _init(minutes: int = 0) -> void:
	assert(minutes >= 0, "Game time cannot be negative")
	total_minutes = minutes
func get_day() -> int: return total_minutes / MINUTES_PER_DAY + 1
func get_minute_of_day() -> int: return total_minutes % MINUTES_PER_DAY
func get_hour() -> int: return get_minute_of_day() / MINUTES_PER_HOUR
func get_minute_of_hour() -> int: return get_minute_of_day() % MINUTES_PER_HOUR
func duplicate_time() -> GameTime: return GameTime.new(total_minutes)
func format_day_time() -> String: return "Day %d, %02d:%02d" % [get_day(), get_hour(), get_minute_of_hour()]
