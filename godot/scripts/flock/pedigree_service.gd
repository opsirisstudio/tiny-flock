class_name PedigreeService
extends RefCounted

var repository: FlockRepository

func _init(flock_repository: FlockRepository) -> void:
	repository = flock_repository

func get_parents(sheep_id: String) -> Array[SheepRecord]:
	var sheep := repository.get_sheep(sheep_id)
	if sheep == null: return []
	var result: Array[SheepRecord] = []
	for parent_id: String in [sheep.mother_id, sheep.father_id]:
		var parent := repository.get_sheep(parent_id)
		if parent != null and parent not in result: result.append(parent)
	return _sorted(result)

func get_children(sheep_id: String) -> Array[SheepRecord]:
	var result: Array[SheepRecord] = []
	if not repository.has_sheep(sheep_id): return result
	for sheep: SheepRecord in repository.all_sheep():
		if sheep.mother_id == sheep_id or sheep.father_id == sheep_id: result.append(sheep)
	return _sorted(result)

func get_siblings(sheep_id: String) -> Array[SheepRecord]:
	var sheep := repository.get_sheep(sheep_id)
	if sheep == null: return []
	var result: Array[SheepRecord] = []
	for candidate: SheepRecord in repository.all_sheep():
		if candidate.sheep_id == sheep_id: continue
		var shares_mother := not sheep.mother_id.is_empty() and candidate.mother_id == sheep.mother_id
		var shares_father := not sheep.father_id.is_empty() and candidate.father_id == sheep.father_id
		if shares_mother or shares_father: result.append(candidate)
	return _sorted(result)

func get_ancestors(sheep_id: String, max_depth: int = -1) -> Array[SheepRecord]:
	if not repository.has_sheep(sheep_id) or max_depth == 0: return []
	var found: Dictionary = {}
	var visited: Dictionary = {sheep_id: true}
	var queue: Array[Dictionary] = [{"id":sheep_id, "depth":0}]
	while not queue.is_empty():
		var current: Dictionary = queue.pop_front()
		if max_depth >= 0 and int(current["depth"]) >= max_depth: continue
		for parent: SheepRecord in get_parents(str(current["id"])):
			if visited.has(parent.sheep_id): continue
			visited[parent.sheep_id] = true; found[parent.sheep_id] = parent
			queue.append({"id":parent.sheep_id, "depth":int(current["depth"]) + 1})
	return _sorted(_dictionary_values(found))

func get_descendants(sheep_id: String) -> Array[SheepRecord]:
	if not repository.has_sheep(sheep_id): return []
	var found: Dictionary = {}
	var visited: Dictionary = {sheep_id: true}
	var queue: Array[String] = [sheep_id]
	while not queue.is_empty():
		var current: String = queue.pop_front()
		for child: SheepRecord in get_children(current):
			if visited.has(child.sheep_id): continue
			visited[child.sheep_id] = true; found[child.sheep_id] = child; queue.append(child.sheep_id)
	return _sorted(_dictionary_values(found))

func _dictionary_values(values: Dictionary) -> Array[SheepRecord]:
	var result: Array[SheepRecord] = []
	for sheep: SheepRecord in values.values(): result.append(sheep)
	return result

func _sorted(records: Array[SheepRecord]) -> Array[SheepRecord]:
	records.sort_custom(func(a: SheepRecord, b: SheepRecord) -> bool:
		if a.generation == b.generation: return a.sheep_id < b.sheep_id
		return a.generation < b.generation)
	return records
