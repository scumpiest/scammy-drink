class_name NoteLine
extends MarginContainer

@onready var label: Label = $VBoxContainer/MarginContainer/Label
@onready var new_label: Label = $VBoxContainer/NewLabel
@onready var scratch_overlay: TextureRect = $VBoxContainer/MarginContainer/ScratchOverlay

var current_value: String = ""
var is_scratched: bool = false

var text: String:
	get:
		return new_label.text if is_scratched else current_value


func update_from_order(value: String) -> void:
	current_value = value
	is_scratched = false
	label.text = current_value
	label.visible = true
	new_label.visible = false
	scratch_overlay.visible = false


func scratch(replacement: String) -> void:
	if is_scratched:
		return
	is_scratched = true
	new_label.text = replacement
	new_label.visible = true
	scratch_overlay.visible = true
