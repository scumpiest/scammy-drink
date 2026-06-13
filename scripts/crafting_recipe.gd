extends Node

var crafting_dict: Dictionary = {}

var cedevita_recipe: Dictionary = {
	"ingredients": {"soda": 1, "orange": 1, "ice": 1},
	"product": {"cedevita": 1},
	"random_chance": 0.5,
	"fake_name": "Golden Sunrise"
}

var pina_colada_recipe: Dictionary = {
	"ingredients": {"coconut_cream": 1, "pineapple": 1, "ice": 1},
	"product": {"pina_colada": 1},
	"random_chance": 0.5,
	"fake_name": "Paradise Island"
}

var rebujito_recipe: Dictionary = {
	"ingredients": {"soda": 1, "white_wine": 1, "mint": 1},
	"product": {"rebujito": 1},
	"random_chance": 0.5,
	"fake_name": "Sherry Splash"
}

var apfelschorle_recipe: Dictionary = {
	"ingredients": {"apple": 1, "soda": 1, "ice": 1},
	"product": {"apfelschorle": 1},
	"random_chance": 0.5,
	"fake_name": "Summer Spritz"
}

var lemonade_recipe: Dictionary = {
	"ingredients": {"water": 1, "lemon": 1, "mint": 1},
	"product": {"lemonade": 1},
	"random_chance": 0.5,
	"fake_name": "Fresh Squeeze"
}

var mojito_recipe: Dictionary = {
	"ingredients": {"white_wine": 1, "lime_juice": 1, "soda": 1},
	"product": {"mojito": 1},
	"random_chance": 0.5,
	"fake_name": "Sour Green"
}

var strawberry_milkshake_recipe: Dictionary = {
	"ingredients": {"milk": 1, "strawberry": 1, "ice": 1},
	"product": {"strawberry_milkshake": 1},
	"random_chance": 0.5,
	"fake_name": "Little Princess"
}

var coconut_mocktail_recipe: Dictionary = {
	"ingredients": {"coconut_cream": 1, "lime_juice": 1, "ice": 1},
	"product": {"coconut_mocktail": 1},
	"random_chance": 0.5,
	"fake_name": "Coco Fizz"
}

var party_mix_recipe: Dictionary = {
	"ingredients": {"white_wine": 1, "lime_juice": 1, "mixed_fruits": 1},
	"product": {"party_mix": 1},
	"random_chance": 0.5,
	"fake_name": "Hawaiian Punch"
}

var es_teler_recipe: Dictionary = {
	"ingredients": {"milk": 1, "mixed_fruits": 1, "ice": 1},
	"product": {"es_teler": 1},
	"random_chance": 0.5,
	"fake_name": "Tropical Mix"
}

func _ready():
	crafting_dict["cedevita"] = cedevita_recipe
	crafting_dict["pina colada"] = pina_colada_recipe
	crafting_dict["rebujito"] = rebujito_recipe
	crafting_dict["apfelschorle"] = apfelschorle_recipe
	crafting_dict["lemonade"] = lemonade_recipe
	crafting_dict["mojito"] = mojito_recipe
	crafting_dict["strawberry milkshake"] = strawberry_milkshake_recipe
	crafting_dict["coconut mocktail"] = coconut_mocktail_recipe
	crafting_dict["party mix"] = party_mix_recipe
	crafting_dict["es teler"] = es_teler_recipe

func get_random_recipe() -> String:
	var recipe_list: Array = get_recipes()
	var random_index: int = randi() % recipe_list.size()
	return recipe_list[random_index]

func get_recipes() -> Array:
	var recipe_list: Array = []
	for recipe in crafting_dict.keys():
		recipe_list.append(recipe)
	return recipe_list
