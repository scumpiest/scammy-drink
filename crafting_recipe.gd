extends Node

var crafting_dict: Dictionary = {}

var cedevita_recipe: Dictionary = {
	"ingredients": {"water": 1, "orange": 1, "ice": 1},
	"product": {"cedevita": 1}
}

var es_teler_recipe: Dictionary = {
	"ingredients": {"milk": 1, "mango": 1, "ice": 1},
	"product": {"es_teler": 1}
}

func _ready():
	crafting_dict["cedevita"] = cedevita_recipe
	crafting_dict["es_teler"] = es_teler_recipe
