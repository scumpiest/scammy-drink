extends PanelContainer

@onready var drink_name: Label = $VBoxContainer/MarginContainer2/DrinkName
@onready var drink_sprite: TextureRect = $VBoxContainer/DrinkSprite

@export var new_name: String
@export var new_sprite: Texture

func _ready() -> void:
	drink_name.text = new_name
	drink_sprite.texture = new_sprite
	
