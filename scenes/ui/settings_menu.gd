extends Control

signal closed

var bus_name: String
var bus_index: int


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_save_button_pressed() -> void:
	#AudioServer.
	pass
