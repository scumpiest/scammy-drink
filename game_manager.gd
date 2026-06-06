extends Node

var inventory: Dictionary = {"water": 1, "milk": 1, "ice": 1, "mango": 1, "orange": 1}

# Uncomment to enable quantity
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
			update_inventory(product.keys()[0], product.values()[0])
			print("Recipe created:", recipe_key)
		else:
			print("Not enough ingredients for recipe")
