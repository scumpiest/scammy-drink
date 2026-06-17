class_name Tooltip
extends PanelContainer

const CURSOR_OFFSET := Vector2(16, -8)

@onready var _label: Label = $MarginContainer/Label

var _displayed_text: String = ""


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_for(text: String, global_pos: Vector2) -> void:
	var formatted_text := text.to_upper()
	if formatted_text != _displayed_text:
		_displayed_text = formatted_text
		_label.text = formatted_text
		reset_size()

	visible = true
	_position_at(global_pos)


func hide_tooltip() -> void:
	visible = false
	_displayed_text = ""


func _position_at(global_pos: Vector2) -> void:
	global_position = global_pos + Vector2(CURSOR_OFFSET.x, CURSOR_OFFSET.y - size.y)
