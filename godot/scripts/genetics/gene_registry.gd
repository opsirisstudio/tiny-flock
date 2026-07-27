class_name GeneRegistry
extends RefCounted

enum Category { POINT, WOOL_COLOR, WOOL_STRUCTURE, PATTERN, STRUCTURE, RARE }

const LOCI: Dictionary = {
	"PNT": {"name": "Point Color", "alleles": ["B", "b"], "style": "complete_dominance", "category": Category.POINT},
	"PDL": {"name": "Point Dilution", "alleles": ["D", "d"], "style": "recessive", "category": Category.POINT},
	"WBC": {"name": "Wool Base Color", "alleles": ["W", "D"], "style": "incomplete_dominance", "category": Category.WOOL_COLOR},
	"WDL": {"name": "Wool Dilution", "alleles": ["D", "d"], "style": "recessive", "category": Category.WOOL_COLOR},
	"WRM": {"name": "Wool Tone", "alleles": ["C", "N", "W"], "style": "additive", "category": Category.WOOL_COLOR},
	"GRY": {"name": "Graying", "alleles": ["G", "g"], "style": "dominant_age_dependent", "category": Category.WOOL_COLOR},
	"CRL": {"name": "Wool Texture", "alleles": ["C", "c"], "style": "incomplete_dominance", "category": Category.WOOL_STRUCTURE},
	"FLF": {"name": "Wool Volume", "alleles": ["F", "f"], "style": "incomplete_dominance", "category": Category.WOOL_STRUCTURE},
	"LEN": {"name": "Wool Length", "alleles": ["L", "s"], "style": "incomplete_dominance", "category": Category.WOOL_STRUCTURE},
	"PPG": {"name": "Point Pattern Presence", "alleles": ["S", "p"], "style": "recessive", "category": Category.PATTERN},
	"PPT": {"name": "Point Pattern Type", "alleles": ["M", "L", "E", "S"], "style": "codominant", "category": Category.PATTERN},
	"WPG": {"name": "Wool Pattern Presence", "alleles": ["S", "p"], "style": "recessive", "category": Category.PATTERN},
	"WPT": {"name": "Wool Pattern Type", "alleles": ["P", "S", "D", "R"], "style": "codominant", "category": Category.PATTERN},
	"AMT": {"name": "Pattern Amount", "alleles": ["L", "H"], "style": "additive", "category": Category.PATTERN},
	"SIZ": {"name": "Body Size", "alleles": ["S", "L"], "style": "additive", "category": Category.STRUCTURE},
	"BLD": {"name": "Body Build", "alleles": ["N", "R"], "style": "additive", "category": Category.STRUCTURE},
	"LEG": {"name": "Leg Length", "alleles": ["L", "s"], "style": "additive", "category": Category.STRUCTURE},
	"FAC": {"name": "Face Shape", "alleles": ["N", "R", "B"], "style": "blended", "category": Category.STRUCTURE},
	"EAR": {"name": "Ear Shape", "alleles": ["U", "S", "F"], "style": "dominance", "category": Category.STRUCTURE},
	"ERS": {"name": "Ear Size", "alleles": ["S", "L"], "style": "additive", "category": Category.STRUCTURE},
	"HRN": {"name": "Horn Presence", "alleles": ["N", "h"], "style": "recessive", "category": Category.STRUCTURE},
	"HSH": {"name": "Horn Shape", "alleles": ["T", "C", "S"], "style": "blended", "category": Category.STRUCTURE},
	"LAV": {"name": "Lavender", "alleles": ["L", "l"], "style": "recessive", "category": Category.RARE},
	"ROS": {"name": "Rose", "alleles": ["R", "r"], "style": "recessive", "category": Category.RARE},
	"STR": {"name": "Star Mark", "alleles": ["S", "s"], "style": "incomplete_dominance", "category": Category.RARE},
}

static func locus_ids() -> Array[String]:
	var result: Array[String] = []
	for locus: String in LOCI:
		result.append(locus)
	return result

static func is_valid_pair(locus: String, pair: Array) -> bool:
	if not LOCI.has(locus) or pair.size() != 2:
		return false
	var legal: Array = LOCI[locus]["alleles"]
	return pair[0] is String and pair[1] is String and pair[0] in legal and pair[1] in legal
