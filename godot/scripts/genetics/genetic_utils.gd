class_name GeneticUtils
extends RefCounted

static func normalized_pair(pair: Array) -> Array[String]:
	var result: Array[String] = [str(pair[0]), str(pair[1])]
	result.sort()
	return result

static func pair_key(pair: Array) -> String:
	return "/".join(normalized_pair(pair))

static func count_allele(pair: Array, allele: String) -> int:
	return pair.count(allele)
