extends PanelContainer

@onready var drink_name: Label = $VBoxContainer/MarginContainer2/DrinkName
@onready var drink_sprite: TextureRect = $VBoxContainer/DrinkSprite
@onready var star1_filled: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/Star1Filled
@onready var star1_empty: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/Star1Empty
@onready var star2_filled: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer3/Star2Filled
@onready var star2_empty: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer3/Star2Empty
@onready var star3_filled: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/Star3Filled
@onready var star3_empty: TextureRect = $VBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/Star3Empty

@export var new_name: String
@export var new_sprite: Texture
@export var recipe_key: String = ""


func _ready() -> void:
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
