extends Control

@onready var filter_select: OptionButton = %FilterSelect
@onready var sheep_list: ItemList = %SheepList
@onready var elder_count_label: Label = %ElderCount
@onready var details: TextEdit = %Details
var repository := FlockRepository.new()
var visible_ids: Array[String] = []

func _ready() -> void:
	filter_select.add_item("All", -1)
	filter_select.add_item("Active Flock", SheepRecord.Location.ACTIVE_FLOCK)
	filter_select.add_item("Active Elder", SheepRecord.Location.ACTIVE_ELDER)
	filter_select.add_item("Barn Archive", SheepRecord.Location.BARN_ARCHIVE)
	for founder: SheepRecord in SheepFactory.founders(): repository.add_sheep(founder)
	var elder := SheepFactory.create_lamb(repository.get_sheep("founder-clover"), repository.get_sheep("founder-biscuit"), BreedingEngine.new(404, false), "Debug Elder")
	elder.sheep_id = "debug-elder"; elder.age_stage = SheepRecord.AgeStage.ELDER; elder.elder_role = SheepRecord.ElderRole.STORYKEEPER
	repository.add_sheep(elder)
	_refresh()

func _on_filter_item_selected(_index: int) -> void:
	_refresh()

func _on_sheep_selected(index: int) -> void:
	if index >= 0 and index < visible_ids.size(): _show_details(visible_ids[index])

func _on_archive_pressed() -> void:
	var id := _selected_id()
	if id.is_empty(): return
	if not repository.archive_sheep(id): details.text = "ERROR: %s" % repository.last_error
	_refresh(id)

func _on_activate_elder_pressed() -> void:
	var id := _selected_id()
	if id.is_empty(): return
	if not repository.activate_elder(id): details.text = "ERROR: %s" % repository.last_error
	_refresh(id)

func _on_favorite_pressed() -> void:
	var id := _selected_id(); var sheep := repository.get_sheep(id)
	if sheep == null: return
	repository.set_favorite(id, not sheep.favorite)
	_refresh(id)

func _refresh(reselect_id: String = "") -> void:
	sheep_list.clear(); visible_ids.clear()
	var filter_id := filter_select.get_selected_id()
	for sheep: SheepRecord in repository.all_sheep():
		if filter_id >= 0 and sheep.location != filter_id: continue
		visible_ids.append(sheep.sheep_id)
		sheep_list.add_item("%s%s — %s" % ["★ " if sheep.favorite else "", sheep.sheep_name, _location_name(sheep.location)])
	elder_count_label.text = "Active elders: %d / %d" % [repository.active_elder_count(), FlockRepository.MAX_ACTIVE_ELDERS]
	if not reselect_id.is_empty() and reselect_id in visible_ids:
		var index := visible_ids.find(reselect_id); sheep_list.select(index); _show_details(reselect_id)
	elif not visible_ids.is_empty(): sheep_list.select(0); _show_details(visible_ids[0])
	else: details.text = "No sheep match this filter."

func _show_details(id: String) -> void:
	var sheep := repository.get_sheep(id)
	if sheep == null: details.text = "ERROR: Record no longer exists."; return
	var parents := PedigreeService.new(repository).get_parents(id)
	var parent_names: Array[String] = []
	for parent: SheepRecord in parents: parent_names.append("%s (%s)" % [parent.sheep_name, parent.sheep_id])
	details.text = "ID: %s\nName: %s\nGeneration: %d\nAge: %s\nLocation: %s\nElder role: %s\nFavorite: %s\nParents: %s\n\nPHENOTYPE\n%s" % [sheep.sheep_id, sheep.sheep_name, sheep.generation, SheepRecord.AgeStage.keys()[sheep.age_stage], _location_name(sheep.location), SheepRecord.ElderRole.keys()[sheep.elder_role], sheep.favorite, parent_names, PhenotypeResolver.resolve(sheep.genome).to_text()]

func _selected_id() -> String:
	var selected := sheep_list.get_selected_items()
	if selected.is_empty(): details.text = "ERROR: Select a sheep first."; return ""
	return visible_ids[selected[0]]

func _location_name(location: SheepRecord.Location) -> String:
	return SheepRecord.Location.keys()[location].to_pascal_case()
