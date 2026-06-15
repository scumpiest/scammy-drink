class_name CapyNotesPanel
extends PanelContainer

const _IngredientChip := preload("res://scenes/crafting/ingredient_chip.gd")

@onready var _ingredients_container: VBoxContainer = $MarginContainer/VBoxContainer/IngredientsContainer


func add_ingredient(ingredient_name: String) -> void:
	var chip: Button = _IngredientChip.new()
	chip.setup(ingredient_name)
	_ingredients_container.add_child(chip)


func clear_ingredients() -> void:
	for child in _ingredients_container.get_children():
		child.queue_free()
