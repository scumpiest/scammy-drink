extends Control

var _drinks_by_key: Dictionary = {}


func _ready() -> void:
	_index_drink_panels()
	GameManager.crafting_complete.connect(_on_crafting_complete)
	GameManager.crafting_failed.connect(_on_crafting_failed)
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


func _on_crafting_complete(recipe_key: String) -> void:
	var drink = _get_drink(recipe_key)
	if drink:
		drink.set_stars(3)


func _on_crafting_failed(_missing_ingredients: Array, total_missing_ingredients: int) -> void:
	var drink = _get_drink(GameManager.get_order())
	if not drink:
		return
	match total_missing_ingredients:
		1:
			drink.set_stars(2)
		2:
			drink.set_stars(1)
		3:
			drink.set_stars(0)


func _on_recipe_unlocked(recipe_key: String) -> void:
	var drink = _get_drink(recipe_key)
	if drink:
		drink.unlock_recipe()
