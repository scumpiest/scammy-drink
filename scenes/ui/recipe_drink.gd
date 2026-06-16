extends PanelContainer

@onready var drink_name: Label = $VBoxContainer/MarginContainer2/VBoxContainer/DrinkName
@onready var actual_name: Label = $VBoxContainer/MarginContainer2/VBoxContainer/ActualName
@onready var drink_sprite: TextureRect = $VBoxContainer/HBoxContainer/MarginContainer2/DrinkSprite
@onready var star1_filled: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/Star1Filled
@onready var star1_empty: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/Star1Empty
@onready var star2_filled: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer3/Star2Filled
@onready var star2_empty: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer3/Star2Empty
@onready var star3_filled: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/Star3Filled
@onready var star3_empty: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/Star3Empty
@onready var ingredient1: Label = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/Ingredient1
@onready var ingredient2: Label = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/Ingredient2
@onready var ingredient3: Label = $VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/Ingredient3

@export var new_name: String
@export var fake_name: String
@export var new_sprite: Texture
@export var recipe_key: String = ""

var _ingredient_labels: Array[Label] = []


func _ready() -> void:
	_ingredient_labels = [ingredient1, ingredient2, ingredient3]
	SignalBus.notes_saved.connect(_on_notes_saved)
	drink_name.text = fake_name
	drink_sprite.texture = new_sprite
	_apply_lock_state()


func _apply_lock_state() -> void:
	if recipe_key.is_empty() or not CraftingRecipe.crafting_dict.has(recipe_key):
		drink_sprite.modulate = Color(0.0, 0.0, 0.0, 1.0)
		actual_name.text = "(?)"
		for label in _ingredient_labels:
			label.text = "?"
		return

	var is_fully_unlocked: bool = GameManager.is_recipe_fully_unlocked(recipe_key)
	drink_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_fully_unlocked else Color(0.0, 0.0, 0.0, 1.0)
	actual_name.text = new_name if is_fully_unlocked else "(?)"
	_refresh_ingredient_labels()


func _refresh_ingredient_labels() -> void:
	if recipe_key.is_empty() or not CraftingRecipe.crafting_dict.has(recipe_key):
		return

	var actual: Array = CraftingRecipe.crafting_dict[recipe_key]["ingredients"].keys()
	for i in _ingredient_labels.size():
		if i >= actual.size():
			_ingredient_labels[i].text = "?"
		elif GameManager.is_recipe_ingredient_unlocked(recipe_key, i):
			_ingredient_labels[i].text = actual[i]
		else:
			_ingredient_labels[i].text = "?"


func set_stars(filled_count: int) -> void:
	star1_filled.visible = filled_count >= 1
	star2_filled.visible = filled_count >= 2
	star3_filled.visible = filled_count >= 3


func refresh_display() -> void:
	_apply_lock_state()


func _on_notes_saved(notes_content: Dictionary) -> void:
	if recipe_key.is_empty() or not CraftingRecipe.crafting_dict.has(recipe_key):
		return
	if recipe_key != notes_content["recipe_key"]:
		return

	var actual: Array = CraftingRecipe.crafting_dict[recipe_key]["ingredients"].keys()
	var saved_ingredients: Array = notes_content["ingredients"]
	if saved_ingredients.size() != actual.size():
		return

	for i in actual.size():
		if saved_ingredients[i] == actual[i]:
			GameManager.unlock_recipe_ingredient_at(recipe_key, i)

	_apply_lock_state()
