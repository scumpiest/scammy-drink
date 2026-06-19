extends Control

@export var WIGGLE_ANGLE_DEGREES: float = 5.0
@export var WIGGLE_PERIOD: float = 1.0

@onready var settings_overlay: Control = $MarginContainer
@onready var settings_panel: Control = $MarginContainer/SettingsMenu
@onready var menu_panel: Control = $PanelContainer
@onready var _capy: Sprite2D = $PanelContainer/MarginContainer/VBoxContainer2/CenterContainer/Capy
@onready var _coworker: Sprite2D = $PanelContainer/MarginContainer/VBoxContainer2/CenterContainer/Coworker

var intro_scene: String = "res://scenes/intro_scene.tscn"


func _ready() -> void:
	settings_panel.closed.connect(_on_settings_closed)
	_setup_bottom_pivot(_capy)
	_setup_bottom_pivot(_coworker)
	_start_wiggle(_capy)
	_start_wiggle(_coworker)


func _setup_bottom_pivot(sprite: Sprite2D) -> void:
	var tex_size := sprite.texture.get_size()
	var scaled_size := tex_size * sprite.scale
	var bottom_center := sprite.position + Vector2(0.0, scaled_size.y / 2.0)
	sprite.offset = Vector2(0.0, -tex_size.y / 2.0)
	sprite.position = bottom_center


func _start_wiggle(sprite: Sprite2D, delay: float = 0.0) -> void:
	var angle := deg_to_rad(WIGGLE_ANGLE_DEGREES)
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(sprite, "rotation", angle, WIGGLE_PERIOD)
	tween.tween_property(sprite, "rotation", -angle, WIGGLE_PERIOD)


func _on_play_pressed() -> void:
	SceneManager.switch_scene(intro_scene)


func _on_settings_pressed() -> void:
	settings_overlay.visible = true
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_settings_closed() -> void:
	settings_overlay.visible = false
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_quit_pressed() -> void:
	get_tree().quit()
