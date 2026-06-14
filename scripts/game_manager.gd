extends Node

signal crafting_complete(recipe_key: String)
signal crafting_result(recipe_key: String, correct_count: int, missing_ingredients: Array)
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


## Creates a recipe based on the crafting ingredients and always completes the order.
## Stars and missing ingredients are reported via crafting_result.
func create_recipe(crafting_ingredients: Dictionary):
	var recipe_key: String = get_order()
	var recipe: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var recipe_ingredients: Dictionary = recipe["ingredients"]

	var correct_count: int = 0
	missing_ingredients = []
	for ing in recipe_ingredients.keys():
		if crafting_ingredients.has(ing):
			correct_count += 1
		else:
			missing_ingredients.append(ing)

	crafting_complete.emit(recipe_key)
	crafting_result.emit(recipe_key, correct_count, missing_ingredients)

	if not unlocked_recipes.has(recipe_key):
		unlocked_recipes[recipe_key] = true
		recipe_unlocked.emit(recipe_key)

	recipe_orders.erase(recipe_key)
	return recipe_key
