class_name BreedingHistoryService
extends RefCounted

var repository: FlockRepository
var pedigree: PedigreeService
func _init(value: FlockRepository) -> void: repository = value; pedigree = PedigreeService.new(value)
func get_offspring(sheep_id: String) -> Array[SheepRecord]: return pedigree.get_children(sheep_id)
func get_mates(sheep_id: String) -> Array[SheepRecord]:
	var by_id := {}
	for child: SheepRecord in get_offspring(sheep_id):
		var partner_id := child.father_id if child.mother_id == sheep_id else child.mother_id; var partner := repository.get_sheep(partner_id)
		if partner != null: by_id[partner_id] = partner
	var result: Array[SheepRecord] = []
	for mate: SheepRecord in by_id.values(): result.append(mate)
	result.sort_custom(func(a: SheepRecord, b: SheepRecord) -> bool: return a.sheep_id < b.sheep_id); return result
func get_offspring_with_partner(sheep_id: String, partner_id: String) -> Array[SheepRecord]:
	var result: Array[SheepRecord] = []
	for child: SheepRecord in get_offspring(sheep_id):
		if (child.mother_id == sheep_id and child.father_id == partner_id) or (child.father_id == sheep_id and child.mother_id == partner_id): result.append(child)
	return result
func get_breeding_count(sheep_id: String) -> int: return get_offspring(sheep_id).size()
func get_unique_mate_count(sheep_id: String) -> int: return get_mates(sheep_id).size()
