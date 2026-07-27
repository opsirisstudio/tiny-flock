class_name ShearingService
extends RefCounted

var repository: FlockRepository
var history: SheepHistoryService
var wool := WoolGrowthService.new()
func _init(value: FlockRepository) -> void: repository = value; history = SheepHistoryService.new(value)
func shear(sheep_id: String, current_time: GameTime) -> ShearingResult:
	var result := ShearingResult.new(); result.sheep_id = sheep_id; var sheep := repository.get_sheep(sheep_id)
	if not wool.is_ready_to_shear(sheep): result.error = "Sheep is not eligible and ready to shear."; return result
	var phenotype := PhenotypeResolver.resolve(sheep.genome); result.wool_color = phenotype.wool_color; result.wool_texture = phenotype.wool_texture; result.wool_length = phenotype.wool_length
	sheep.wool_growth = 0.0; var event := SheepLifeEvent.new(); event.event_type = SheepLifeEvent.Type.SHEARED; event.time_marker = current_time.total_minutes; history.record_event(sheep_id, event)
	if history.get_events_by_type(sheep_id, SheepLifeEvent.Type.FIRST_SHEAR).is_empty(): event.event_type = SheepLifeEvent.Type.FIRST_SHEAR; history.record_event(sheep_id, event)
	result.success = true; return result
