extends Node

var inventory: Dictionary = {}


func update_inventory(item: String, quantity: int):
	if inventory.has(item):
		inventory[item] += quantity
	else:
		inventory[item] = quantity

	if inventory[item] <= 0:
		inventory.erase(item)

	print("Inventory updated:", inventory)

func create_recipe(recipe_key: String):
	var recipe: Dictionary = CraftingRecipe.crafting_dict[recipe_key]

	if recipe:
		var product: Dictionary = recipe["product"]
		var ingredients: Dictionary = recipe["ingredients"]

		if inventory.has_all(ingredients.keys()):
			var obtained_ingredients: int = 0
			for item in ingredients:
				if inventory[item] >= ingredients[item]:
					obtained_ingredients += 1

			if obtained_ingredients == ingredients.size():
				for item in ingredients:
					update_inventory(item, -ingredients[item])
				for item in product:
					update_inventory(item, product[item])
		else:
			print("Not enough ingredients for recipe")
