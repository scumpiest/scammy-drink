extends Control

const TUTORIAL_SCENE: String = "res://scenes/tutorial/tutorial_scene.tscn"

@onready var _capy: Sprite2D = $Capy
@onready var _sarah: Sprite2D = $Coworker
@onready var _capy_marker: Marker2D = $CapyMarker
@onready var _sarah_marker: Marker2D = $SarahMarker
@onready var _footsteps: AudioStreamPlayer = $Footsteps
@onready var _bubble_background: PanelContainer = $BubbleBackground
@onready var _chat_bubble: Label = $BubbleBackground/VBoxContainer/PanelContainer/MarginContainer/ChatBubble
@onready var _bubble_tail: MarginContainer = $BubbleBackground/VBoxContainer/MarginContainer
@onready var _voice_player: AudioStreamPlayer = $VoicePlayer
@onready var _start_button: Button = $Footer/StartTutorialButton

@export var lerp_weight: float = 1.0
@export var wiggle_angle_degrees: float = 2.0
@export var wiggle_period: float = 1.0
@export var pop_duration: float = 1.0

const ARRIVAL_THRESHOLD: float = 8.0
const ENTRANCE_PAUSE: float = 1.0
const SARAH_PERSONA: String = "sarah"
const SARAH_INTRO_EVENTS: Array[String] = [
	"1_start",
	"2_autoplay_after_one",
	"3_clicked_on",
	"4_autoplay_after_3",
]
const SARAH_INTRO_VO: Array[AudioStream] = [
	preload("res://assets/VO/Sarah/Sarah 1 start.wav"),
	preload("res://assets/VO/Sarah/Sarah 2 autoplay after 1.wav"),
	preload("res://assets/VO/Sarah/Sarah 3 clicked on.wav"),
	preload("res://assets/VO/Sarah/Sarah 4 autoplay after 3.wav"),
]

var _current_target: Marker2D = null
var _moving_sprite: Sprite2D = null
var _sarah_wiggle_tween: Tween = null


func _ready() -> void:
	_bubble_background.visible = false
	_bubble_tail.visible = false
	_start_button.visible = false
	_start_button.pressed.connect(_on_start_tutorial_pressed)
	_play_entrance_sequence()


func _process(delta: float) -> void:
	if not _current_target or not _moving_sprite:
		return

	_moving_sprite.position = _moving_sprite.position.lerp(
		_current_target.position,
		1.0 - exp(-lerp_weight * delta)
	)
	if _moving_sprite.position.distance_to(_current_target.position) <= ARRIVAL_THRESHOLD:
		_moving_sprite.position = _current_target.position
		_stop_movement()


func _play_entrance_sequence() -> void:
	await _slide_to_marker(_capy, _capy_marker)
	await get_tree().create_timer(ENTRANCE_PAUSE).timeout
	await _slide_to_marker(_sarah, _sarah_marker)
	await _play_sarah_intro_dialogue()


func _play_sarah_intro_dialogue() -> void:
	_setup_bottom_pivot(_sarah)
	_bubble_background.visible = true
	_start_sarah_wiggle()

	for i in SARAH_INTRO_EVENTS.size():
		var event_name: String = SARAH_INTRO_EVENTS[i]
		_chat_bubble.text = DialogueBank.get_customer_line(SARAH_PERSONA, event_name)
		await _position_bubble()
		_voice_player.stream = SARAH_INTRO_VO[i]
		_voice_player.play()
		await _voice_player.finished

	_stop_sarah_wiggle()
	_bubble_background.visible = false
	_show_start_button()


func _show_start_button() -> void:
	_start_button.visible = true
	_start_button.scale = Vector2.ZERO
	_start_button.modulate.a = 0.0
	_start_button.pivot_offset = _start_button.size / 2.0

	var tween := create_tween()
	tween.tween_property(_start_button, "scale", Vector2.ONE, pop_duration) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_start_button, "modulate:a", 1.0, pop_duration * 0.5)


func _on_start_tutorial_pressed() -> void:
	GameManager.prepare_tutorial("cedevita")
	SceneManager.switch_scene(TUTORIAL_SCENE)


func _setup_bottom_pivot(sprite: Sprite2D) -> void:
	var tex_size := sprite.texture.get_size()
	var scaled_size := tex_size * sprite.scale
	var bottom_center := sprite.position + Vector2(0.0, scaled_size.y / 2.0)
	sprite.offset = Vector2(0.0, -tex_size.y / 2.0)
	sprite.position = bottom_center


func _start_sarah_wiggle() -> void:
	var angle := deg_to_rad(wiggle_angle_degrees)
	_sarah_wiggle_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sarah_wiggle_tween.tween_property(_sarah, "rotation", angle, wiggle_period)
	_sarah_wiggle_tween.tween_property(_sarah, "rotation", -angle, wiggle_period)


func _stop_sarah_wiggle() -> void:
	if _sarah_wiggle_tween:
		_sarah_wiggle_tween.kill()
		_sarah_wiggle_tween = null
	_sarah.rotation = 0.0


func _position_bubble() -> void:
	await get_tree().process_frame
	var viewport_size := get_viewport_rect().size
	var bubble_size := _bubble_background.size
	_bubble_background.position = (viewport_size - bubble_size)


func _slide_to_marker(sprite: Sprite2D, marker: Marker2D) -> void:
	_moving_sprite = sprite
	_current_target = marker
	_footsteps.play()
	while _current_target != null:
		await get_tree().process_frame


func _stop_movement() -> void:
	_current_target = null
	_moving_sprite = null
	_footsteps.stop()
