extends Node

signal scene_changed(new_scene_path)

var current_scene = null

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func switch_scene(next_scene: String) -> void:
	# add animation_player

	# clean up and load
	current_scene.call_deferred("queue_free")
	var new_scene = load(next_scene)
	current_scene = new_scene.instantiate()

	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
