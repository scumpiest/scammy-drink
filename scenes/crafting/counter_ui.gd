extends Control

@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var enter_marker: Marker2D = $EnterMarker
@onready var exit_marker: Marker2D = $ExitMarker
@onready var crafting_counter: PanelContainer = $CraftingCounter
@onready var notes: PanelContainer = $Notes
@onready var recipe_book: Control = $RecipeBook

var current_target: Marker2D = null
var customer: Area2D = null

var main_menu_scene: String = "uid://ctrh7huvrvaws"

@export var lerp_weight: float = 1.0
@export var crabby: PackedScene = null
@export var bomb: PackedScene = null


func _ready() -> void:
	recipe_book.notes_saved.connect(notes.update_recipe_ingredients)
	customer = spawn_customer(crabby)
	setup_customer(customer)


func _process(delta: float) -> void:
	if Input.is_action_pressed("spawn_item"):
		print("spawn_item pressed")
		var item = bomb.instantiate()
		item.global_position = enter_marker.global_position
		item.z_index = -1
		add_child(item)
	if current_target:
		customer.position = customer.position.lerp(current_target.global_position, 1.0 - exp(-lerp_weight * delta))
	if Input.is_action_pressed("close"):
		recipe_book.visible = false
	

func spawn_customer(customer: PackedScene) -> Area2D:
	var new_customer = customer.instantiate()
	new_customer.global_position = spawn_marker.global_position
	add_child(new_customer)
	return new_customer


func setup_customer(customer: Area2D) -> void:
	customer.request_completed.connect(_on_request_completed)
	customer.request_failed.connect(_on_request_failed)
	notes.update_display()
	slide_to_marker(enter_marker)


func slide_to_marker(marker: Marker2D) -> void:
	current_target = marker


func _on_request_completed() -> void:
	slide_to_marker(exit_marker)
	await get_tree().create_timer(2.5).timeout
	customer.tree_exited.connect(_on_customer_exited, CONNECT_ONE_SHOT)
	customer.queue_free()


func _on_customer_exited() -> void:
	customer = spawn_customer(crabby)
	setup_customer(customer)


func _on_request_failed() -> void:
	crafting_counter.reset()


func _on_main_menu_button_pressed() -> void:
	SceneManager.switch_scene(main_menu_scene)


func _on_recipe_button_pressed() -> void:
	recipe_book.visible = true
