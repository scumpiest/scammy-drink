@tool
class_name IngredientButton2D
extends TextureButton

@export var item_data: IngredientData : set = _set_item_data
@export var item_to_spawn: PackedScene
@export var marker: Marker2D

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if item_data:
		_set_item_data(item_data)

func _set_item_data(value: IngredientData) -> void:
	item_data = value
	if not is_node_ready():
		return
	if item_data and item_data.sprite:
		_sprite.texture = item_data.sprite

## Handles mouse input for the ingredient button, spawning the item on click.
func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	if item_to_spawn == null:
		print("IngredientButton2D: item_to_spawn not assigned!")
		return

	var new_item = item_to_spawn.instantiate()
	if item_data:
		new_item.data = item_data
	new_item.item_scale = Vector2(0.15, 0.15)
	new_item.global_position = get_global_mouse_position()

	var glass_ingredients: Node = get_tree().get_first_node_in_group("glass_ingredients")
	if glass_ingredients == null:
		print("IngredientButton2D: glass_ingredients group not found!")
		return
	glass_ingredients.add_child(new_item)
	new_item.drag_and_drop.begin_drag()
	get_viewport().set_input_as_handled()
