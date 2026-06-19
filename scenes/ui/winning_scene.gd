extends Control

var main_menu_scene: String = "uid://ctrh7huvrvaws"


func _on_main_menu_pressed() -> void:
	SceneManager.switch_scene(main_menu_scene)
