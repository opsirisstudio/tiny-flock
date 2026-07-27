class_name TestPhenotypeResolver
extends RefCounted

static func run() -> void:
	_test_colors_and_tone()
	_test_wool_structure()
	_test_body_structure()
	_test_conditional_traits()
	_test_rare_traits()
	_test_order_independence_and_determinism()

static func _p(overrides: Dictionary) -> SheepPhenotype:
	return PhenotypeResolver.resolve(SheepFactory.default_genome(overrides))

static func _test_colors_and_tone() -> void:
	assert(_p({"PNT":["B","B"]}).point_color == "black")
	assert(_p({"PNT":["B","b"]}).point_color == "black")
	assert(_p({"PNT":["b","b"]}).point_color == "chocolate")
	assert(_p({"PNT":["B","b"], "PDL":["d","d"]}).point_color == "silver")
	assert(_p({"PNT":["b","b"], "PDL":["d","d"]}).point_color == "caramel")
	var wool_cases := [["W", "W", "white"], ["W", "D", "fawn"], ["D", "D", "brown"]]
	for case: Array in wool_cases:
		assert(_p({"WBC":[case[0], case[1]]}).wool_color == case[2])
	var diluted_cases := [["W", "W", "cream"], ["W", "D", "champagne"], ["D", "D", "taupe"]]
	for case: Array in diluted_cases:
		assert(_p({"WBC":[case[0], case[1]], "WDL":["d","d"]}).wool_color == case[2])
	var tone_cases := [["C","C","strong_cool"], ["C","N","cool"], ["N","N","neutral"], ["N","W","warm"], ["W","W","strong_warm"], ["C","W","neutral"]]
	for case: Array in tone_cases:
		assert(_p({"WRM":[case[0], case[1]]}).wool_tone == case[2])

static func _test_wool_structure() -> void:
	for case: Array in [["C","C","tight_curls"], ["C","c","soft_waves"], ["c","c","straight"]]: assert(_p({"CRL":[case[0],case[1]]}).wool_texture == case[2])
	for case: Array in [["F","F","cloud"], ["F","f","fluffy"], ["f","f","sleek"]]: assert(_p({"FLF":[case[0],case[1]]}).wool_volume == case[2])
	for case: Array in [["L","L","long"], ["L","s","medium"], ["s","s","short"]]: assert(_p({"LEN":[case[0],case[1]]}).wool_length == case[2])

static func _test_body_structure() -> void:
	for case: Array in [["S","S","petite"], ["S","L","standard"], ["L","L","large"]]: assert(_p({"SIZ":[case[0],case[1]]}).body_size == case[2])
	for case: Array in [["N","N","slim"], ["N","R","standard"], ["R","R","round"]]: assert(_p({"BLD":[case[0],case[1]]}).body_build == case[2])
	for case: Array in [["L","L","long"], ["L","s","standard"], ["s","s","stubby"]]: assert(_p({"LEG":[case[0],case[1]]}).leg_length == case[2])
	for case: Array in [["S","S","small"], ["S","L","medium"], ["L","L","large"]]: assert(_p({"ERS":[case[0],case[1]]}).ear_size == case[2])

static func _test_conditional_traits() -> void:
	assert(_p({"PPG":["S","p"], "PPT":["M","L"]}).point_patterns.is_empty())
	var points := _p({"PPG":["p","p"], "PPT":["M","L"]}).point_patterns
	assert(points.has("mask") and points.has("blaze"))
	assert(_p({"WPG":["S","p"], "WPT":["P","R"]}).wool_patterns.is_empty())
	var wool := _p({"WPG":["p","p"], "WPT":["P","R"]}).wool_patterns
	assert(wool.has("patches") and wool.has("roan"))
	assert(not _p({"HRN":["N","h"], "HSH":["C","S"]}).has_horns)
	assert(_p({"HRN":["N","h"], "HSH":["C","S"]}).horn_shape == "none")
	var horned := _p({"HRN":["h","h"], "HSH":["C","S"]})
	assert(horned.has_horns and horned.horn_shape == "large_spiral_curl")

static func _test_rare_traits() -> void:
	assert(not _p({"LAV":["L","l"]}).lavender_expressed)
	assert(_p({"LAV":["l","l"]}).lavender_expressed)
	assert(not _p({"ROS":["R","r"]}).rose_expressed)
	assert(_p({"ROS":["r","r"]}).rose_expressed)
	assert(_p({"STR":["S","S"]}).star_mark == "none")
	assert(_p({"STR":["S","s"]}).star_mark == "small")
	assert(_p({"STR":["s","s"]}).star_mark == "large")

static func _test_order_independence_and_determinism() -> void:
	var cases := [{"PNT":["B","b"]}, {"WBC":["W","D"]}, {"BLD":["N","R"]}, {"FAC":["R","B"]}, {"WRM":["C","N"]}, {"PPG":["p","p"], "PPT":["M","L"]}]
	for overrides: Dictionary in cases:
		var reversed := overrides.duplicate(true)
		for locus: String in reversed: reversed[locus] = [reversed[locus][1], reversed[locus][0]]
		assert(_p(overrides).to_text() == _p(reversed).to_text())
	var genome := SheepFactory.default_genome({"FAC":["R","B"]})
	assert(PhenotypeResolver.resolve(genome).to_text() == PhenotypeResolver.resolve(genome).to_text())
