class_name SheepHistoryService
extends RefCounted

var repository: FlockRepository
func _init(value: FlockRepository) -> void: repository = value
func record_event(sheep_id: String, event: SheepLifeEvent) -> bool:
	var sheep := repository.get_sheep(sheep_id)
	if sheep == null or event == null: return false
	sheep.life_events.append(event.duplicate_event()); return true
func get_events(sheep_id: String) -> Array[SheepLifeEvent]:
	var result: Array[SheepLifeEvent] = []; var sheep := repository.get_sheep(sheep_id)
	if sheep != null:
		for event: SheepLifeEvent in sheep.life_events: result.append(event.duplicate_event())
	return result
func get_events_by_type(sheep_id: String, type: SheepLifeEvent.Type) -> Array[SheepLifeEvent]:
	var result: Array[SheepLifeEvent] = []
	for event: SheepLifeEvent in get_events(sheep_id):
		if event.event_type == type: result.append(event)
	return result
func get_recent_events(sheep_id: String, limit: int) -> Array[SheepLifeEvent]:
	var events := get_events(sheep_id)
	var result: Array[SheepLifeEvent] = []
	for index: int in range(maxi(0, events.size() - maxi(0, limit)), events.size()): result.append(events[index])
	return result
