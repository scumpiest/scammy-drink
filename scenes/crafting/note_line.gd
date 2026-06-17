class_name NoteLine
extends MarginContainer

@onready var label: Label = $VBoxContainer/HBoxContainer/MarginContainer/MarginContainer/Label
@onready var new_label: Label = $VBoxContainer/NewLabel
@onready var scratch_overlay: TextureRect = $VBoxContainer/HBoxContainer/MarginContainer/ScratchOverlay
@onready var undo_button: TextureButton = $VBoxContainer/HBoxContainer/UndoButton

var current_value: String = ""
var is_scratched: bool = false

var text: String:
	get:
		return new_label.text if is_scratched else current_value


func _ready() -> void:
	undo_button.pressed.connect(_on_undo_pressed)
	_update_undo_button()


func update_from_order(value: String) -> void:
	current_value = value
	is_scratched = false
	label.text = current_value
	label.visible = true
	new_label.visible = false
	scratch_overlay.visible = false
	_update_undo_button()


func scratch(replacement: String) -> void:
	if is_scratched:
		return
	is_scratched = true
	new_label.text = replacement
	new_label.visible = true
	scratch_overlay.visible = true
	_update_undo_button()


func undo() -> void:
	if not is_scratched:
		return
	is_scratched = false
	new_label.visible = false
	scratch_overlay.visible = false
	_update_undo_button()


func _on_undo_pressed() -> void:
	undo()


func _update_undo_button() -> void:
	undo_button.visible = is_scratched
