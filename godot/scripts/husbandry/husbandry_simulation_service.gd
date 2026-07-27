class_name HusbandrySimulationService
extends RefCounted

var happiness := HappinessService.new()
func advance_needs(sheep: SheepRecord, elapsed_minutes: int) -> void:
	assert(elapsed_minutes >= 0, "Husbandry time cannot run backward")
	if elapsed_minutes == 0 or sheep.location == SheepRecord.Location.BARN_ARCHIVE: return
	var days := float(elapsed_minutes) / GameTime.MINUTES_PER_DAY
	sheep.hunger = clampf(sheep.hunger - days / HusbandryConfig.FULL_TO_EMPTY_HUNGER_DAYS, 0.0, 1.0)
	sheep.cleanliness = clampf(sheep.cleanliness - days / HusbandryConfig.FULL_TO_DIRTY_DAYS, 0.0, 1.0)
	happiness.advance(sheep, elapsed_minutes)
