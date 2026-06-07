extends RigidBody2D

@export var data: ItemData : set = _set_data
@export var item_scale: Vector2 = Vector2(0.25, 0.25)

@onready var sprite: Sprite2D = $Sprite2D
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var velocity_based_rotation: VelocityBasedRotation = $VelocityBasedRotation

var metadata: String = ""

func _ready():
	sprite.scale = item_scale
	velocity_based_rotation.enabled = false
	drag_and_drop.drag_started.connect(_on_drag_started)
	drag_and_drop.dropped.connect(_on_dropped)
	drag_and_drop.drag_canceled.connect(_on_drag_canceled)
	if data:
		_set_data(data)

func _set_data(value: ItemData):
	data = value

	if not is_node_ready():
		return

	name = data.name
	sprite.texture = data.sprite
	metadata = data.metadata

	# we need this for water modulation
	# color = data.color

func _on_drag_started() -> void:
	velocity_based_rotation.enabled = true

func _on_dropped(_starting_position: Vector2) -> void:
	velocity_based_rotation.enabled = false

func _on_drag_canceled(starting_position: Vector2) -> void:
	velocity_based_rotation.enabled = false
	_tween_to(starting_position)

func _tween_to(target_position: Vector2) -> void:
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", target_position, 0.3)
