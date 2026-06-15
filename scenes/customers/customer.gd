class_name Customer
extends Area2D

signal request_completed
signal request_failed

enum Type { AXOLOTL, FISH, SEAL, SHARK }

const SPRITES: Dictionary = {
	Type.AXOLOTL: preload("res://assets/customers/Axlotl_customer.png"),
	Type.FISH: preload("res://assets/customers/Fish_customer.png"),
	Type.SEAL: preload("res://assets/customers/Seal_customer.png"),
	Type.SHARK: preload("res://assets/customers/Shark_customer.png"),
}

@onready var bubble_background: PanelContainer = $BubbleBackground
@onready var chat_bubble: Label = $BubbleBackground/ChatBubble
@onready var sprite: Sprite2D = $Sprite2D

const BOP_SPEED: float = 14.0
const BOP_HEIGHT: float = 10.0
const MOVE_THRESHOLD_SQUARED: float = 0.25

var customer_type: Type
var request: String = ""
var _last_position: Vector2 = Vector2.ZERO
var _sprite_rest_y: float = 0.0
var _sprite_rest_scale: Vector2 = Vector2.ONE
var _bop_time: float = 0.0


func _ready() -> void:
	sprite.texture = SPRITES[customer_type]
	_sprite_rest_y = sprite.position.y
	_sprite_rest_scale = sprite.scale
	_last_position = position

	GameManager.add_recipe_order()
	request = GameManager.get_order()
	# TODO: We shouldnt display the drink request(keep this for debugging)
	chat_bubble.text = "GIMME " + request.to_upper() + "!!"

	GameManager.crafting_result.connect(_on_crafting_result)


func _process(delta: float) -> void:
	var is_moving: bool = position.distance_squared_to(_last_position) > MOVE_THRESHOLD_SQUARED

	if is_moving:
		if position.x < _last_position.x:
			sprite.flip_h = true
		elif position.x > _last_position.x:
			sprite.flip_h = false

		_bop_time += delta * BOP_SPEED
		var bounce: float = abs(sin(_bop_time))
		sprite.position.y = _sprite_rest_y - bounce * BOP_HEIGHT
		sprite.scale = _sprite_rest_scale * Vector2(1.0 + bounce * 0.06, 1.0 - bounce * 0.04)
	else:
		_bop_time = 0.0
		sprite.position.y = lerpf(sprite.position.y, _sprite_rest_y, delta * 12.0)
		sprite.scale = sprite.scale.lerp(_sprite_rest_scale, delta * 12.0)

	_last_position = position


func _on_crafting_result(_recipe_key: String, _correct_count: int, _missing_ingredients: Array) -> void:
	if _recipe_key != request:
		return
	bubble_background.visible = true
	if _missing_ingredients.is_empty():
		chat_bubble.text = "Thanks for the " + request + "!"
	else:
		var ingredients_str: String = ", ".join(_missing_ingredients)
		chat_bubble.text = "You forgot " + ingredients_str + "... but I'll take it!"
	await get_tree().create_timer(1.5).timeout
	request_completed.emit()
	bubble_background.visible = false
	request = ""
