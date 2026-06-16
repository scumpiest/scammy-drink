extends Node

var crafting_dict: Dictionary = {}


var cedevita_recipe: Dictionary = {
	"ingredients": {"soda": 1, "orange": 1, "ice": 1},
	"product": {"cedevita": 1},
	"random_chance": 0.5,
	"fake_name": "Golden Sunrise",
	"filename": "Cedevita.png"
}

var pina_colada_recipe: Dictionary = {
	"ingredients": {"coconut_cream": 1, "pineapple": 1, "ice": 1},
	"product": {"pina_colada": 1},
	"random_chance": 0.5,
	"fake_name": "Paradise Island",
	"filename": "Piña_Colada.png"
}

var rebujito_recipe: Dictionary = {
	"ingredients": {"soda": 1, "white_wine": 1, "mint": 1},
	"product": {"rebujito": 1},
	"random_chance": 0.5,
	"fake_name": "Sherry Splash",
	"filename": "Rebujito.png"
}

var apfelschorle_recipe: Dictionary = {
	"ingredients": {"apple": 1, "soda": 1, "ice": 1},
	"product": {"apfelschorle": 1},
	"random_chance": 0.5,
	"fake_name": "Summer Spritz",
	"filename": "Apfelschorle.png"
}

var lemonade_recipe: Dictionary = {
	"ingredients": {"water": 1, "lemon": 1, "mint": 1},
	"product": {"lemonade": 1},
	"random_chance": 0.5,
	"fake_name": "Fresh Squeeze",
	"filename": "Lemonade.png"
}

var mojito_recipe: Dictionary = {
	"ingredients": {"white_wine": 1, "lime_juice": 1, "soda": 1},
	"product": {"mojito": 1},
	"random_chance": 0.5,
	"fake_name": "Sour Green",
	"filename": "Mojito.png"
}

var strawberry_milkshake_recipe: Dictionary = {
	"ingredients": {"milk": 1, "strawberry": 1, "ice": 1},
	"product": {"strawberry_milkshake": 1},
	"random_chance": 0.5,
	"fake_name": "Little Princess",
	"filename": "Strawberru_Milkshake.png"
}

var coconut_mocktail_recipe: Dictionary = {
	"ingredients": {"coconut_cream": 1, "lime_juice": 1, "ice": 1},
	"product": {"coconut_mocktail": 1},
	"random_chance": 0.5,
	"fake_name": "Coco Fizz",
	"filename": "Coconut_Mocktail.png"
}

var party_mix_recipe: Dictionary = {
	"ingredients": {"white_wine": 1, "lime_juice": 1, "mixed_fruits": 1},
	"product": {"party_mix": 1},
	"random_chance": 0.5,
	"fake_name": "Hawaiian Punch",
	"filename": "" # TODO ADD PNG FOR PARTYMIX AND THE FILENAME HERE
}

var es_teler_recipe: Dictionary = {
	"ingredients": {"milk": 1, "mixed_fruits": 1, "ice": 1},
	"product": {"es_teler": 1},
	"random_chance": 0.5,
	"fake_name": "Tropical Mix",
	"filename": "Es_teler.png"
}

func _ready():
	crafting_dict["cedevita"] = cedevita_recipe
	crafting_dict["pina_colada"] = pina_colada_recipe
	crafting_dict["rebujito"] = rebujito_recipe
	crafting_dict["apfelschorle"] = apfelschorle_recipe
	crafting_dict["lemonade"] = lemonade_recipe
	crafting_dict["mojito"] = mojito_recipe
	crafting_dict["strawberry_milkshake"] = strawberry_milkshake_recipe
	crafting_dict["coconut_mocktail"] = coconut_mocktail_recipe
	crafting_dict["party_mix"] = party_mix_recipe
	crafting_dict["es_teler"] = es_teler_recipe

func get_random_recipe() -> String:
	var recipe_list: Array = get_recipes()
	var random_index: int = randi() % recipe_list.size()
	return recipe_list[random_index]

func get_recipes() -> Array:
	var recipe_list: Array = []
	for recipe in crafting_dict.keys():
		recipe_list.append(recipe)
	return recipe_list
	
func get_recipe_dict() -> Dictionary:
	return crafting_dict
