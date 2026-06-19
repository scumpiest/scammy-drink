extends Control

const SARAH_SCENE: String = "res://scenes/sarah_scene.tscn"

@onready var _intro1: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/intro1
@onready var _intro2: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/intro2
@onready var _intro3: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/intro3
@onready var _intro4: TextureRect = $MarginContainer/HBoxContainer/intro4
@onready var sfx: AudioStreamPlayer = $SFX

@export var POP_DURATION: float = 1
@export var PAUSE_BETWEEN: float = 1

var _intro_cards: Array[TextureRect] = []


func _ready() -> void:
	_intro_cards = [_intro1, _intro2, _intro3, _intro4]
	for card: TextureRect in _intro_cards:
		card.scale = Vector2.ZERO
		card.modulate.a = 0.0

	await get_tree().process_frame

	for card: TextureRect in _intro_cards:
		card.pivot_offset = card.size / 2.0

	_play_intro_sequence()


func _play_intro_sequence() -> void:
	var tween := create_tween()

	for card: TextureRect in _intro_cards:
		tween.tween_callback(sfx.play)
		tween.tween_property(card, "scale", Vector2.ONE, POP_DURATION) \
			.set_trans(Tween.TRANS_BACK) \
			.set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card, "modulate:a", 1.0, POP_DURATION * 0.5)
		tween.tween_interval(PAUSE_BETWEEN)

	tween.tween_callback(_go_to_sarah_scene)


func _go_to_sarah_scene() -> void:
	SceneManager.switch_scene(SARAH_SCENE)
