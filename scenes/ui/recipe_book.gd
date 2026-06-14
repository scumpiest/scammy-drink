extends Control

var _drinks_by_key: Dictionary = {}


func _ready() -> void:
	_index_drink_panels()
	GameManager.crafting_result.connect(_on_crafting_result)
	GameManager.recipe_unlocked.connect(_on_recipe_unlocked)


func _index_drink_panels() -> void:
	var grids: HBoxContainer = $CenterContainer/MarginContainer/HBoxContainer
	for grid in grids.get_children():
		for drink in grid.get_children():
			if drink.recipe_key.is_empty():
				continue
			_drinks_by_key[drink.recipe_key] = drink


func _get_drink(recipe_key: String):
	return _drinks_by_key.get(recipe_key)


func _on_crafting_result(recipe_key: String, correct_count: int, _missing_ingredients: Array) -> void:
	var drink = _get_drink(recipe_key)
	if drink:
		drink.set_stars(correct_count)


func _on_recipe_unlocked(recipe_key: String) -> void:
	var drink = _get_drink(recipe_key)
	if drink:
		drink.unlock_recipe()
