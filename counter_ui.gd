extends Control

@onready var crabby: Area2D = $Crabby
@onready var enter_marker: Marker2D = $EnterMarker
@onready var exit_marker: Marker2D = $ExitMarker
@onready var crafting_counter: PanelContainer = $CraftingCounter

var current_target: Marker2D = null

@export var lerp_weight: float = 1.0

func _ready() -> void:
	crabby.request_completed.connect(_on_request_completed)
	crabby.request_failed.connect(_on_request_failed)
	slide_to_marker(enter_marker)

func _process(delta: float) -> void:
	if current_target:
		crabby.position = crabby.position.lerp(current_target.global_position, 1.0 - exp(-lerp_weight * delta))

func slide_to_marker(marker: Marker2D) -> void:
	current_target = marker

func _on_request_completed() -> void:
	slide_to_marker(exit_marker)

func _on_request_failed() -> void:
	crafting_counter.reset()
