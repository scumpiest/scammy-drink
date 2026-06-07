extends Control

var play_scene: String = "res://counter_ui.tscn"
var settings_scene: String = "res://settings_menu.tscn"
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
	SceneManager.switch_scene(settings_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()
