extends Control

@onready var settings_overlay: Control = $MarginContainer
@onready var settings_panel: Control = $MarginContainer/SettingsMenu
@onready var menu_panel: Control = $PanelContainer

var play_scene: String = "uid://omqlt0501aof"


func _ready() -> void:
	settings_panel.closed.connect(_on_settings_closed)


func _on_play_pressed() -> void:
	print("Play is pressed")
	SceneManager.switch_scene(play_scene)


func _on_settings_pressed() -> void:
	settings_overlay.visible = true
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_settings_closed() -> void:
	settings_overlay.visible = false
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_quit_pressed() -> void:
	get_tree().quit()
