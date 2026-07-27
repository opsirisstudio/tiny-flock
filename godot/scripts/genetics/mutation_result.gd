class_name MutationResult
extends RefCounted

var did_mutate := false
var locus_id := ""
var previous_alleles: Array[String] = []
var resulting_alleles: Array[String] = []
func to_dictionary() -> Dictionary: return {"did_mutate":did_mutate, "locus_id":locus_id, "previous_alleles":previous_alleles.duplicate(), "resulting_alleles":resulting_alleles.duplicate()}
