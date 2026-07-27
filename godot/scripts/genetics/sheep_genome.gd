class_name SheepGenome
extends Resource

@export var loci: Dictionary = {}

func _init(initial_loci: Dictionary = {}) -> void:
	for locus: String in initial_loci:
		set_pair(locus, initial_loci[locus])

func set_pair(locus: String, pair: Array) -> void:
	assert(GeneRegistry.is_valid_pair(locus, pair), "Invalid allele pair for locus %s: %s" % [locus, pair])
	loci[locus] = GeneticUtils.normalized_pair(pair)

func get_pair(locus: String) -> Array[String]:
	assert(loci.has(locus), "Genome is missing locus %s" % locus)
	var pair: Array = loci[locus]
	return [str(pair[0]), str(pair[1])]

func validate(require_complete: bool = true) -> bool:
	if require_complete and loci.size() != GeneRegistry.LOCI.size():
		return false
	for locus: String in loci:
		if not GeneRegistry.is_valid_pair(locus, loci[locus]):
			return false
	return true

func duplicate_genome() -> SheepGenome:
	return SheepGenome.new(loci.duplicate(true))

func to_text() -> String:
	var lines: PackedStringArray = []
	for locus: String in GeneRegistry.locus_ids():
		if loci.has(locus):
			lines.append("%s: %s/%s" % [locus, loci[locus][0], loci[locus][1]])
	return "\n".join(lines)
