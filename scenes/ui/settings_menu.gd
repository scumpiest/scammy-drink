extends Control

signal closed

const TUTORIAL_SCENE: String = "res://scenes/tutorial/tutorial_scene.tscn"

@onready var _play_tutorial_button: Button = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/PlayTutorialButton

var bus_name: String
var bus_index: int


func _ready() -> void:
	_play_tutorial_button.visible = false


func set_play_tutorial_visible(show_button: bool) -> void:
	_play_tutorial_button.visible = show_button


func _on_play_tutorial_button_pressed() -> void:
	GameManager.prepare_tutorial("cedevita")
	SceneManager.switch_scene(TUTORIAL_SCENE)


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_save_button_pressed() -> void:
	#AudioServer.
	pass
