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

	update_ingredients(order_data["ingredients"], random_chance)


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


func update_ingredients(real_ingredients: Array, chance: float) -> void:
	var inventory_keys: Array = GameManager.inventory.keys()
	var ingredient_lines: Array[MarginContainer] = [ingredient1, ingredient2, ingredient3]

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
	var lines: Array[MarginContainer] = [drink_name, ingredient1, ingredient2, ingredient3]
	for line in lines:
		if line.get_global_rect().has_point(global_pos):
			line.scratch(replacement)
			return true
	return false
