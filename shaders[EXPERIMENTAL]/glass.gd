extends Node2D

signal ingredient_added(ingredient: String)

@onready var liquid_rect = $LiquidMask/LiquidRect
@onready var splash_particles = $WaterArea/SplashParticles
@onready var water_area = $WaterArea
@onready var slosh_sfx = $SloshSFX

@export var float_force: float = 380.0
@export var water_damp: float = 4.5

var current_fill : float = 0.5
var target_fill : float = 1.0

var pour_speed: float = 0.25
var base_wave_amp: float = 0.015

func _ready():
	assert(liquid_rect != null, "liquid_rect node not found — check the node path")
	assert(liquid_rect.material != null, "LiquidRect has no material assigned")
	liquid_rect.material.set_shader_parameter("fill_amount", 0.5)

func _process(delta):

	# pour liquid
	# if Input.is_action_pressed("ui_select"):
	# 	if current_fill < 1.0:
	# 		current_fill = lerp(current_fill, target_fill, delta * 5.0)
	# 		liquid_rect.material.set_shader_parameter("fill_amount", current_fill)

	# 		liquid_rect.material.set_shader_parameter("wave_amplitude", base_wave_amp * 1.5)
	# else:
	var current_amp = liquid_rect.material.get_shader_parameter("wave_amplitude")
	# 	liquid_rect.material.set_shader_parameter("wave_amplitude", lerp(current_amp, base_wave_amp, 0.1))

func _physics_process(_delta):
	# apply upward buoyancy to anything in the water area
	for body in water_area.get_overlapping_bodies():
		if body is RigidBody2D:
			# calculate depth to push harder the deeper it goes
			var depth = water_area.global_position.y - body.global_position.y
			body.apply_central_force(Vector2.UP * float_force)

# CONNECTED SIGNAL FROM WATERAREA
func _on_water_area_body_entered(body):
	if body is RigidBody2D:
		# apply thick liquid dampening instantly
		body.linear_damp = water_damp
		body.angular_damp = water_damp

		# trigger particle splash at the object's entry point
		splash_particles.global_position.x = body.global_position.x
		splash_particles.restart()

		ingredient_added.emit(body.metadata)
		trigger_slosh()

func trigger_slosh():
	var tween = create_tween()

	slosh_sfx.play()

	liquid_rect.material.set_shader_parameter("splash_intensity", 1.0)
	tween.tween_property(liquid_rect.material, "shader_parameter/splash_intensity", 0.0, 1.5)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

# TODO: call this method when switching recipes!
func change_drink_flavor(new_color: Color):
	liquid_rect.material.set_shader_parameter("liquid_color", new_color)
