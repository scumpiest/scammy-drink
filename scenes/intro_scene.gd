extends Control

const TUTORIAL_SCENE: String = "res://scenes/tutorial/tutorial_scene.tscn"

@onready var _intro1: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/intro1
@onready var _intro2: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/intro2
@onready var _intro3: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/intro3
@onready var _intro4: TextureRect = $MarginContainer/HBoxContainer/intro4
@onready var _start_button: Button = $Footer/StartTutorialButton

@export var POP_DURATION: float = 1
@export var PAUSE_BETWEEN: float = 1

var _intro_cards: Array[TextureRect] = []


func _ready() -> void:
	_intro_cards = [_intro1, _intro2, _intro3, _intro4]
	for card: TextureRect in _intro_cards:
		card.scale = Vector2.ZERO
		card.modulate.a = 0.0

	_start_button.visible = false
	_start_button.pressed.connect(_on_start_tutorial_pressed)

	await get_tree().process_frame

	for card: TextureRect in _intro_cards:
		card.pivot_offset = card.size / 2.0

	_play_intro_sequence()


func _play_intro_sequence() -> void:
	var tween := create_tween()

	for card: TextureRect in _intro_cards:
		tween.tween_property(card, "scale", Vector2.ONE, POP_DURATION) \
			.set_trans(Tween.TRANS_BACK) \
			.set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card, "modulate:a", 1.0, POP_DURATION * 0.5)
		tween.tween_interval(PAUSE_BETWEEN)

	tween.tween_callback(_show_start_button)


func _show_start_button() -> void:
	_start_button.visible = true
	_start_button.scale = Vector2.ZERO
	_start_button.modulate.a = 0.0
	_start_button.pivot_offset = _start_button.size / 2.0

	var tween := create_tween()
	tween.tween_property(_start_button, "scale", Vector2.ONE, POP_DURATION) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_start_button, "modulate:a", 1.0, POP_DURATION * 0.5)


func _on_start_tutorial_pressed() -> void:
	GameManager.prepare_tutorial("cedevita")
	SceneManager.switch_scene(TUTORIAL_SCENE)
