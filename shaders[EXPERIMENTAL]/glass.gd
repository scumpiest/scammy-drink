extends Node2D

signal ingredient_added(ingredient: String)
signal pour_reached_max(ingredient_id: String)

const MIN_POUR_TO_REGISTER: float = 0.05

@onready var liquid_polygon: Polygon2D = $LiquidPolygon
@onready var splash_particles = $WaterArea/SplashParticles
@onready var water_area = $WaterArea
@onready var slosh_sfx = $SloshSFX

@export var float_force: float = 380.0
@export var water_damp: float = 4.5
@export var pour_speed: float = 0.35
@export var pour_wave_amp: float = 0.0225
@export var slosh_wave_amp: float = 0.05

var fill_level: float = 0.0

var _added_fruits: Array[RigidBody2D] = []
var _liquid_material: ShaderMaterial
var _wave_tween: Tween
var _is_pouring: bool = false
var _pour_start_level: float = 0.0
var _pour_ceiling: float = 0.0
var _active_pour_ingredient: String = ""
var _pour_max_reached: bool = false


func _ready() -> void:
	assert(liquid_polygon != null, "LiquidPolygon node not found — check the node path")
	assert(liquid_polygon.material != null, "LiquidPolygon has no material assigned")

	_liquid_material = liquid_polygon.material.duplicate() as ShaderMaterial
	liquid_polygon.material = _liquid_material
	liquid_polygon.color = Color.WHITE

	var bounds := _get_polygon_bounds(liquid_polygon.polygon)
	_liquid_material.set_shader_parameter("polygon_min", bounds.position)
	_liquid_material.set_shader_parameter("polygon_max", bounds.position + bounds.size)
	reset_liquid()


func _process(delta: float) -> void:
	if not _is_pouring:
		return

	if fill_level < _pour_ceiling:
		fill_level = minf(fill_level + pour_speed * delta, _pour_ceiling)
		_liquid_material.set_shader_parameter("fill_amount", fill_level)
		_liquid_material.set_shader_parameter("wave_amplitude", pour_wave_amp)
	elif not _pour_max_reached and not _active_pour_ingredient.is_empty():
		_pour_max_reached = true
		pour_reached_max.emit(_active_pour_ingredient)


func start_pour(liquid_color: Color, ingredient_id: String = "", max_pour_fill: float = 0.5) -> bool:
	if _is_pouring or fill_level >= 1.0:
		return false

	_is_pouring = true
	_pour_start_level = fill_level
	_pour_ceiling = minf(fill_level + max_pour_fill, 1.0)
	_active_pour_ingredient = ingredient_id
	_pour_max_reached = false
	_kill_wave_tween()
	change_drink_flavor(liquid_color)
	return true


func stop_pour() -> float:
	if not _is_pouring:
		return 0.0
	return _finish_pour()


func reset_liquid() -> void:
	_is_pouring = false
	_pour_start_level = 0.0
	_pour_ceiling = 0.0
	_active_pour_ingredient = ""
	fill_level = 0.0
	_added_fruits.clear()
	_liquid_material.set_shader_parameter("fill_amount", 0.0)
	_set_wave_amplitude(0.0)


func _finish_pour() -> float:
	var poured_amount := fill_level - _pour_start_level
	_is_pouring = false
	_pour_start_level = 0.0
	_pour_ceiling = 0.0
	_active_pour_ingredient = ""
	_pour_max_reached = false
	_fade_wave_out()
	return poured_amount


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
	_kill_wave_tween()
	slosh_sfx.play()
	_liquid_material.set_shader_parameter("wave_amplitude", slosh_wave_amp)
	_wave_tween = create_tween()
	_wave_tween.tween_property(_liquid_material, "shader_parameter/wave_amplitude", 0.0, 1.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func _fade_wave_out() -> void:
	_kill_wave_tween()
	_wave_tween = create_tween()
	_wave_tween.tween_property(_liquid_material, "shader_parameter/wave_amplitude", 0.0, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func _set_wave_amplitude(amplitude: float) -> void:
	_kill_wave_tween()
	_liquid_material.set_shader_parameter("wave_amplitude", amplitude)


func _kill_wave_tween() -> void:
	if _wave_tween and _wave_tween.is_valid():
		_wave_tween.kill()
	_wave_tween = null


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
