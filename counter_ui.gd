extends Control

@onready var crabby: TextureRect = $Crabby
@onready var enter_marker: Marker2D = $EnterMarker
@onready var exit_marker: Marker2D = $ExitMarker
@onready var bubble_background: PanelContainer = $Crabby/BubbleBackground
@onready var chat_bubble: Label = $Crabby/BubbleBackground/ChatBubble

var current_target: Marker2D = null

@export var lerp_weight: float = 1.0

func _ready() -> void:
	GameManager.crafting_complete.connect(_on_crafting_complete)
	bubble_background.visible = false
	slide_to_marker(enter_marker)

func _process(delta: float) -> void:
	if current_target:
		crabby.position = crabby.position.lerp(current_target.global_position, 1.0 - exp(-lerp_weight * delta))

func slide_to_marker(marker: Marker2D) -> void:
	current_target = marker

func _on_crafting_complete(_recipe_key) -> void:
	bubble_background.visible = true
	chat_bubble.text = "Thanks for the " + _recipe_key + "!"
	await get_tree().create_timer(2.5).timeout
	bubble_background.visible = false
	slide_to_marker(exit_marker)
