extends Area2D

const SNAP_OFFSET := Vector2(96, 96)

@onready var icon: Sprite2D = $Texture
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var velocity_based_rotation: VelocityBasedRotation = $VelocityBasedRotation


func _ready() -> void:
	velocity_based_rotation.enabled = false
	drag_and_drop.drag_started.connect(_on_drag_started)
	drag_and_drop.dropped.connect(_on_dropped)
	drag_and_drop.drag_canceled.connect(_on_drag_canceled)


func _on_drag_started() -> void:
	velocity_based_rotation.enabled = true


func _on_dropped(starting_position: Vector2) -> void:
	velocity_based_rotation.enabled = false
	for area in get_overlapping_areas():
		var parent := area.get_parent()
		if parent is CraftingSlot and parent.receive_item(self):
			return
	_tween_to(starting_position)


func _on_drag_canceled(starting_position: Vector2) -> void:
	velocity_based_rotation.enabled = false
	_tween_to(starting_position)


func _tween_to(target_position: Vector2) -> void:
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", target_position, 0.3)
