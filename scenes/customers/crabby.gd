extends Area2D

signal request_completed
signal request_failed

@onready var bubble_background: PanelContainer = $BubbleBackground
@onready var chat_bubble: Label = $BubbleBackground/ChatBubble
@onready var sprite: Sprite2D = $Sprite2D

var request: String = ""

func _ready() -> void:
	sprite.modulate = Color(randf(), randf(), randf())

	GameManager.add_recipe_order()
	request = GameManager.get_order()
	chat_bubble.text = "GIMME " + request.to_upper() + "!!"

	GameManager.crafting_complete.connect(_on_crafting_complete)
	GameManager.crafting_failed.connect(_on_crafting_failed)
	GameManager.crafting_wrong.connect(_on_crafting_wrong)

## Handles the crafting complete signal, showing the bubble and emitting the request_completed signal.
func _on_crafting_complete(_recipe_key) -> void:
	bubble_background.visible = true
	if _recipe_key == request:
		chat_bubble.text = "Thanks for the " + _recipe_key + "!"
		await get_tree().create_timer(1.5).timeout
		request_completed.emit()
		bubble_background.visible = false
		request = ""

## Handles the crafting failed signal, showing the missing ingredients in the chat bubble.
func _on_crafting_failed(_missing_ingredients, _total_missing_ingredients) -> void:
	if _missing_ingredients != []:
		var ingredients_str = ", ".join(_missing_ingredients)
		chat_bubble.text = "You're missing ingredients: " + ingredients_str + " to make " + request + "!"

## Handles the crafting wrong signal, showing the incorrect recipe in the chat bubble.
func _on_crafting_wrong(_recipe_key) -> void:
	if _recipe_key != request:
		print("I DONT WANT THAT, GIVE ME " + request + "!!")
		chat_bubble.text = "I DONT WANT THAT, GIVE ME " + request.to_upper() + "!!"
		request_failed.emit()
