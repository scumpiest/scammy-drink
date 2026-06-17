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
@onready var chat_bubble: Label = $BubbleBackground/VBoxContainer/PanelContainer/MarginContainer/ChatBubble
@onready var sprite: Sprite2D = $Sprite2D

const BOP_SPEED: float = 14.0
const BOP_HEIGHT: float = 10.0
const MOVE_THRESHOLD_SQUARED: float = 0.25
const PERSONA_BY_TYPE: Dictionary = {
	Type.AXOLOTL: "axolotl",
	Type.FISH: "fish",
	Type.SEAL: "seal",
	Type.SHARK: "shark",
}

var customer_type: Type
var request: String = ""
var _last_position: Vector2 = Vector2.ZERO
var _sprite_rest_y: float = 0.0
var _sprite_rest_scale: Vector2 = Vector2.ONE
var _bop_time: float = 0.0
var _ingredients_added_count: int = 0
var _had_wrong_before_two: bool = false
var _shown_my_drink_with_wrong: bool = false
var _shown_my_drink_with_right: bool = false
var _dialogue_debug_enabled: bool = false


func _ready() -> void:
	sprite.texture = SPRITES[customer_type]
	_sprite_rest_y = sprite.position.y
	_sprite_rest_scale = sprite.scale
	_last_position = position

	GameManager.add_recipe_order()
	request = GameManager.get_order()
	_reset_dialogue_state()
	_show_dialogue("hello")

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
	_show_mix_result_dialogue(_correct_count)
	await get_tree().create_timer(1.5).timeout
	request_completed.emit()
	bubble_background.visible = false
	_display_completed_drink()
	request = ""


func on_ingredient_feedback(ingredient: String, is_wrong: bool, total_added: int, missing_ingredient_hint: String) -> void:
	_ingredients_added_count = total_added
	_debug_log("ingredient_added", {
		"ingredient": ingredient,
		"is_wrong": is_wrong,
		"total_added": total_added,
		"missing_hint": missing_ingredient_hint
	})

	if is_wrong:
		if total_added <= 2:
			_had_wrong_before_two = true
		var events: Array[String] = []
		if not _shown_my_drink_with_wrong:
			events.append("my_drink?")
			_shown_my_drink_with_wrong = true
		events.append("wrong_ingredient")
		_show_dialogue_events(events, {"ingredient": ingredient})

	if total_added == 2:
		var events: Array[String] = []
		if not _had_wrong_before_two and not _shown_my_drink_with_right:
			events.append("my_drink?")
			_shown_my_drink_with_right = true
		events.append("right_ingredient")
		_show_dialogue_events(events, {"ingredient": missing_ingredient_hint})


func _show_mix_result_dialogue(correct_count: int) -> void:
	_debug_log("mix_result", {
		"ingredients_added_count": _ingredients_added_count,
		"correct_count": correct_count
	})

	match correct_count:
		0:
			_show_dialogue("thx_failed")
		1:
			_show_dialogue("thx_1")
		2:
			_show_dialogue("thx_2")
		3:
			_show_dialogue("thx_3")


func _show_dialogue(event_name: String, params: Dictionary = {}) -> void:
	_show_dialogue_events([event_name], params)


func _show_dialogue_events(event_names: Array[String], params: Dictionary = {}) -> void:
	var persona: String = _get_persona_name()
	var lines: Array[String] = []
	for event_name in event_names:
		var line: String = DialogueBank.get_customer_line(persona, event_name, params)
		if line.is_empty():
			_debug_log("missing_dialogue_line", {"persona": persona, "event": event_name})
			continue
		lines.append(line)

	if lines.is_empty():
		return

	bubble_background.visible = true
	chat_bubble.text = "\n".join(lines)
	_debug_log("dialogue", {
		"persona": persona,
		"events": event_names,
		"line": chat_bubble.text
	})


func _get_persona_name() -> String:
	return PERSONA_BY_TYPE.get(customer_type, "seal")


func _reset_dialogue_state() -> void:
	_ingredients_added_count = 0
	_had_wrong_before_two = false
	_shown_my_drink_with_wrong = false
	_shown_my_drink_with_right = false


func set_dialogue_debug_enabled(enabled: bool) -> void:
	_dialogue_debug_enabled = enabled
	_debug_log("debug_mode_changed", {"enabled": enabled})


func _debug_log(event_name: String, data: Dictionary = {}) -> void:
	if not _dialogue_debug_enabled:
		return
	print("[DialogueDebug] customer=%s event=%s data=%s" % [_get_persona_name(), event_name, str(data)])
	
func _display_completed_drink() -> void:
	var dict_name = request+"_recipe"
	print(dict_name)
	var crafting_dict = CraftingRecipe.get_recipe_dict()
	var recipe = crafting_dict[request]
	var path_to_png = recipe.filename
	CraftingComplete._set_path(path_to_png)
	var scene_resource = load("res://scenes/crafting/crafting_complete.tscn")
	var scene_instance = scene_resource.instantiate()
	get_tree().current_scene.add_child(scene_instance)
