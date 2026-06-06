extends Node

signal crafting_complete(recipe_key: String)

var inventory: Dictionary = {
	"soda": 1, "milk": 1, "ice": 1, "water": 1, "white_wine": 1,
	"lime_juice": 1, "coconut_cream": 1, "mixed_fruits": 1,
	"orange": 1, "pineapple": 1, "lemon": 1, "apple": 1,
	"mint": 1, "strawberry": 1}

func update_inventory(item: String, quantity: int):
	if inventory.has(item):
		inventory[item] += quantity
	else:
		inventory[item] = quantity

	if inventory[item] <= 0:
		inventory.erase(item)

func create_recipe(crafting_ingredients: Dictionary):
	for recipe_key in CraftingRecipe.crafting_dict.keys():
		var recipe: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
		var ingredients: Dictionary = recipe["ingredients"]
		for ingredient in ingredients:
			if crafting_ingredients == ingredients:
				print("Recipe created:", recipe_key)
				crafting_complete.emit(recipe_key)
				return recipe_key
	print("No recipe found")
