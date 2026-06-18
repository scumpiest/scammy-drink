extends Node2D

@onready var sfx_player: AudioStreamPlayer = $IngredientSounds
@onready var drop_sound := preload("res://assets/sfx/Drop 5.wav")
@onready var pour_sound := preload("res://assets/sfx/Water Pour.mp3")
@onready var fruit_pick_sound := preload("res://assets/sfx/Fruit pick.wav")

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

const FLUID_BUTTON_DISPLAY_NAMES: Dictionary = {
	"WhiteWine": "White Wine",
	"Water": "Water",
	"Soda": "Soda",
	"Milk": "Milk",
	"LimeJuice": "Lime Juice",
	"CoconutCream": "Coconut Cream",
}

const FLUID_INGREDIENT_BY_BUTTON: Dictionary = {
	"WhiteWine": "white_wine",
	"Water": "water",
	"Soda": "soda",
	"Milk": "milk",
	"LimeJuice": "lime_juice",
	"CoconutCream": "coconut_cream",
}

const FLUID_COLORS: Dictionary = {
	"white_wine": Color(0.95, 0.92, 0.7, 0.75),
	"water": Color(0.45, 0.75, 0.95, 0.7),
	"soda": Color(0.85, 0.3, 0.3, 0.75),
	"milk": Color(0.95, 0.95, 0.95, 0.85),
	"lime_juice": Color(0.7, 0.95, 0.3, 0.8),
	"coconut_cream": Color(0.98, 0.97, 0.9, 0.85),
}

const FIRST_FLUID_POUR_FILL: float = 0.5
const SECOND_FLUID_POUR_FILL: float = 0.2

@onready var glass: Node2D = $Blender/BlenderFront/Glass
@onready var blender: Node2D = $Blender

signal mix_animation_finished

var crafting_ingredients = {}
var _fruit_areas_enabled: bool = true
var _pouring_ingredient: String = ""

func _ready() -> void:
	glass.ingredient_added.connect(_on_ingredient_added)
	glass.pour_reached_max.connect(_on_pour_reached_max)
	GameManager.crafting_complete.connect(_on_crafting_complete)
	blender.mix_animation_finished.connect(func() -> void: mix_animation_finished.emit())
	_setup_fruit_areas()
	_setup_fluid_buttons()


func show_blender() -> void:
	blender.show_blender()


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
	_pouring_ingredient = ""
	sfx_player.stop()
	glass.reset_liquid()
	var glass_ingredients: Node = $GlassIngredients
	for child in glass_ingredients.get_children():
		child.queue_free()

	get_tree().call_group("fluid_button", "set", "disabled", false)
	_set_fruit_areas_enabled(true)

func mix() -> void:
	GameManager.create_recipe(crafting_ingredients)


func _on_mix_pressed() -> void:
	mix()

func _on_crafting_complete(_recipe_key) -> void:
	reset()

func _on_reset_pressed():
	reset()


func _on_ingredient_added(ingredient: String) -> void:
	_add_ingredient(ingredient)
	sfx_player.stream = drop_sound; sfx_player.play()


func _setup_fruit_areas() -> void:
	for area_name in FRUIT_AREA_NAMES:
		var area := get_node_or_null(area_name) as Area2D
		if area == null:
			continue
		area.add_to_group("fruit_button")
		area.input_pickable = true


func _setup_fluid_buttons() -> void:
	for child in get_children():
		if not child.is_in_group("fluid_button") or not child is BaseButton:
			continue
		var button := child as BaseButton
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.button_down.connect(_on_fluid_button_down.bind(button))
		button.button_up.connect(_on_fluid_button_up.bind(button))


func _set_fruit_areas_enabled(enabled: bool) -> void:
	_fruit_areas_enabled = enabled
	get_tree().call_group("fruit_button", "set", "input_pickable", enabled)


func get_hovered_ingredient_name() -> String:
	var mouse_pos := get_global_mouse_position()

	if _fruit_areas_enabled:
		var fruit_name := _get_hovered_fruit_name(mouse_pos)
		if not fruit_name.is_empty():
			return fruit_name

	return _get_hovered_fluid_name(mouse_pos)


func _get_hovered_fruit_name(mouse_pos: Vector2) -> String:
	for i in range(FRUIT_AREA_NAMES.size() - 1, -1, -1):
		var area_name: String = FRUIT_AREA_NAMES[i]
		var area := get_node_or_null(area_name) as Area2D
		if area == null or not area.input_pickable:
			continue
		if not _is_point_in_area(area, mouse_pos):
			continue
		if FRUIT_DATA_BY_AREA.has(area_name):
			var data: IngredientData = FRUIT_DATA_BY_AREA[area_name]
			return data.name
		return area_name
	return ""


func _get_hovered_fluid_name(mouse_pos: Vector2) -> String:
	for child in get_children():
		if not child.is_in_group("fluid_button") or not child is BaseButton:
			continue
		var button := child as BaseButton
		if button.disabled or not button.visible:
			continue
		if button.get_global_rect().has_point(mouse_pos):
			return FLUID_BUTTON_DISPLAY_NAMES.get(child.name, child.name)
	return ""


func _is_point_in_area(area: Area2D, global_point: Vector2) -> bool:
	for child in area.get_children():
		if child is CollisionPolygon2D:
			var collision := child as CollisionPolygon2D
			var local_point := collision.to_local(global_point)
			if Geometry2D.is_point_in_polygon(local_point, collision.polygon):
				return true
	return false


func _spawn_fruit(item_data: IngredientData) -> void:
	sfx_player.stream = fruit_pick_sound
	sfx_player.play()

	var new_item: RigidBody2D = BASE_FRUIT_SCENE.instantiate()
	new_item.data = item_data
	new_item.item_scale = Vector2(0.15, 0.15)
	new_item.global_position = get_global_mouse_position()

	$GlassIngredients.add_child(new_item)
	new_item.drag_and_drop.begin_drag()
	get_viewport().set_input_as_handled()


func _get_fluid_pour_max_fill() -> float:
	var fluid_count := 0
	for ingredient in crafting_ingredients.keys():
		if FLUID_INGREDIENT_BY_BUTTON.values().has(ingredient):
			fluid_count += 1
	return FIRST_FLUID_POUR_FILL if fluid_count == 0 else SECOND_FLUID_POUR_FILL


func _on_fluid_button_down(button: BaseButton) -> void:
	if button.disabled or not _pouring_ingredient.is_empty():
		return

	var ingredient: String = FLUID_INGREDIENT_BY_BUTTON.get(button.name, "")
	if ingredient.is_empty():
		return
	if crafting_ingredients.has(ingredient) or _get_total_ingredients() >= 3:
		return

	var liquid_color: Color = FLUID_COLORS.get(ingredient, Color.WHITE)
	var max_pour_fill: float = _get_fluid_pour_max_fill()
	if not glass.start_pour(liquid_color, ingredient, max_pour_fill):
		return

	_pouring_ingredient = ingredient
	sfx_player.stream = pour_sound
	sfx_player.play()


func _on_fluid_button_up(_button: BaseButton) -> void:
	_finish_fluid_pour()


func _on_pour_reached_max(ingredient: String) -> void:
	if _pouring_ingredient != ingredient:
		return
	_finish_fluid_pour()


func _finish_fluid_pour() -> void:
	if _pouring_ingredient.is_empty():
		return

	var ingredient := _pouring_ingredient
	_pouring_ingredient = ""
	sfx_player.stop()

	var poured_amount: float = glass.stop_pour()
	if poured_amount >= glass.MIN_POUR_TO_REGISTER:
		_add_ingredient(ingredient)
