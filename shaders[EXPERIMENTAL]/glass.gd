extends Node2D

signal ingredient_added(ingredient: String)

@onready var liquid_polygon: Polygon2D = $LiquidPolygon
@onready var splash_particles = $WaterArea/SplashParticles
@onready var water_area = $WaterArea
@onready var slosh_sfx = $SloshSFX

@export var float_force: float = 380.0
@export var water_damp: float = 4.5

var fill_level: float = 0.0
var pour_speed: float = 0.25
var base_wave_amp: float = 0.015
var _added_fruits: Array[RigidBody2D] = []
var _liquid_material: ShaderMaterial


func _ready() -> void:
	assert(liquid_polygon != null, "LiquidPolygon node not found — check the node path")
	assert(liquid_polygon.material != null, "LiquidPolygon has no material assigned")

	_liquid_material = liquid_polygon.material.duplicate() as ShaderMaterial
	liquid_polygon.material = _liquid_material
	liquid_polygon.color = Color.WHITE

	var bounds := _get_polygon_bounds(liquid_polygon.polygon)
	_liquid_material.set_shader_parameter("polygon_min", bounds.position)
	_liquid_material.set_shader_parameter("polygon_max", bounds.position + bounds.size)
	_liquid_material.set_shader_parameter("fill_amount", 0.5)


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_select"):
		if fill_level < 1.0:
			fill_level += pour_speed * delta
			_liquid_material.set_shader_parameter("fill_amount", fill_level)
			_liquid_material.set_shader_parameter("wave_amplitude", base_wave_amp * 1.5)
	else:
		var current_amp: float = _liquid_material.get_shader_parameter("wave_amplitude")
		_liquid_material.set_shader_parameter("wave_amplitude", lerp(current_amp, base_wave_amp, 0.1))


func _physics_process(_delta: float) -> void:
	for body in water_area.get_overlapping_bodies():
		if body is RigidBody2D:
			body.apply_central_force(Vector2.UP * float_force)


func _on_water_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.linear_damp = water_damp
		body.angular_damp = water_damp
		splash_particles.global_position.x = body.global_position.x
		splash_particles.restart()
		trigger_slosh()


func _on_bottom_area_body_entered(body: Node2D) -> void:
	if not body is RigidBody2D:
		return
	if body in _added_fruits:
		return
	if body.metadata.is_empty():
		return
	_added_fruits.append(body)
	ingredient_added.emit(body.metadata)


func trigger_slosh() -> void:
	var tween := create_tween()
	slosh_sfx.play()
	_liquid_material.set_shader_parameter("wave_amplitude", 0.05)
	tween.tween_property(_liquid_material, "shader_parameter/wave_amplitude", base_wave_amp, 1.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func change_drink_flavor(new_color: Color) -> void:
	_liquid_material.set_shader_parameter("liquid_color", new_color)


func _get_polygon_bounds(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()
	var min_v := points[0]
	var max_v := points[0]
	for point in points:
		min_v = min_v.min(point)
		max_v = max_v.max(point)
	return Rect2(min_v, max_v - min_v)
