class_name ArchiveTransitionService
extends RefCounted

var repository: FlockRepository
var history: SheepHistoryService
var last_error := ""
func _init(value: FlockRepository) -> void: repository = value; history = SheepHistoryService.new(value)

func archive(sheep_id: String, current_time: GameTime) -> bool:
	last_error = ""
	var sheep := repository.get_sheep(sheep_id)
	var already_archived := sheep != null and sheep.location == SheepRecord.Location.BARN_ARCHIVE
	if not repository.archive_sheep(sheep_id): last_error = repository.last_error; return false
	if not already_archived:
		sheep.archived_at_game_minute = current_time.total_minutes
		_record(sheep_id, SheepLifeEvent.Type.ARCHIVED_TO_BARN, current_time)
	return true

func restore_to_flock(sheep_id: String, current_time: GameTime) -> bool:
	var sheep := repository.get_sheep(sheep_id)
	var was_archived := sheep != null and sheep.location == SheepRecord.Location.BARN_ARCHIVE
	last_error = ""
	if not repository.restore_to_flock(sheep_id): last_error = repository.last_error; return false
	if was_archived: _unfreeze(sheep, current_time); _record(sheep_id, SheepLifeEvent.Type.RETURNED_FROM_BARN, current_time)
	return true

func activate_elder(sheep_id: String, current_time: GameTime) -> bool:
	var sheep := repository.get_sheep(sheep_id)
	var was_archived := sheep != null and sheep.location == SheepRecord.Location.BARN_ARCHIVE
	last_error = ""
	if not repository.activate_elder(sheep_id): last_error = repository.last_error; return false
	if was_archived: _unfreeze(sheep, current_time); _record(sheep_id, SheepLifeEvent.Type.RETURNED_FROM_BARN, current_time)
	return true

func _record(sheep_id: String, type: SheepLifeEvent.Type, current_time: GameTime) -> void:
	var event := SheepLifeEvent.new(); event.event_type = type; event.time_marker = current_time.total_minutes
	history.record_event(sheep_id, event)

func _unfreeze(sheep: SheepRecord, current_time: GameTime) -> void:
	if sheep.archived_at_game_minute < 0: return
	var frozen_minutes := maxi(0, current_time.total_minutes - sheep.archived_at_game_minute)
	if frozen_minutes > 0:
		sheep.birth_game_minute += frozen_minutes
		if sheep.breeding_available_game_minute > sheep.archived_at_game_minute: sheep.breeding_available_game_minute += frozen_minutes
		if sheep.pregnancy != null: sheep.pregnancy.due_game_minute += frozen_minutes
	sheep.archived_at_game_minute = -1
