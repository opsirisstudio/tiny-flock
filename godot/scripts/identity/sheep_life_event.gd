class_name SheepLifeEvent
extends Resource

enum Type { BORN, FIRST_FEEDING, FIRST_SHEAR, FIRST_BREEDING, OFFSPRING_BORN, BECAME_JUVENILE, BECAME_ADULT, BECAME_ELDER, ARCHIVED_TO_BARN, RETURNED_FROM_BARN, MARKED_FAVORITE, UNMARKED_FAVORITE, MUTATION_DISCOVERED, GENETIC_TRAIT_CONFIRMED, ASSIGNED_ELDER_ROLE, BREEDER_NOTE_ADDED, BREEDING, SHEARED, PREGNANCY_STARTED, BIRTH_GIVEN, FED, PETTED, GROOMED, WASHED, TREAT_GIVEN }
@export var event_type: Type = Type.BORN
@export var time_marker := 0
@export var related_sheep_ids: Array[String] = []
@export var metadata: Dictionary = {}

func duplicate_event() -> SheepLifeEvent:
	var copy := SheepLifeEvent.new(); copy.event_type = event_type; copy.time_marker = time_marker; copy.related_sheep_ids = related_sheep_ids.duplicate(); copy.metadata = metadata.duplicate(true); return copy
func to_dictionary() -> Dictionary:
	return {"event_type":event_type, "time_marker":time_marker, "related_sheep_ids":related_sheep_ids.duplicate(), "metadata":metadata.duplicate(true)}
static func from_dictionary(data: Dictionary) -> SheepLifeEvent:
	var event := SheepLifeEvent.new(); event.event_type = int(data.get("event_type", -1)) as Type; event.time_marker = int(data.get("time_marker", 0))
	for id: Variant in data.get("related_sheep_ids", []): event.related_sheep_ids.append(str(id))
	event.metadata = (data.get("metadata", {}) as Dictionary).duplicate(true); return event
