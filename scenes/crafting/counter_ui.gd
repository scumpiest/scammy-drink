extends Control

@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var enter_marker: Marker2D = $EnterMarker
@onready var exit_marker: Marker2D = $ExitMarker
@onready var crafting_counter: Node2D = $CraftingCounter
@onready var notes: PanelContainer = $Notes
@onready var recipe_book: Control = $RecipeBook
@onready var capy_notes: PanelContainer = $CapyNotes
@onready var _tooltip: PanelContainer = $Tooltip
@onready var footsteps_player: AudioStreamPlayer = $Footsteps


var current_target: Marker2D = null
var _awaiting_notes_save: bool = false
var _notes_saved_for_order: bool = false
var _spawned_drink: Node2D = null
var customer: Customer
var _dialogue_debug_enabled: bool = false

var main_menu_scene: String = "uid://ctrh7huvrvaws"

@export var customer_scene: PackedScene
@export var lerp_weight: float = 1.0


func _ready() -> void:
	SignalBus.notes_saved.connect(_on_notes_saved)
	GameManager.all_recipes_three_star.connect(_on_all_recipes_three_star)
	crafting_counter.drink_ingredient_added.connect(capy_notes.add_ingredient)
	crafting_counter.drink_ingredient_added.connect(_on_drink_ingredient_added)
	crafting_counter.mix_animation_finished.connect(_on_mix_animation_finished)
	notes.drink_cleared.connect(_on_drink_cleared)
	customer = spawn_customer()
	setup_customer(customer)


func _process(delta: float) -> void:
	if current_target and customer and is_instance_valid(customer):
		customer.position = customer.position.lerp(current_target.global_position, 1.0 - exp(-lerp_weight * delta))
	_update_ingredient_tooltip()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close_recipe"):
		recipe_book.visible = false
		$BookSounds.play()
	if event.is_action_pressed("open_recipe"):
		recipe_book.visible = true
		$BookSounds.play()
	if event.is_action_pressed("toggle_dialogue_debug"):
		_toggle_dialogue_debug_mode()

func spawn_customer() -> Customer:
	var new_customer: Customer = customer_scene.instantiate() as Customer
	new_customer.customer_type = randi() % Customer.Type.size() as Customer.Type
	new_customer.global_position = spawn_marker.global_position
	add_child(new_customer)
	footsteps_player.play()
	GameManager._set_can_mix(true)
	return new_customer


func setup_customer(new_customer: Customer) -> void:
	new_customer.request_completed.connect(_on_request_completed)
	new_customer.request_failed.connect(_on_request_failed)
	new_customer.set_dialogue_debug_enabled(_dialogue_debug_enabled)
	_notes_saved_for_order = not GameManager.get_session_notes(GameManager.get_order()).is_empty()
	notes.update_display()
	slide_to_marker(enter_marker)


func slide_to_marker(marker: Marker2D) -> void:
	current_target = marker


func _on_request_completed() -> void:
	_clear_drink()
	slide_to_marker(exit_marker)
	await get_tree().create_timer(2.5).timeout
	customer.tree_exited.connect(_on_customer_exited, CONNECT_ONE_SHOT)
	customer.queue_free()


func _on_customer_exited() -> void:
	current_target = null
	GameManager._set_can_mix(false)
	if _notes_saved_for_order:
		_spawn_next_customer()
	else:
		_awaiting_notes_save = true


func _on_mix_animation_finished() -> void:
	_spawn_drink()
	notes.show_save_button()
	if customer and is_instance_valid(customer):
		customer.on_mix_animation_finished()


func _spawn_drink() -> void:
	_clear_drink()
	var recipe_key: String = GameManager.get_order()
	var recipe: Dictionary = CraftingRecipe.crafting_dict.get(recipe_key, {})
	var path_to_png: String = recipe.get("filename", "")
	if path_to_png.is_empty():
		return
	CraftingComplete._set_path(path_to_png)
	var drink: Node2D = load("res://scenes/crafting/crafting_complete.tscn").instantiate()
	add_child(drink)
	_spawned_drink = drink


func _clear_drink() -> void:
	if _spawned_drink and is_instance_valid(_spawned_drink):
		_spawned_drink.queue_free()
	_spawned_drink = null


func _on_drink_cleared() -> void:
	capy_notes.clear_ingredients()
	_clear_drink()
	crafting_counter.show_blender()


func _on_notes_saved(_notes_content: Dictionary) -> void:
	_notes_saved_for_order = true
	#print("YAYHAHAHHHAAAAAAAAAAAAAAWAHAOOOOAHAHOOOOOOOOOOYIPPPREEEEEE")
	if _awaiting_notes_save:
		_awaiting_notes_save = false
		$PenSounds.play()
		
		_spawn_next_customer()


func _spawn_next_customer() -> void:
	GameManager.complete_current_order()
	customer = spawn_customer()
	setup_customer(customer)


func _on_request_failed() -> void:
	crafting_counter.reset()


func _on_main_menu_button_pressed() -> void:
	SceneManager.switch_scene(main_menu_scene)


func _on_recipe_button_pressed() -> void:
	recipe_book.visible = true

# TODO: Add a victory screen
func _on_all_recipes_three_star() -> void:
	recipe_book.visible = true


func _on_drink_ingredient_added(ingredient: String) -> void:
	if not customer or not is_instance_valid(customer):
		return
	if customer.request.is_empty():
		return

	var recipe_data: Dictionary = CraftingRecipe.crafting_dict.get(customer.request, {})
	if recipe_data.is_empty():
		return

	var recipe_ingredients: Dictionary = recipe_data.get("ingredients", {})
	var is_wrong: bool = not recipe_ingredients.has(ingredient)
	var total_added: int = crafting_counter.crafting_ingredients.size()
	var missing_hint: String = _get_missing_ingredient_hint(recipe_ingredients)

	customer.on_ingredient_feedback(ingredient, is_wrong, total_added, missing_hint)


func _get_missing_ingredient_hint(recipe_ingredients: Dictionary) -> String:
	for recipe_ingredient in recipe_ingredients.keys():
		if not crafting_counter.crafting_ingredients.has(recipe_ingredient):
			return str(recipe_ingredient)
	return ""


func _update_ingredient_tooltip() -> void:
	var ingredient_name: String = crafting_counter.get_hovered_ingredient_name()
	if ingredient_name.is_empty():
		_tooltip.hide_tooltip()
	else:
		_tooltip.show_for(ingredient_name, get_global_mouse_position())


func _toggle_dialogue_debug_mode() -> void:
	_dialogue_debug_enabled = not _dialogue_debug_enabled
	print("[DialogueDebug] enabled=%s" % str(_dialogue_debug_enabled))
	if customer and is_instance_valid(customer):
		customer.set_dialogue_debug_enabled(_dialogue_debug_enabled)
