class_name GeneticKnowledgeRecord
extends Resource

enum State { UNKNOWN, SUSPECTED, CONFIRMED, GENOTYPED }

@export var sheep_id := ""
@export var locus_id := ""
@export var knowledge_state: State = State.UNKNOWN
@export var known_alleles: Array[String] = []

func validate() -> bool:
	if sheep_id.is_empty() or not GeneRegistry.LOCI.has(locus_id):
		return false
	if knowledge_state < State.UNKNOWN or knowledge_state > State.GENOTYPED:
		return false
	if known_alleles.is_empty():
		return knowledge_state != State.GENOTYPED
	return knowledge_state == State.GENOTYPED and GeneRegistry.is_valid_pair(locus_id, known_alleles)

func to_dictionary() -> Dictionary:
	return {"sheep_id": sheep_id, "locus_id": locus_id, "knowledge_state": knowledge_state, "known_alleles": known_alleles.duplicate()}

static func from_dictionary(data: Dictionary) -> GeneticKnowledgeRecord:
	var record := GeneticKnowledgeRecord.new()
	record.sheep_id = str(data.get("sheep_id", ""))
	record.locus_id = str(data.get("locus_id", ""))
	record.knowledge_state = int(data.get("knowledge_state", State.UNKNOWN)) as State
	var alleles: Array = data.get("known_alleles", [])
	for allele: Variant in alleles: record.known_alleles.append(str(allele))
	return record
