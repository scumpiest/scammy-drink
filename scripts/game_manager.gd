extends Node

signal crafting_complete(recipe_key: String)
signal crafting_result(recipe_key: String, correct_count: int, missing_ingredients: Array)
signal all_recipes_three_star

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
var unlocked_recipe_ingredients: Dictionary = {}
var recipe_best_stars: Dictionary = {}
var session_notes: Dictionary = {}
var _all_three_star_emitted: bool = false

var can_mix: bool = true


func save_session_notes(notes_content: Dictionary) -> void:
	session_notes[notes_content["recipe_key"]] = notes_content


func get_session_notes(recipe_key: String) -> Dictionary:
	return session_notes.get(recipe_key, {})


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

	var previous_best: int = recipe_best_stars.get(recipe_key, 0)
	recipe_best_stars[recipe_key] = maxi(previous_best, correct_count)
	_check_all_recipes_three_star()

	crafting_complete.emit(recipe_key)
	crafting_result.emit(recipe_key, correct_count, missing_ingredients)

	return recipe_key


func complete_current_order() -> void:
	if recipe_orders.is_empty():
		return
	recipe_orders.pop_front()


func _ensure_recipe_ingredient_slots(recipe_key: String) -> Array:
	if not unlocked_recipe_ingredients.has(recipe_key):
		unlocked_recipe_ingredients[recipe_key] = [false, false, false]
	return unlocked_recipe_ingredients[recipe_key]


func unlock_recipe_ingredient_at(recipe_key: String, index: int) -> void:
	var slots: Array = _ensure_recipe_ingredient_slots(recipe_key)
	slots[index] = true
	_update_recipe_unlock_state(recipe_key)


func is_recipe_ingredient_unlocked(recipe_key: String, index: int) -> bool:
	if not unlocked_recipe_ingredients.has(recipe_key):
		return false
	return unlocked_recipe_ingredients[recipe_key][index]


func is_recipe_fully_unlocked(recipe_key: String) -> bool:
	if not unlocked_recipe_ingredients.has(recipe_key):
		return false
	for unlocked in unlocked_recipe_ingredients[recipe_key]:
		if not unlocked:
			return false
	return true


func _update_recipe_unlock_state(recipe_key: String) -> void:
	if is_recipe_fully_unlocked(recipe_key):
		unlocked_recipes[recipe_key] = true


func get_recipe_stars(recipe_key: String) -> int:
	return recipe_best_stars.get(recipe_key, 0)


func has_three_star(recipe_key: String) -> bool:
	return get_recipe_stars(recipe_key) >= 3


func are_all_recipes_three_star() -> bool:
	for recipe_key in CraftingRecipe.get_recipes():
		if get_recipe_stars(recipe_key) < 3:
			return false
	return true


func _check_all_recipes_three_star() -> void:
	if _all_three_star_emitted:
		return
	if are_all_recipes_three_star():
		_all_three_star_emitted = true
		all_recipes_three_star.emit()

func _set_can_mix(val: bool) -> void:
	can_mix = val
