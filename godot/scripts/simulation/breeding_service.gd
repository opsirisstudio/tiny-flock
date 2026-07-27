class_name BreedingService
extends RefCounted

var repository: FlockRepository
var eligibility: BreedingEligibilityService
var history: SheepHistoryService
func _init(value: FlockRepository) -> void: repository = value; eligibility = BreedingEligibilityService.new(value); history = SheepHistoryService.new(value)
func conceive(sheep_a_id: String, sheep_b_id: String, current_time: GameTime, seed_value: int) -> BreedingResult:
	var result := BreedingResult.new(); var a := repository.get_sheep(sheep_a_id); var b := repository.get_sheep(sheep_b_id)
	if not eligibility.can_breed(a, b, current_time): result.error = eligibility.last_error; return result
	var female := a if a.sex == SheepRecord.Sex.FEMALE else b; var male := b if female == a else a
	var pregnancy := PregnancyState.new(); pregnancy.other_parent_id = male.sheep_id; pregnancy.conception_game_minute = current_time.total_minutes; pregnancy.due_game_minute = current_time.total_minutes + LifecycleConfig.PREGNANCY_DAYS * GameTime.MINUTES_PER_DAY; pregnancy.expected_litter_seed = seed_value; female.pregnancy = pregnancy
	for sheep: SheepRecord in [female, male]:
		var event := SheepLifeEvent.new(); event.event_type = SheepLifeEvent.Type.BREEDING; event.time_marker = current_time.total_minutes; event.related_sheep_ids = [male.sheep_id if sheep == female else female.sheep_id]; history.record_event(sheep.sheep_id, event)
		if history.get_events_by_type(sheep.sheep_id, SheepLifeEvent.Type.FIRST_BREEDING).is_empty(): event.event_type = SheepLifeEvent.Type.FIRST_BREEDING; history.record_event(sheep.sheep_id, event)
	var started := SheepLifeEvent.new(); started.event_type = SheepLifeEvent.Type.PREGNANCY_STARTED; started.time_marker = current_time.total_minutes; started.related_sheep_ids = [male.sheep_id]; history.record_event(female.sheep_id, started)
	result.success = true; result.female_id = female.sheep_id; result.male_id = male.sheep_id; return result
