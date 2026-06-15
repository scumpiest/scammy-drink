extends Control

@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var enter_marker: Marker2D = $EnterMarker
@onready var exit_marker: Marker2D = $ExitMarker
@onready var crafting_counter: PanelContainer = $CraftingCounter
@onready var notes: PanelContainer = $Notes
@onready var recipe_book: Control = $RecipeBook
@onready var tip_panel: PanelContainer = $TipPanel


var current_target: Marker2D = null
var _awaiting_notes_save: bool = false
var _notes_saved_for_order: bool = false
var customer: Customer

var main_menu_scene: String = "uid://ctrh7huvrvaws"

@export var customer_scene: PackedScene
@export var lerp_weight: float = 1.0


func _ready() -> void:
	SignalBus.notes_saved.connect(_on_notes_saved)
	GameManager.all_recipes_three_star.connect(_on_all_recipes_three_star)
	customer = spawn_customer()
	setup_customer(customer)


func _process(delta: float) -> void:
	if current_target and customer and is_instance_valid(customer):
		customer.position = customer.position.lerp(current_target.global_position, 1.0 - exp(-lerp_weight * delta))
	if Input.is_action_pressed("close"):
		recipe_book.visible = false
	

func spawn_customer() -> Customer:
	var new_customer: Customer = customer_scene.instantiate() as Customer
	new_customer.customer_type = randi() % Customer.Type.size() as Customer.Type
	new_customer.global_position = spawn_marker.global_position
	add_child(new_customer)
	return new_customer


func setup_customer(new_customer: Customer) -> void:
	new_customer.request_completed.connect(_on_request_completed)
	new_customer.request_failed.connect(_on_request_failed)
	_notes_saved_for_order = not GameManager.get_session_notes(GameManager.get_order()).is_empty()
	notes.update_display()
	slide_to_marker(enter_marker)


func slide_to_marker(marker: Marker2D) -> void:
	current_target = marker


func _on_request_completed() -> void:
	tip_panel.show_tips(GameManager.missing_ingredients)
	slide_to_marker(exit_marker)
	await get_tree().create_timer(2.5).timeout
	customer.tree_exited.connect(_on_customer_exited, CONNECT_ONE_SHOT)
	customer.queue_free()


func _on_customer_exited() -> void:
	current_target = null
	if _notes_saved_for_order:
		tip_panel.hide_tips()
		_spawn_next_customer()
	else:
		_awaiting_notes_save = true


func _on_notes_saved(_notes_content: Dictionary) -> void:
	_notes_saved_for_order = true
	tip_panel.hide_tips()
	if _awaiting_notes_save:
		_awaiting_notes_save = false
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
