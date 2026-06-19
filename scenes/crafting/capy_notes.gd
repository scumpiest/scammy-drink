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


func get_chip_rect_by_index(index: int) -> Rect2:
	var children := _ingredients_container.get_children()
	if index < 0 or index >= children.size():
		return Rect2()
	var child := children[index]
	if child is Control:
		return child.get_global_rect()
	return Rect2()
