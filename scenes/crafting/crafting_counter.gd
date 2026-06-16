extends Node2D

signal drink_ingredient_added(ingredient: String)

const BASE_FRUIT_SCENE: PackedScene = preload("res://scenes/ingredients/base_fruit.tscn")

const FRUIT_DATA_BY_AREA: Dictionary = {
	"MixedFruits": preload("res://resources/ingredients/mixed_fruits.tres"),
	"Pineapple": preload("res://resources/ingredients/pineapple.tres"),
	"Strawberry": preload("res://resources/ingredients/strawberry.tres"),
	"Orange": preload("res://resources/ingredients/orange.tres"),
	"Mint": preload("res://resources/ingredients/mint.tres"),
	"Lemon": preload("res://resources/ingredients/lemon.tres"),
	"Apple": preload("res://resources/ingredients/apple.tres"),
	"Ice": preload("res://resources/ingredients/ice.tres"),
}

const FRUIT_AREA_NAMES: Array[String] = [
	"MixedFruits",
	"Pineapple",
	"Strawberry",
	"Orange",
	"Mint",
	"Lemon",
	"Apple",
	"Ice",
]

@onready var mix_button: Button = $MixButton
@onready var glass: Node2D = $Glass

var crafting_ingredients = {}
var _fruit_areas_enabled: bool = true

func _ready() -> void:
	glass.ingredient_added.connect(_on_ingredient_added)
	GameManager.crafting_complete.connect(_on_crafting_complete)
	_setup_fruit_areas()


func _unhandled_input(event: InputEvent) -> void:
	if not _fruit_areas_enabled:
		return
	if not event is InputEventMouseButton:
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	var mouse_pos := get_global_mouse_position()
	for i in range(FRUIT_AREA_NAMES.size() - 1, -1, -1):
		var area_name: String = FRUIT_AREA_NAMES[i]
		var area := get_node_or_null(area_name) as Area2D
		if area == null or not area.input_pickable:
			continue
		if not _is_point_in_area(area, mouse_pos):
			continue
		if FRUIT_DATA_BY_AREA.has(area_name):
			_spawn_fruit(FRUIT_DATA_BY_AREA[area_name])
		elif area_name == "Ice":
			_add_ingredient("ice")
		get_viewport().set_input_as_handled()
		return


func _add_ingredient(ingredient: String) -> void:
	if crafting_ingredients.has(ingredient):
		return

	if crafting_ingredients.size() < 3:
		crafting_ingredients[ingredient] = crafting_ingredients.get(ingredient, 0) + 1
		drink_ingredient_added.emit(ingredient)

	if _get_total_ingredients() >= 3:
		get_tree().call_group("fluid_button", "set", "disabled", true)
		_set_fruit_areas_enabled(false)
		print("Max ingredients reached. Buttons disabled!")

func _get_total_ingredients() -> int:
	var total = 0
	for count in crafting_ingredients.values():
		total += count
	return total

func reset() -> void:
	crafting_ingredients.clear()
	var glass_ingredients: Node = get_parent().get_node("GlassIngredients")
	for child in glass_ingredients.get_children():
		child.queue_free()

	get_tree().call_group("fluid_button", "set", "disabled", false)
	_set_fruit_areas_enabled(true)

func _on_mix_pressed():
	GameManager.create_recipe(crafting_ingredients)

func _on_crafting_complete(_recipe_key) -> void:
	reset()

func _on_reset_pressed():
	reset()


func _on_ingredient_added(ingredient: String) -> void:
	_add_ingredient(ingredient)


func _setup_fruit_areas() -> void:
	for area_name in FRUIT_AREA_NAMES:
		var area := get_node_or_null(area_name) as Area2D
		if area == null:
			continue
		area.add_to_group("fruit_button")
		area.input_pickable = true


func _set_fruit_areas_enabled(enabled: bool) -> void:
	_fruit_areas_enabled = enabled
	get_tree().call_group("fruit_button", "set", "input_pickable", enabled)


func _is_point_in_area(area: Area2D, global_point: Vector2) -> bool:
	for child in area.get_children():
		if child is CollisionPolygon2D:
			var collision := child as CollisionPolygon2D
			var local_point := collision.to_local(global_point)
			if Geometry2D.is_point_in_polygon(local_point, collision.polygon):
				return true
	return false


func _spawn_fruit(item_data: IngredientData) -> void:
	var new_item: RigidBody2D = BASE_FRUIT_SCENE.instantiate()
	new_item.data = item_data
	new_item.item_scale = Vector2(0.15, 0.15)
	new_item.global_position = get_global_mouse_position()

	var glass_ingredients: Node = get_tree().get_first_node_in_group("glass_ingredients")
	if glass_ingredients == null:
		push_warning("CraftingCounter: glass_ingredients group not found!")
		new_item.queue_free()
		return

	glass_ingredients.add_child(new_item)
	new_item.drag_and_drop.begin_drag()
	get_viewport().set_input_as_handled()


func _on_soda_pressed():  _add_ingredient("soda")
func _on_milk_pressed():  _add_ingredient("milk")
func _on_water_pressed(): _add_ingredient("water")
func _on_white_wine_pressed(): _add_ingredient("white_wine")
func _on_lime_juice_pressed(): _add_ingredient("lime_juice")
func _on_coconut_cream_pressed(): _add_ingredient("coconut_cream")
