class_name RelationshipService
extends RefCounted

enum Classification { SELF, PARENT_CHILD, FULL_SIBLING, HALF_SIBLING, OTHER_RELATIVE, UNRELATED, UNKNOWN }
var repository: FlockRepository
var pedigree: PedigreeService
func _init(value: FlockRepository) -> void: repository = value; pedigree = PedigreeService.new(value)
func classify(a: SheepRecord, b: SheepRecord) -> Classification:
	if a == null or b == null or not repository.has_sheep(a.sheep_id) or not repository.has_sheep(b.sheep_id): return Classification.UNKNOWN
	if a.sheep_id == b.sheep_id: return Classification.SELF
	if a.sheep_id in [b.mother_id, b.father_id] or b.sheep_id in [a.mother_id, a.father_id]: return Classification.PARENT_CHILD
	var same_mother := not a.mother_id.is_empty() and a.mother_id == b.mother_id; var same_father := not a.father_id.is_empty() and a.father_id == b.father_id
	if same_mother and same_father: return Classification.FULL_SIBLING
	if same_mother or same_father: return Classification.HALF_SIBLING
	for ancestor: SheepRecord in pedigree.get_ancestors(a.sheep_id):
		if ancestor.sheep_id == b.sheep_id: return Classification.PARENT_CHILD
		for other: SheepRecord in pedigree.get_ancestors(b.sheep_id):
			if ancestor.sheep_id == other.sheep_id: return Classification.OTHER_RELATIVE
	for ancestor: SheepRecord in pedigree.get_ancestors(b.sheep_id):
		if ancestor.sheep_id == a.sheep_id: return Classification.PARENT_CHILD
	return Classification.UNRELATED
func get_relationship_warning(a: SheepRecord, b: SheepRecord) -> Classification: return classify(a, b)
