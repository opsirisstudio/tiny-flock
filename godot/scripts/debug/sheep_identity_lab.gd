extends Control

@onready var sheep_select: OptionButton = %SheepSelect
@onready var details: TextEdit = %Details
@onready var note_input: LineEdit = %NoteInput
var repository := FlockRepository.new()
var ids: Array[String] = []

func _ready() -> void:
	for founder: SheepRecord in SheepFactory.founders(): repository.add_sheep(founder)
	for sheep: SheepRecord in repository.all_sheep(): ids.append(sheep.sheep_id); sheep_select.add_item(sheep.sheep_name)
	_show_selected()
func _on_sheep_selected(_index: int) -> void: _show_selected()
func _on_add_note_pressed() -> void:
	if ids.is_empty(): return
	BreederNoteService.new(repository).add_note(ids[sheep_select.selected], note_input.text, Time.get_unix_time_from_system()); note_input.clear(); _show_selected()
func _show_selected() -> void:
	if ids.is_empty(): return
	var sheep := repository.get_sheep(ids[sheep_select.selected]); var profile := sheep.personality
	var history := SheepHistoryService.new(repository); var breeding := BreedingHistoryService.new(repository); var notes := BreederNoteService.new(repository)
	details.text = "TEMPERAMENT\n%s\n\nTRAITS\n%s\n\nFOOD\nFavorite: %s  Disliked: %s\n\nBONDING\n%s\n\nELDER AFFINITIES\n%s\nBest: %s\n\nLIFE EVENTS\n%s\n\nBREEDING\nMates: %d  Offspring: %d\n\nLEGACY\n%s\n\nNOTES\n%s" % [profile.temperament, profile.traits(), profile.favorite_food, profile.disliked_food, BondingResolver.resolve(profile), ElderRoleAffinityResolver.get_elder_role_affinities(profile), SheepRecord.ElderRole.keys()[ElderRoleAffinityResolver.get_best_elder_role(profile)], history.get_events(sheep.sheep_id).map(func(event: SheepLifeEvent) -> String: return SheepLifeEvent.Type.keys()[event.event_type]), breeding.get_unique_mate_count(sheep.sheep_id), breeding.get_breeding_count(sheep.sheep_id), sheep.legacy_tags.map(func(tag: SheepRecord.LegacyTag) -> String: return SheepRecord.LegacyTag.keys()[tag]), notes.list_notes(sheep.sheep_id).map(func(note: BreederNote) -> String: return note.text)]
