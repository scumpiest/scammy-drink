extends Node2D

signal mix_animation_finished

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _glass: Node2D = $BlenderFront/Glass
@onready var _mix_button: TextureButton = $BlenderButton
@onready var _crafting_counter: Node2D = get_parent()
@onready var mix_sfx: AudioStreamPlayer2D = $MixSFX

func _ready() -> void:
	_mix_button.pressed.connect(_on_mix_button_pressed)
	_animation_player.animation_finished.connect(_on_animation_finished)
	_crafting_counter.ingredients_changed.connect(_update_mix_button_state)
	_update_mix_button_state()


func _on_mix_button_pressed() -> void:
	if GameManager.can_mix:
		mix_sfx.play()
		_crafting_counter.mix()
		_animation_player.play(&"mix")
		_glass.trigger_slosh()
		_mix_button.disabled = true
		_update_mix_button_state()
		GameManager._set_can_mix(false)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"mix":
		_animation_player.play(&"RESET")
		visible = false
		mix_animation_finished.emit()


func show_blender() -> void:
	visible = true
	_animation_player.play(&"RESET")
	_update_mix_button_state()


func is_mix_button_hovered() -> bool:
	if not visible:
		return false
	return _mix_button.get_global_rect().has_point(get_global_mouse_position())


func _update_mix_button_state() -> void:
	var ready_to_mix: bool = _crafting_counter.get_total_ingredients() >= 3
	_mix_button.disabled = not ready_to_mix or not GameManager.can_mix
