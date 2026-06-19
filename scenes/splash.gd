extends Node2D

signal finished

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_sprite.sprite_frames.set_animation_loop(&"done", false)
	_sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)
	_sprite.play(&"done")


func _on_animation_finished() -> void:
	finished.emit()
	queue_free()
