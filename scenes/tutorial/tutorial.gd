extends Node

signal tutorial_complete
signal box_complete

@onready var counterui := get_parent()

var tutorial_scene
var text_box_list: Array
var box_index: int

@onready var current_target: Marker2D = counterui.find_child("EnterMarker")
var customer: Customer
var lerp_weight: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(current_target)
	box_index = 0
	text_box_list = self.get_children()
	text_box_list[box_index].show()
	
	counterui.fruits_interactible = false
	counterui.liquids_interactible = false
	counterui.mixer_interactible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_target and customer and is_instance_valid(customer):
		customer.position = customer.position.lerp(current_target.global_position, 1.0 - exp(-lerp_weight * delta))
	#counterui._update_ingredient_tooltip()
	
func _input(event):
	if event.is_action_pressed("next_tutorial_box"):
		text_box_list[box_index].hide()
		script()
		
		if  box_index + 1 < text_box_list.size():
			box_index += 1
			text_box_list[box_index].show()
			
		else:
			text_box_list[box_index].hide()
			tutorial_complete.emit()
		

		
func script():
	if box_index == 2:
		print("flag ")
		customer = get_parent().spawn_customer()
		get_parent().setup_customer(customer)
	elif box_index == 4:
		counterui.liquids_interactible = true
	elif box_index == 7:
		counterui.fruits_interactible = true
	elif box_index == 8:
		counterui.mixer_interactible = true
	elif box_index == 4:
		pass
	elif box_index == 5:
		pass
	elif box_index == 6:
		pass
	elif box_index == 7:
		pass
	elif box_index == 8:
		pass
	elif box_index == 9:
		pass
	elif box_index == 10:
		pass
	elif box_index == 11:
		pass
	elif box_index == 12:
		pass
	elif box_index == 13:
		pass
	elif box_index == 14:
		pass
