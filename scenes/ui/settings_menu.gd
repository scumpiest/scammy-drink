extends Control

var main_menu_scene: String = "uid://ctrh7huvrvaws"

var bus_name: String
var bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_back_button_pressed() -> void:
	SceneManager.switch_scene(main_menu_scene)


func _on_save_button_pressed() -> void:
	#AudioServer.
	pass
