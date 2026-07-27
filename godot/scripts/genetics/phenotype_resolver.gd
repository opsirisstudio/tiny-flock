class_name PhenotypeResolver
extends RefCounted

static func resolve(genome: SheepGenome) -> SheepPhenotype:
	assert(genome.validate(), "Cannot resolve an incomplete or invalid genome")
	var p := SheepPhenotype.new()
	p.point_color = resolve_point_color(genome)
	p.wool_color = resolve_wool_base_color(genome)
	p.wool_tone = resolve_wool_tone(genome)
	p.graying_strength = resolve_graying(genome)
	p.wool_texture = resolve_wool_texture(genome)
	p.wool_volume = resolve_wool_volume(genome)
	p.wool_length = resolve_wool_length(genome)
	p.point_patterns = resolve_point_patterns(genome)
	p.wool_patterns = resolve_wool_patterns(genome)
	p.pattern_amount = resolve_pattern_amount(genome)
	p.body_size = resolve_body_size(genome)
	p.body_build = resolve_body_build(genome)
	p.leg_length = resolve_leg_length(genome)
	p.face_shape = resolve_face_shape(genome)
	p.ear_shape = resolve_ear_shape(genome)
	p.ear_size = resolve_ear_size(genome)
	p.has_horns = resolve_horn_presence(genome)
	p.horn_shape = resolve_horn_shape(genome)
	p.lavender_expressed = resolve_lavender(genome)
	p.rose_expressed = resolve_rose(genome)
	p.star_mark = resolve_star_mark(genome)
	return p

static func resolve_point_color(g: SheepGenome) -> String:
	var black := g.get_pair("PNT").has("B")
	var dilute := g.get_pair("PDL").count("d") == 2
	return ("silver" if dilute else "black") if black else ("caramel" if dilute else "chocolate")

static func resolve_wool_base_color(g: SheepGenome) -> String:
	var whites := g.get_pair("WBC").count("W")
	var base: String = ["brown", "fawn", "white"][whites]
	if g.get_pair("WDL").count("d") != 2:
		return base
	return {"white": "cream", "fawn": "champagne", "brown": "taupe"}[base]

static func resolve_wool_tone(g: SheepGenome) -> String:
	return _lookup(g, "WRM", {"C/C":"strong_cool", "C/N":"cool", "N/N":"neutral", "N/W":"warm", "W/W":"strong_warm", "C/W":"neutral"})

static func resolve_graying(g: SheepGenome) -> String:
	return ["none", "normal", "strong"][g.get_pair("GRY").count("G")]

static func resolve_wool_texture(g: SheepGenome) -> String:
	return ["straight", "soft_waves", "tight_curls"][g.get_pair("CRL").count("C")]

static func resolve_wool_volume(g: SheepGenome) -> String:
	return ["sleek", "fluffy", "cloud"][g.get_pair("FLF").count("F")]

static func resolve_wool_length(g: SheepGenome) -> String:
	return ["short", "medium", "long"][g.get_pair("LEN").count("L")]

static func resolve_point_patterns(g: SheepGenome) -> Array[String]:
	if g.get_pair("PPG").count("p") != 2: return []
	return _codominant(g.get_pair("PPT"), {"M":"mask", "L":"blaze", "E":"eye_patch", "S":"socks"})

static func resolve_wool_patterns(g: SheepGenome) -> Array[String]:
	if g.get_pair("WPG").count("p") != 2: return []
	return _codominant(g.get_pair("WPT"), {"P":"patches", "S":"speckles", "D":"saddle", "R":"roan"})

static func resolve_pattern_amount(g: SheepGenome) -> String:
	return ["minimal", "moderate", "extensive"][g.get_pair("AMT").count("H")]

static func resolve_body_size(g: SheepGenome) -> String:
	return ["petite", "standard", "large"][g.get_pair("SIZ").count("L")]

static func resolve_body_build(g: SheepGenome) -> String:
	return ["slim", "standard", "round"][g.get_pair("BLD").count("R")]

static func resolve_leg_length(g: SheepGenome) -> String:
	return ["stubby", "standard", "long"][g.get_pair("LEG").count("L")]

static func resolve_face_shape(g: SheepGenome) -> String:
	return _lookup(g, "FAC", {"N/N":"narrow", "N/R":"soft", "R/R":"round", "B/R":"baby_round", "B/B":"baby", "B/N":"small_muzzle"})

static func resolve_ear_shape(g: SheepGenome) -> String:
	var pair := g.get_pair("EAR")
	if pair.has("F"): return "floppy"
	if pair.has("S"): return "side"
	return "upright"

static func resolve_ear_size(g: SheepGenome) -> String:
	return ["small", "medium", "large"][g.get_pair("ERS").count("L")]

static func resolve_horn_presence(g: SheepGenome) -> bool:
	return g.get_pair("HRN").count("h") == 2

static func resolve_horn_shape(g: SheepGenome) -> String:
	if not resolve_horn_presence(g): return "none"
	return _lookup(g, "HSH", {"T/T":"tiny", "C/C":"curled", "S/S":"spiral", "C/T":"small_curled", "C/S":"large_spiral_curl", "S/T":"small_spiral"})

static func resolve_lavender(g: SheepGenome) -> bool:
	return g.get_pair("LAV").count("l") == 2

static func resolve_rose(g: SheepGenome) -> bool:
	return g.get_pair("ROS").count("r") == 2

static func resolve_star_mark(g: SheepGenome) -> String:
	return ["none", "small", "large"][g.get_pair("STR").count("s")]

static func _lookup(g: SheepGenome, locus: String, values: Dictionary) -> String:
	var key := GeneticUtils.pair_key(g.get_pair(locus))
	assert(values.has(key), "No phenotype mapping for %s %s" % [locus, key])
	return values[key]

static func _codominant(pair: Array[String], names: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for allele: String in pair:
		var value: String = names[allele]
		if value not in result: result.append(value)
	return result
