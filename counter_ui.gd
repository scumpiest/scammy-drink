extends Control

@onready var crabby: TextureRect = $Crabby
@onready var enter_marker: Marker2D = $EnterMarker
@onready var exit_marker: Marker2D = $ExitMarker

func _ready() -> void:
	GameManager.crafting_complete.connect(_on_crafting_complete)
	slide_to_marker(enter_marker)

func slide_to_marker(marker: Marker2D) -> void:
	if marker:
		var tween = create_tween()
		tween.tween_property(crabby, "position", marker.global_position, 1.5 )

func _on_crafting_complete(_recipe_key) -> void:
	print("move crabby")
	slide_to_marker(exit_marker)
