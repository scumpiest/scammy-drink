extends Node

signal crafting_complete(recipe_key: String)
signal crafting_wrong(recipe_key: String)
signal crafting_failed(missing_ingredients: Array, total_missing_ingredients: int)
signal recipe_unlocked(recipe_key: String)

var inventory: Dictionary = {
	"soda": 1,
	"milk": 1,
	"ice": 1,
	"water": 1,
	"white_wine": 1,
	"lime_juice": 1,
	"coconut_cream": 1,
	"mixed_fruits": 1,
	"orange": 1,
	"pineapple": 1,
	"lemon": 1,
	"apple": 1,
	"mint": 1,
	"strawberry": 1,
}

var recipe_orders: Array = []
var missing_ingredients: Array = []
var unlocked_recipes: Dictionary = {}


func update_inventory(item: String, quantity: int):
	if inventory.has(item):
		inventory[item] += quantity
	else:
		inventory[item] = quantity

	if inventory[item] <= 0:
		inventory.erase(item)


## Adds a random recipe to the recipe orders.
func add_recipe_order():
	var new_recipe = CraftingRecipe.get_random_recipe()
	recipe_orders.append(new_recipe)


func get_order() -> String:
	return recipe_orders[0]


## Compares the crafting ingredients against the recipe ingredients and returns the comparison result.
func _compare_ingredients(crafting_ingredients: Dictionary, recipe_ingredients: Dictionary) -> Dictionary:
	var comparison_result: Dictionary = Util.compare_dicts(crafting_ingredients, recipe_ingredients)
	return comparison_result


## Creates a recipe based on the crafting ingredients and compares it against the current recipe order.
func create_recipe(crafting_ingredients: Dictionary):
	var recipe_key: String = get_order()
	var recipe: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var recipe_ingredients: Dictionary = recipe["ingredients"]
	var match_ingredients = _compare_ingredients(crafting_ingredients, recipe_ingredients)

	if match_ingredients["is_equal"]:
		print("Recipe created:", recipe_key)
		crafting_complete.emit(recipe_key)
		if not unlocked_recipes.has(recipe_key):
			unlocked_recipes[recipe_key] = true
			recipe_unlocked.emit(recipe_key)
		recipe_orders.erase(recipe_key)
		return recipe_key
	else:
		for key in CraftingRecipe.crafting_dict:
			if key == recipe_key:
				continue

			var other_ingredients = CraftingRecipe.crafting_dict[key]["ingredients"]
			var other_match_recipe = _compare_ingredients(crafting_ingredients, other_ingredients)

			if other_match_recipe["is_equal"]:
				crafting_wrong.emit(key)
				return key

		missing_ingredients = match_ingredients["missing_in_a"]
		var total_missing_ingredients = missing_ingredients.size()
		crafting_failed.emit(missing_ingredients, total_missing_ingredients)
		return ""
