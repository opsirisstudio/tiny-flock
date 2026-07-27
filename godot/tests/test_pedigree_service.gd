class_name TestPedigreeService
extends RefCounted

static func run() -> void:
	var repository := FlockRepository.new()
	for id: String in ["A","B","E","G"]: assert(repository.add_sheep(_record(id, "", "", 0)))
	for data: Array in [["C","A","B",1], ["D","A","B",1], ["F","C","E",2], ["H","D","G",2], ["I","F","H",3]]:
		assert(repository.add_sheep(_record(data[0], data[1], data[2], data[3])))
	var service := PedigreeService.new(repository)
	assert(_ids(service.get_parents("C")) == ["A","B"])
	assert(_ids(service.get_children("A")) == ["C","D"])
	assert(_ids(service.get_siblings("C")) == ["D"])
	assert(_ids(service.get_ancestors("I")) == ["A","B","E","G","C","D","F","H"])
	assert(_ids(service.get_descendants("A")) == ["C","D","F","H","I"])
	assert(_ids(service.get_ancestors("I", 1)) == ["F","H"])
	repository.get_sheep("A").mother_id = "I"
	assert(service.get_ancestors("I").size() == 8)
	assert(service.get_parents("missing").is_empty())

static func _record(id: String, mother: String, father: String, generation: int) -> SheepRecord:
	var sheep := SheepRecord.new(); sheep.sheep_id = id; sheep.sheep_name = id; sheep.mother_id = mother; sheep.father_id = father; sheep.generation = generation; sheep.genome = SheepFactory.default_genome(); return sheep

static func _ids(records: Array[SheepRecord]) -> Array[String]:
	var result: Array[String] = []
	for sheep: SheepRecord in records: result.append(sheep.sheep_id)
	return result
