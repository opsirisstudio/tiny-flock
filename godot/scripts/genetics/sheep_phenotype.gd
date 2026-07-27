class_name SheepPhenotype
extends Resource

@export var point_color := ""
@export var wool_color := ""
@export var wool_tone := ""
@export var graying_strength := "none"
@export var wool_texture := ""
@export var wool_volume := ""
@export var wool_length := ""
@export var point_patterns: Array[String] = []
@export var wool_patterns: Array[String] = []
@export var pattern_amount := ""
@export var body_size := ""
@export var body_build := ""
@export var leg_length := ""
@export var face_shape := ""
@export var ear_shape := ""
@export var ear_size := ""
@export var has_horns := false
@export var horn_shape := "none"
@export var lavender_expressed := false
@export var rose_expressed := false
@export var star_mark := "none"

func to_text() -> String:
	return "Points: %s\nWool: %s (%s)\nGraying: %s\nTexture: %s / %s / %s\nPatterns: point=%s wool=%s amount=%s\nBody: %s / %s; legs=%s; face=%s\nEars: %s / %s\nHorns: %s (%s)\nRare: lavender=%s rose=%s star=%s" % [point_color, wool_color, wool_tone, graying_strength, wool_texture, wool_volume, wool_length, point_patterns, wool_patterns, pattern_amount, body_size, body_build, leg_length, face_shape, ear_shape, ear_size, has_horns, horn_shape, lavender_expressed, rose_expressed, star_mark]
