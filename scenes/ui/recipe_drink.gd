extends PanelContainer

@onready var drink_name: Label = $VBoxContainer/MarginContainer2/DrinkName
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
@export var new_sprite: Texture
@export var recipe_key: String = ""


func _ready() -> void:
	SignalBus.notes_saved.connect(_on_notes_saved)
	drink_sprite.texture = new_sprite
	_apply_lock_state()


func _apply_lock_state() -> void:
	var is_unlocked: bool = GameManager.unlocked_recipes.has(recipe_key)
	drink_name.text = new_name if is_unlocked else "?"
	drink_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_unlocked else Color(0.0, 0.0, 0.0, 1.0)


func set_stars(filled_count: int) -> void:
	star1_filled.visible = filled_count >= 1
	star2_filled.visible = filled_count >= 2
	star3_filled.visible = filled_count >= 3


func unlock_recipe() -> void:
	drink_name.text = new_name
	drink_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_notes_saved(notes_content: Dictionary) -> void:
	print(drink_name.text)
	print(notes_content["recipe_key"])
	if drink_name.text == notes_content["recipe_key"]:
		ingredient1.text = notes_content["ingredients"][0]
		ingredient2.text = notes_content["ingredients"][1]
		ingredient3.text = notes_content["ingredients"][2]
	else:
		print("Recipe key does not match")