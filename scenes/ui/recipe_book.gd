extends Control

@onready var close_button: TextureButton = $CloseButton

var _drinks_by_key: Dictionary = {}


func _ready() -> void:
	_index_drink_panels()
	_refresh_all_stars()
	GameManager.crafting_result.connect(_on_crafting_result)
	close_button.pressed.connect(_on_close_button_pressed)

func _index_drink_panels() -> void:
	var grids: HBoxContainer = $CenterContainer/MarginContainer/HBoxContainer
	for grid in grids.get_children():
		for drink in grid.get_children():
			if drink.recipe_key.is_empty():
				continue
			_drinks_by_key[drink.recipe_key] = drink


func _get_drink(recipe_key: String):
	return _drinks_by_key.get(recipe_key)


func _refresh_all_stars() -> void:
	for recipe_key in _drinks_by_key:
		_drinks_by_key[recipe_key].set_stars(GameManager.get_recipe_stars(recipe_key))


func refresh_all_displays() -> void:
	_refresh_all_stars()
	for drink in _drinks_by_key.values():
		drink.refresh_display()


func _on_crafting_result(recipe_key: String, _correct_count: int, _missing_ingredients: Array) -> void:
	var drink = _get_drink(recipe_key)
	if drink:
		drink.set_stars(GameManager.get_recipe_stars(recipe_key))
		drink.refresh_display()


func _on_close_button_pressed() -> void:
	visible = false
