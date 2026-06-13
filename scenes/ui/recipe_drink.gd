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
	GameManager.crafting_failed.connect(_on_crafting_failed)
	GameManager.crafting_complete.connect(_on_crafting_complete)
	GameManager.recipe_unlocked.connect(_on_recipe_unlocked)
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


func _on_recipe_unlocked(key: String) -> void:
	print("recipe unlocked: ", key)
	if key != recipe_key:
		return
	drink_name.text = new_name
	drink_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_crafting_complete(event_recipe_key: String) -> void:
	if event_recipe_key != recipe_key:
		return
	set_stars(3)


func _on_crafting_failed(_missing_ingredients: Array, total_missing_ingredients: int) -> void:
	if GameManager.get_order() != recipe_key:
		return
	match total_missing_ingredients:
		1:
			set_stars(2)
		2:
			set_stars(1)
		3:
			set_stars(0)
