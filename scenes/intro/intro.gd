extends Node

var panels: Array
var panel_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panels = get_children()
	panel_index = 0
	
func _process(delta) -> void:
	intro()
	
func intro() -> void:
	var panel = panels[panel_index]
	panel.self_modulate.a = lerpf(panel.self_modulate.a, 200.0, .001)
	await get_tree().create_timer(1).timeout
	print(panel.self_modulate.a)
	if panel.self_modulate.a >= 250.0 && panel_index + 1 < panels.size():
		panel_index += 1
		await get_tree().create_timer(5.0).timeout
