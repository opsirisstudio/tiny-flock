class_name LifecycleService
extends RefCounted

var history: SheepHistoryService
func _init(repository: FlockRepository) -> void: history = SheepHistoryService.new(repository)
func get_age_minutes(sheep: SheepRecord, current_time: GameTime) -> int: return maxi(0, current_time.total_minutes - sheep.birth_game_minute)
func get_age_days(sheep: SheepRecord, current_time: GameTime) -> int: return get_age_minutes(sheep, current_time) / GameTime.MINUTES_PER_DAY
func resolve_age_stage(sheep: SheepRecord, current_time: GameTime) -> SheepRecord.AgeStage:
	var age := get_age_minutes(sheep, current_time)
	if age < LifecycleConfig.JUVENILE_AGE_DAYS * GameTime.MINUTES_PER_DAY: return SheepRecord.AgeStage.LAMB
	if age < LifecycleConfig.ADULT_AGE_DAYS * GameTime.MINUTES_PER_DAY: return SheepRecord.AgeStage.JUVENILE
	if age < LifecycleConfig.ELDER_AGE_DAYS * GameTime.MINUTES_PER_DAY: return SheepRecord.AgeStage.ADULT
	return SheepRecord.AgeStage.ELDER
func update_age_stage(sheep: SheepRecord, current_time: GameTime) -> bool:
	var target := resolve_age_stage(sheep, current_time)
	if target == sheep.age_stage: return false
	var transitions := [{"stage":SheepRecord.AgeStage.JUVENILE,"event":SheepLifeEvent.Type.BECAME_JUVENILE,"day":LifecycleConfig.JUVENILE_AGE_DAYS}, {"stage":SheepRecord.AgeStage.ADULT,"event":SheepLifeEvent.Type.BECAME_ADULT,"day":LifecycleConfig.ADULT_AGE_DAYS}, {"stage":SheepRecord.AgeStage.ELDER,"event":SheepLifeEvent.Type.BECAME_ELDER,"day":LifecycleConfig.ELDER_AGE_DAYS}]
	for transition: Dictionary in transitions:
		if int(transition.stage) > sheep.age_stage and int(transition.stage) <= target:
			var event := SheepLifeEvent.new(); event.event_type = int(transition.event) as SheepLifeEvent.Type; event.time_marker = sheep.birth_game_minute + int(transition.day) * GameTime.MINUTES_PER_DAY
			if history.get_events_by_type(sheep.sheep_id, event.event_type).is_empty(): history.record_event(sheep.sheep_id, event)
	sheep.age_stage = target
	return true
