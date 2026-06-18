extends Control

@onready var settings_panel = $MarginContainer/SettingsMenu
var play_scene: String = "uid://omqlt0501aof"
var settings_scene: String = "uid://c86lgs72w0q84"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	print("Play is pressed")
	SceneManager.switch_scene(play_scene)

func _on_settings_pressed() -> void:
	settings_panel.visible = true 
	settings_panel.z_index = 10
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_quit_pressed() -> void:
	get_tree().quit()
