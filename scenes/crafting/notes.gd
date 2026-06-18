extends PanelContainer

signal notes_saved(notes_content: Dictionary)
signal drink_cleared

@onready var drink_name: NoteLine = $MarginContainer/VBoxContainer/DrinkName
@onready var ingredient1: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient1
@onready var ingredient2: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient2
@onready var ingredient3: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient3
@onready var _save_button: Button = $MarginContainer/VBoxContainer/VBoxContainer/Save

var random_chance: float = 0.0
var notes_content: Dictionary = {}


func update_display() -> void:
	_hide_save_button()
	var order_data: Dictionary = get_order_data()

	random_chance = order_data["random_chance"]

	drink_name.update_from_order(order_data["fake_name"])
	update_ingredients(order_data["ingredients"], random_chance)


func update_notes_content() -> void:
	notes_content = {
		"recipe_key": GameManager.get_order(),
		"drink_name": drink_name.text,
		"ingredients": [ingredient1.text, ingredient2.text, ingredient3.text],
	}

func get_order_data() -> Dictionary:
	var recipe_key: String = GameManager.get_order()
	var recipe_data: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var ingredients: Dictionary = recipe_data["ingredients"]
	var fake_name: String = recipe_data["fake_name"]
	var ingredients_array: Array = ingredients.keys()

	return {
		"recipe_key": recipe_key,
		"ingredients": ingredients_array,
		"random_chance": recipe_data["random_chance"],
		"fake_name": fake_name,
	}


func update_ingredients(real_ingredients: Array, chance: float) -> void:
	var inventory_keys: Array = GameManager.inventory.keys()
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	var used_ingredients: Array[String] = []

	var fake_pool: Array = []
	for key in inventory_keys:
		if not real_ingredients.has(key):
			fake_pool.append(key)

	var has_fakes_available: bool = not fake_pool.is_empty()

	for i in ingredient_lines.size():
		var ingredient: String = ""

		if randf() < chance or not has_fakes_available:
			ingredient = real_ingredients[i]
		else:
			var available_fakes: Array = []
			for key in fake_pool:
				if not used_ingredients.has(key):
					available_fakes.append(key)

			if available_fakes.is_empty():
				ingredient = real_ingredients[i]
			else:
				var random_index: int = randi_range(0, available_fakes.size() - 1)
				ingredient = available_fakes[random_index]

		used_ingredients.append(ingredient)
		ingredient_lines[i].update_from_order(ingredient)


func try_scratch_at_position(global_pos: Vector2, replacement: String) -> bool:
	var lines: Array[NoteLine] = [drink_name, ingredient1, ingredient2, ingredient3]
	for line in lines:
		if line.get_global_rect().has_point(global_pos):
			line.scratch(replacement)
			return true
	return false


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.get("type", "") == "ingredient"):
		return false
	var global_pos := get_global_transform() * at_position
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	for line in ingredient_lines:
		if line.get_global_rect().has_point(global_pos) and not line.is_scratched:
			return true
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var ingredient: String = data.get("name", "")
	var global_pos := get_global_transform() * at_position
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	for line in ingredient_lines:
		if line.get_global_rect().has_point(global_pos) and not line.is_scratched:
			line.scratch(ingredient)
			return


func show_save_button() -> void:
	_save_button.visible = true


func _hide_save_button() -> void:
	_save_button.visible = false


func _on_save_pressed():
	update_notes_content()
	GameManager.save_session_notes(notes_content)
	SignalBus.notes_saved.emit(notes_content)
	_hide_save_button()
	drink_cleared.emit()
