class_name TipPanel
extends PanelContainer

const _IngredientChip := preload("res://scenes/crafting/ingredient_chip.gd")

@onready var _hint_label: Label = $MarginContainer/VBoxContainer/HintLabel
@onready var _chips_container: VBoxContainer = $MarginContainer/VBoxContainer/ChipsContainer


func show_tips(missing: Array) -> void:
	for child in _chips_container.get_children():
		child.queue_free()

	if missing.is_empty():
		_hint_label.text = "Perfect drink — nothing missed!"
	else:
		_hint_label.text = "Drag to replace an ingredient:"
		for ingredient in missing:
			var chip: Button = _IngredientChip.new()
			chip.setup(ingredient)
			_chips_container.add_child(chip)

	visible = true


func hide_tips() -> void:
	for child in _chips_container.get_children():
		child.queue_free()
	visible = false
