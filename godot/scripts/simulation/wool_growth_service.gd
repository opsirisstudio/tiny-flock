class_name WoolGrowthService
extends RefCounted

func calculate_growth_delta(elapsed_minutes: int) -> float:
	assert(elapsed_minutes >= 0, "Elapsed wool time cannot be negative")
	return float(elapsed_minutes) / float(LifecycleConfig.FULL_WOOL_GROWTH_DAYS * GameTime.MINUTES_PER_DAY)
func advance_wool_growth(sheep: SheepRecord, elapsed_minutes: int) -> void:
	if sheep.location == SheepRecord.Location.BARN_ARCHIVE or sheep.age_stage == SheepRecord.AgeStage.LAMB: return
	sheep.wool_growth = clampf(sheep.wool_growth + calculate_growth_delta(elapsed_minutes), 0.0, 1.0)
func advance_wool_growth_interval(sheep: SheepRecord, old_time: GameTime, new_time: GameTime) -> void:
	assert(new_time.total_minutes >= old_time.total_minutes, "Wool interval cannot run backward")
	if sheep.location == SheepRecord.Location.BARN_ARCHIVE: return
	var growth_start := sheep.birth_game_minute + LifecycleConfig.JUVENILE_AGE_DAYS * GameTime.MINUTES_PER_DAY
	var eligible_start := maxi(old_time.total_minutes, growth_start)
	var eligible_minutes := maxi(0, new_time.total_minutes - eligible_start)
	if eligible_minutes > 0: sheep.wool_growth = clampf(sheep.wool_growth + calculate_growth_delta(eligible_minutes), 0.0, 1.0)
func is_ready_to_shear(sheep: SheepRecord) -> bool: return sheep != null and sheep.wool_growth >= 1.0 and sheep.age_stage in [SheepRecord.AgeStage.ADULT, SheepRecord.AgeStage.ELDER] and sheep.location != SheepRecord.Location.BARN_ARCHIVE
