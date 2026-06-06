extends Control

var volumeMusic
var volumeSounds
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_musicslider_value_changed(value: float) -> void:
	await get_tree().create_timer(10).timeout
	volumeMusic = value
	print(volumeMusic)
