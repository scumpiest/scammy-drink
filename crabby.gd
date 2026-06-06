extends Area2D

signal request_completed
signal request_failed

@onready var bubble_background: PanelContainer = $BubbleBackground
@onready var chat_bubble: Label = $BubbleBackground/ChatBubble

var request: String = ""

func _ready() -> void:
	request = CraftingRecipe.get_recipes().pick_random()
	chat_bubble.text = "GIMME " + request.to_upper() + "!!"
	GameManager.crafting_complete.connect(_on_crafting_complete)

func _on_crafting_complete(_recipe_key) -> void:
	bubble_background.visible = true
	if _recipe_key == request:
		chat_bubble.text = "Thanks for the " + _recipe_key + "!"
		await get_tree().create_timer(2.5).timeout
		request_completed.emit()
		bubble_background.visible = false
		request = ""
	else:
		print("I DONT WANT THAT, GIVE ME " + request + "!!")
		chat_bubble.text = "I DONT WANT THAT, GIVE ME " + request.to_upper() + "!!"
		request_failed.emit()
