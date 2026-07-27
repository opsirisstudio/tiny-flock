extends Control

@onready var mother_select: OptionButton = %MotherSelect
@onready var father_select: OptionButton = %FatherSelect
@onready var output: TextEdit = %Output
var sheep: Array[SheepRecord] = []
var engine := BreedingEngine.new(2026, false)
var lamb_count := 0

func _ready() -> void:
	sheep = SheepFactory.founders()
	for founder: SheepRecord in sheep:
		mother_select.add_item(founder.sheep_name)
		father_select.add_item(founder.sheep_name)
	father_select.select(1)
	_show_parents()

func _on_breed_pressed() -> void:
	breed_many(1)

func _on_breed_ten_pressed() -> void:
	breed_many(10)

func breed_many(count: int) -> void:
	if mother_select.selected == father_select.selected:
		output.text = "ERROR: Select two distinct founder records before breeding."
		return
	var mother := sheep[mother_select.selected]
	var father := sheep[father_select.selected]
	var sections: PackedStringArray = []
	for _index: int in count:
		lamb_count += 1
		var lamb := SheepFactory.create_lamb(mother, father, engine, 0, "Generated Lamb #%d" % lamb_count)
		var phenotype := PhenotypeResolver.resolve(lamb.genome)
		sections.append("LAMB: %s\nParents: %s (%s) + %s (%s)\nGeneration: %d\n\nGENOTYPE\n%s\n\nPHENOTYPE\n%s" % [lamb.sheep_name, mother.sheep_name, lamb.mother_id, father.sheep_name, lamb.father_id, lamb.generation, lamb.genome.to_text(), phenotype.to_text()])
	output.text = "\n\n==========\n\n".join(sections)

func _show_parents() -> void:
	if sheep.is_empty(): return
	output.text = "MOTHER GENOTYPE\n%s\n\nFATHER GENOTYPE\n%s" % [sheep[mother_select.selected].genome.to_text(), sheep[father_select.selected].genome.to_text()]
