extends PanelContainer

@onready var drink_name: MarginContainer = $MarginContainer/VBoxContainer/DrinkName
@onready var ingredient1: MarginContainer = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient1
@onready var ingredient2: MarginContainer = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient2
@onready var ingredient3: MarginContainer = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient3

var random_chance: float = 0.0


func update_display() -> void:
	var order_data: Dictionary = get_order_data()

	random_chance = order_data["random_chance"]

	drink_name.update_from_order(order_data["recipe_key"])

	update_ingredients(order_data["ingredients"])


func get_order_data() -> Dictionary:
	var recipe_key: String = GameManager.get_order()
	var recipe_data: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var ingredients: Dictionary = recipe_data["ingredients"]
	var ingredients_array: Array = ingredients.keys()

	return {
		"recipe_key": recipe_key,
		"ingredients": ingredients_array,
		"random_chance": recipe_data["random_chance"],
	}


func update_ingredients(real_ingredients: Array) -> void:
	var inventory_keys: Array = GameManager.inventory.keys()

	var ingredient_lines: Array[MarginContainer] = [ingredient1, ingredient2, ingredient3]

	for i in ingredient_lines.size():
		var ingredient: String = ""
		var random_ingredient: String = ""
		if randf() < 0.5:
			random_ingredient = inventory_keys[randi_range(0, inventory_keys.size() - 1)]
			if not real_ingredients.has(random_ingredient):
				ingredient = random_ingredient
		else:
			ingredient = real_ingredients[i]
		ingredient_lines[i].update_from_order(ingredient)


func try_scratch_at_position(global_pos: Vector2, replacement: String) -> bool:
	var lines: Array[MarginContainer] = [drink_name, ingredient1, ingredient2, ingredient3]
	for line in lines:
		if line.get_global_rect().has_point(global_pos):
			line.scratch(replacement)
			return true
	return false
