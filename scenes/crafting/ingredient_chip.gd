class_name IngredientChip
extends Button

var ingredient_name: String = ""


func setup(name: String) -> void:
	ingredient_name = name
	text = ingredient_name.replace("_", " ")
	mouse_default_cursor_shape = Control.CURSOR_DRAG


func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := Label.new()
	preview.text = text
	preview.add_theme_font_size_override("font_size", 20)
	preview.add_theme_color_override("font_color", Color(0.77, 0.34, 0.15, 1.0))
	set_drag_preview(preview)
	return {"type": "ingredient", "name": ingredient_name}
