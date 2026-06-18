extends Node

const _FRUIT_RESOURCES: Array[IngredientData] = [
	preload("res://resources/ingredients/mixed_fruits.tres"),
	preload("res://resources/ingredients/pineapple.tres"),
	preload("res://resources/ingredients/strawberry.tres"),
	preload("res://resources/ingredients/orange.tres"),
	preload("res://resources/ingredients/mint.tres"),
	preload("res://resources/ingredients/lemon.tres"),
	preload("res://resources/ingredients/apple.tres"),
	preload("res://resources/ingredients/ice.tres"),
]

const _FLUID_DISPLAY_NAMES: Dictionary = {
	"white_wine": "White Wine",
	"water": "Water",
	"soda": "Soda",
	"milk": "Milk",
	"lime_juice": "Lime Juice",
	"coconut_cream": "Coconut Cream",
}

var _display_names: Dictionary = {}
var _initialized: bool = false


func get_display_name(key: String) -> String:
	_ensure_initialized()
	return _display_names.get(key, key)


func _ensure_initialized() -> void:
	if _initialized:
		return

	for data in _FRUIT_RESOURCES:
		if not data.metadata.is_empty():
			_display_names[data.metadata] = data.name

	for metadata_key in _FLUID_DISPLAY_NAMES.keys():
		_display_names[metadata_key] = _FLUID_DISPLAY_NAMES[metadata_key]

	_initialized = true
