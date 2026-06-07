extends TextureButton

@export var item_to_spawn: PackedScene
@export var marker: Marker2D

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	if item_to_spawn == null:
		print("Don't forget to assign an item scene in the Inspector!")
		return

	var new_item = item_to_spawn.instantiate()
	new_item.item_scale = Vector2(0.15, 0.15)
	new_item.global_position = get_global_mouse_position()
	get_tree().current_scene.add_child(new_item)
	new_item.drag_and_drop.begin_drag()
	get_viewport().set_input_as_handled()
