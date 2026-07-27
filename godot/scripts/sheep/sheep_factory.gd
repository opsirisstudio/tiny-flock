class_name SheepFactory
extends RefCounted

static var _next_lamb_id := 1

static func founders() -> Array[SheepRecord]:
	return [
		_founder("founder-clover", "Clover", SheepRecord.Sex.FEMALE, {"PNT":["B","b"], "WBC":["W","W"], "CRL":["C","c"], "PPG":["S","p"], "SIZ":["S","S"], "EAR":["U","S"]}),
		_founder("founder-biscuit", "Biscuit", SheepRecord.Sex.MALE, {"PNT":["b","b"], "PDL":["D","d"], "WBC":["W","D"], "WRM":["N","W"], "CRL":["C","c"], "EAR":["F","U"], "LAV":["L","l"], "BLD":["N","R"]}),
		_founder("founder-poppy", "Poppy", SheepRecord.Sex.FEMALE, {"PDL":["d","d"], "WDL":["D","d"], "WBC":["W","D"], "WPG":["p","p"], "WPT":["P","S"], "FLF":["F","F"], "SIZ":["S","L"], "HRN":["N","h"]}),
		_founder("founder-bean", "Bean", SheepRecord.Sex.MALE, {"PNT":["B","b"], "WBC":["D","D"], "WDL":["d","d"], "CRL":["c","c"], "PPG":["p","p"], "PPT":["M","L"], "BLD":["R","R"], "STR":["S","s"]}),
	]

static func create_lamb(mother: SheepRecord, father: SheepRecord, engine: BreedingEngine, lamb_name: String = "Generated Lamb") -> SheepRecord:
	assert(mother.genome != null and father.genome != null, "Parents require genomes")
	var lamb := SheepRecord.new()
	lamb.sheep_id = "lamb-%d-%d-%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec(), _next_lamb_id]
	_next_lamb_id += 1
	lamb.sheep_name = lamb_name
	lamb.sex = SheepRecord.Sex.FEMALE if engine.rng.randi_range(0, 1) == 0 else SheepRecord.Sex.MALE
	lamb.mother_id = mother.sheep_id
	lamb.father_id = father.sheep_id
	lamb.generation = maxi(mother.generation, father.generation) + 1
	lamb.age_stage = SheepRecord.AgeStage.LAMB
	lamb.genome = engine.breed_genomes(mother.genome, father.genome)
	var personality_rng := engine.rng
	if mother.personality != null and father.personality != null: lamb.personality = PersonalityGenerator.generate_offspring_personality(mother.personality, father.personality, personality_rng)
	else: lamb.personality = PersonalityGenerator.generate_founder_personality(personality_rng)
	if engine.last_mutation_result.did_mutate:
		lamb.add_legacy_tag(SheepRecord.LegacyTag.MUTATION_FOUNDER)
		var event := SheepLifeEvent.new(); event.event_type = SheepLifeEvent.Type.MUTATION_DISCOVERED; event.related_sheep_ids = [mother.sheep_id, father.sheep_id]; event.metadata = engine.last_mutation_result.to_dictionary(); lamb.life_events.append(event)
	return lamb

static func default_genome(overrides: Dictionary = {}) -> SheepGenome:
	var values := {
		"PNT":["B","B"], "PDL":["D","D"], "WBC":["W","W"], "WDL":["D","D"], "WRM":["N","N"], "GRY":["g","g"],
		"CRL":["C","c"], "FLF":["F","f"], "LEN":["L","s"], "PPG":["S","S"], "PPT":["M","M"],
		"WPG":["S","S"], "WPT":["P","P"], "AMT":["L","H"], "SIZ":["S","L"], "BLD":["N","R"], "LEG":["L","s"],
		"FAC":["N","R"], "EAR":["U","S"], "ERS":["S","L"], "HRN":["N","N"], "HSH":["T","C"],
		"LAV":["L","L"], "ROS":["R","R"], "STR":["S","S"]
	}
	for locus: String in overrides: values[locus] = overrides[locus]
	return SheepGenome.new(values)

static func _founder(id: String, name: String, founder_sex: int, overrides: Dictionary) -> SheepRecord:
	var sheep := SheepRecord.new()
	sheep.sheep_id = id
	sheep.sheep_name = name
	sheep.sex = founder_sex
	sheep.generation = 0
	sheep.add_legacy_tag(SheepRecord.LegacyTag.FOUNDER)
	sheep.age_stage = SheepRecord.AgeStage.ADULT
	sheep.genome = default_genome(overrides)
	var rng := RandomNumberGenerator.new(); rng.seed = id.hash(); sheep.personality = PersonalityGenerator.generate_founder_personality(rng)
	return sheep
