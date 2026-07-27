class_name BreederNote
extends Resource

@export var note_id := ""
@export var created_marker := 0
@export var text := ""
func to_dictionary() -> Dictionary: return {"note_id":note_id, "created_marker":created_marker, "text":text}
static func from_dictionary(data: Dictionary) -> BreederNote:
	var note := BreederNote.new(); note.note_id = str(data.get("note_id", "")); note.created_marker = int(data.get("created_marker", 0)); note.text = str(data.get("text", "")); return note
