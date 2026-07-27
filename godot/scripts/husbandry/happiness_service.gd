class_name HappinessService
extends RefCounted

func get_care_target(sheep: SheepRecord) -> float:
	return clampf(sheep.hunger * HusbandryConfig.HAPPINESS_HUNGER_WEIGHT + sheep.cleanliness * HusbandryConfig.HAPPINESS_CLEANLINESS_WEIGHT + sheep.bond * HusbandryConfig.HAPPINESS_BOND_WEIGHT, 0.0, 1.0)
func advance(sheep: SheepRecord, elapsed_minutes: int) -> void:
	if elapsed_minutes <= 0 or sheep.location == SheepRecord.Location.BARN_ARCHIVE: return
	var target := get_care_target(sheep)
	var maximum_change := HusbandryConfig.HAPPINESS_RESPONSE_PER_DAY * float(elapsed_minutes) / GameTime.MINUTES_PER_DAY
	sheep.happiness = clampf(move_toward(sheep.happiness, target, maximum_change), 0.0, 1.0)
