extends PanelContainer

@onready var drink_name: MarginContainer = $MarginContainer/VBoxContainer/DrinkName
@onready var ingredient1: MarginContainer = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient1
@onready var ingredient2: MarginContainer = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient2
@onready var ingredient3: MarginContainer = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient3

var current_value: String = ""
var ingredient1_value: String = ""
var ingredient2_value: String = ""
var ingredient3_value: String = ""


func update_display() -> void:
	var order_data: Dictionary = get_order_data()
	drink_name.update_from_order(order_data["recipe_key"])
	ingredient1.update_from_order(order_data["ingredient1"])
	ingredient2.update_from_order(order_data["ingredient2"])
	ingredient3.update_from_order(order_data["ingredient3"])


func get_order_data() -> Dictionary:
	var recipe_key: String = GameManager.get_order()
	var recipe_data: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var ingredients: Dictionary = recipe_data["ingredients"]
	var ingredient_names: Array = ingredients.keys()
	ingredient1_value = ingredient_names[0]
	ingredient2_value = ingredient_names[1]
	ingredient3_value = ingredient_names[2]

	return {
		"recipe_key": recipe_key,
		"ingredient1": ingredient1_value,
		"ingredient2": ingredient2_value,
		"ingredient3": ingredient3_value,
	}


func try_scratch_at_position(global_pos: Vector2, replacement: String) -> bool:
	var lines: Array[MarginContainer] = [drink_name, ingredient1, ingredient2, ingredient3]
	for line in lines:
		if line.get_global_rect().has_point(global_pos):
			line.scratch(replacement)
			return true
	return false
