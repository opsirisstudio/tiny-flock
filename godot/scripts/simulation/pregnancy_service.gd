class_name PregnancyService
extends RefCounted

var repository: FlockRepository
var history: SheepHistoryService
func _init(value: FlockRepository) -> void: repository = value; history = SheepHistoryService.new(value)
static func select_litter_size(roll: float) -> int:
	if roll < LifecycleConfig.SINGLETON_WEIGHT: return 1
	if roll < LifecycleConfig.SINGLETON_WEIGHT + LifecycleConfig.TWINS_WEIGHT: return 2
	return 3
func resolve_due_pregnancy(mother: SheepRecord, current_time: GameTime) -> BirthResult:
	var result := BirthResult.new(); result.mother_id = mother.sheep_id if mother != null else ""
	if mother == null or mother.pregnancy == null: result.error = "No pregnancy to resolve."; return result
	if current_time.total_minutes < mother.pregnancy.due_game_minute: result.error = "Pregnancy is not due."; return result
	var state := mother.pregnancy; var father := repository.get_sheep(state.other_parent_id)
	if father == null: result.error = "Pregnancy references a missing other parent."; return result
	var rng := RandomNumberGenerator.new(); rng.seed = state.expected_litter_seed
	var litter_size := select_litter_size(rng.randf())
	for index: int in range(litter_size):
		var lamb_seed := rng.randi(); var engine := BreedingEngine.new(lamb_seed, true)
		var stable_id := "lamb-%s-%d-%d-%d" % [mother.sheep_id, state.due_game_minute, state.expected_litter_seed, index]
		var lamb := SheepFactory.create_lamb(mother, father, engine, "Lamb %d" % (index + 1), stable_id)
		lamb.birth_game_minute = current_time.total_minutes; lamb.wool_growth = 0.0
		var born := SheepLifeEvent.new(); born.event_type = SheepLifeEvent.Type.BORN; born.time_marker = current_time.total_minutes; born.related_sheep_ids = [mother.sheep_id, father.sheep_id]; born.metadata = {"mother_id":mother.sheep_id, "father_id":father.sheep_id, "litter_size":litter_size, "litter_index":index}; lamb.life_events.append(born)
		if not repository.add_sheep(lamb): result.error = repository.last_error; return result
		result.lambs.append(lamb)
		for parent: SheepRecord in [mother, father]:
			var offspring := SheepLifeEvent.new(); offspring.event_type = SheepLifeEvent.Type.OFFSPRING_BORN; offspring.time_marker = current_time.total_minutes; offspring.related_sheep_ids = [lamb.sheep_id]; offspring.metadata = {"offspring_id":lamb.sheep_id, "other_parent_id":father.sheep_id if parent == mother else mother.sheep_id}; history.record_event(parent.sheep_id, offspring)
	mother.pregnancy = null; mother.breeding_available_game_minute = current_time.total_minutes + LifecycleConfig.POSTPARTUM_COOLDOWN_DAYS * GameTime.MINUTES_PER_DAY
	var birth := SheepLifeEvent.new(); birth.event_type = SheepLifeEvent.Type.BIRTH_GIVEN; birth.time_marker = current_time.total_minutes; birth.related_sheep_ids = [father.sheep_id]; birth.metadata = {"litter_size":litter_size}; history.record_event(mother.sheep_id, birth)
	result.success = true; return result
func resolve_all_due(current_time: GameTime) -> Array[BirthResult]:
	var results: Array[BirthResult] = []
	for sheep: SheepRecord in repository.all_sheep():
		if sheep.pregnancy != null and current_time.total_minutes >= sheep.pregnancy.due_game_minute: results.append(resolve_due_pregnancy(sheep, current_time))
	return results
