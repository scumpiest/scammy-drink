extends PanelContainer

signal notes_saved(notes_content: Dictionary)

@onready var drink_name: NoteLine = $MarginContainer/VBoxContainer/DrinkName
@onready var ingredient1: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient1
@onready var ingredient2: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient2
@onready var ingredient3: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient3

var random_chance: float = 0.0
var notes_content: Dictionary = {}


func update_display() -> void:
	var order_data: Dictionary = get_order_data()

	random_chance = order_data["random_chance"]

	var recipe_key: String = order_data["recipe_key"]
	var saved: Dictionary = GameManager.get_session_notes(recipe_key)
	if not saved.is_empty():
		_restore_from_session(saved, order_data)
		return

	drink_name.update_from_order(order_data["fake_name"])
	update_ingredients(order_data["ingredients"], random_chance)


func _restore_from_session(saved: Dictionary, order_data: Dictionary) -> void:
	drink_name.update_from_order(saved.get("drink_name", order_data["fake_name"]))

	var saved_ingredients: Array = saved.get("ingredients", [])
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	for i in ingredient_lines.size():
		if i < saved_ingredients.size():
			ingredient_lines[i].update_from_order(saved_ingredients[i])

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

	# fake ingredients safe guard
	var has_fakes_available: bool = false
	for key in inventory_keys:
		if not real_ingredients.has(key):
			has_fakes_available = true
			break

	for i in ingredient_lines.size():
		var ingredient: String = ""
		
		# check if we should use the REAL ingredient
		if randf() < chance or not has_fakes_available:
			ingredient = real_ingredients[i]
		else:
			# loop until we find an ingredient that is NOT in the real_ingredients list
			var random_ingredient: String = ""
			
			while true:
				# pick a random ingredient from inventory
				var random_index: int = randi_range(0, inventory_keys.size() - 1)
				random_ingredient = inventory_keys[random_index]
				
				# break the loop ONLY if it's a true fake (not in the recipe)
				if not real_ingredients.has(random_ingredient):
					break
			
			ingredient = random_ingredient
			
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


func _on_save_pressed():
	update_notes_content()
	GameManager.save_session_notes(notes_content)
	SignalBus.notes_saved.emit(notes_content)
