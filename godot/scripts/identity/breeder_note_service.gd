class_name BreederNoteService
extends RefCounted

var repository: FlockRepository
func _init(value: FlockRepository) -> void: repository = value
func add_note(sheep_id: String, text: String, created_marker: int, note_id: String = "") -> String:
	var sheep := repository.get_sheep(sheep_id); var clean := text.strip_edges()
	if sheep == null or clean.is_empty(): return ""
	var note := BreederNote.new(); note.note_id = note_id if not note_id.is_empty() else "%s-note-%d" % [sheep_id, sheep.next_note_number]; sheep.next_note_number += 1
	if sheep.breeder_notes.any(func(existing: BreederNote) -> bool: return existing.note_id == note.note_id): return ""
	note.created_marker = created_marker; note.text = clean; sheep.breeder_notes.append(note); return note.note_id
func remove_note(sheep_id: String, note_id: String) -> bool:
	var sheep := repository.get_sheep(sheep_id)
	if sheep == null: return false
	for index: int in sheep.breeder_notes.size():
		if sheep.breeder_notes[index].note_id == note_id: sheep.breeder_notes.remove_at(index); return true
	return false
func list_notes(sheep_id: String) -> Array[BreederNote]:
	var result: Array[BreederNote] = []; var sheep := repository.get_sheep(sheep_id)
	if sheep != null:
		for note: BreederNote in sheep.breeder_notes: result.append(BreederNote.from_dictionary(note.to_dictionary()))
	return result
