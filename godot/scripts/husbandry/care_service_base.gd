class_name CareServiceBase
extends RefCounted

var repository: FlockRepository
var history: SheepHistoryService
func _init(value: FlockRepository) -> void: repository = value; history = SheepHistoryService.new(value)
func begin(sheep_id: String, interaction: String) -> CareInteractionResult:
	var result := CareInteractionResult.new(); result.sheep_id = sheep_id; result.interaction_type = interaction
	var sheep := repository.get_sheep(sheep_id)
	if sheep == null: result.reason = CareInteractionResult.Reason.SHEEP_NOT_FOUND; return result
	result.capture_before(sheep)
	if sheep.location == SheepRecord.Location.BARN_ARCHIVE: result.capture_after(sheep); result.reason = CareInteractionResult.Reason.SHEEP_ARCHIVED; return result
	return result
func apply_life_stage_bond(sheep: SheepRecord, gain: float, petting: bool = false) -> float:
	if sheep.age_stage == SheepRecord.AgeStage.LAMB: gain *= HusbandryConfig.LAMB_BOND_MULTIPLIER
	if petting and sheep.age_stage == SheepRecord.AgeStage.ELDER: gain *= HusbandryConfig.ELDER_PET_BOND_MULTIPLIER
	return gain
func record(sheep_id: String, type: SheepLifeEvent.Type, time: GameTime, metadata: Dictionary = {}) -> void:
	var event := SheepLifeEvent.new(); event.event_type = type; event.time_marker = time.total_minutes; event.metadata = metadata; history.record_event(sheep_id, event)
