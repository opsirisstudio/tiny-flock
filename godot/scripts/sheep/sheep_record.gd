class_name SheepRecord
extends Resource

enum Sex { FEMALE, MALE }
enum AgeStage { LAMB, JUVENILE, ADULT, ELDER }
enum Location { ACTIVE_FLOCK, ACTIVE_ELDER, BARN_ARCHIVE }
enum ElderRole { NONE, NANNY, COMFORTER, GROOMER, SHEPHERD, FORAGER, STORYKEEPER }
enum LegacyTag { FOUNDER, MUTATION_FOUNDER, NOTABLE_BREEDER }

@export var sheep_id := ""
@export var sheep_name := ""
@export var sex: Sex = Sex.FEMALE
@export var mother_id := ""
@export var father_id := ""
@export var generation := 0
@export var age_stage: AgeStage = AgeStage.ADULT
@export var location: Location = Location.ACTIVE_FLOCK
@export var elder_role: ElderRole = ElderRole.NONE
@export var favorite := false
@export var legacy_tags: Array[LegacyTag] = []
@export var genome: SheepGenome
@export_range(0.0, 100.0) var hunger := 100.0
@export_range(0.0, 100.0) var cleanliness := 100.0
@export_range(0.0, 100.0) var happiness := 100.0
@export_range(0.0, 100.0) var bond := 0.0
@export_range(0.0, 100.0) var wool_growth := 0.0

func validate() -> bool:
	if sheep_id.is_empty() or genome == null or not genome.validate() or generation < 0:
		return false
	if sex < Sex.FEMALE or sex > Sex.MALE or age_stage < AgeStage.LAMB or age_stage > AgeStage.ELDER:
		return false
	if location < Location.ACTIVE_FLOCK or location > Location.BARN_ARCHIVE or elder_role < ElderRole.NONE or elder_role > ElderRole.STORYKEEPER:
		return false
	if location == Location.ACTIVE_ELDER and age_stage != AgeStage.ELDER:
		return false
	for tag: LegacyTag in legacy_tags:
		if tag < LegacyTag.FOUNDER or tag > LegacyTag.NOTABLE_BREEDER:
			return false
	return true

func has_legacy_tag(tag: LegacyTag) -> bool:
	return tag in legacy_tags

func add_legacy_tag(tag: LegacyTag) -> void:
	if tag not in legacy_tags: legacy_tags.append(tag)
