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

	GameManager.crafting_result.connect(_on_crafting_result)

## Always accepts the drink; shows which ingredients were missing before leaving.
func _on_crafting_result(_recipe_key: String, _correct_count: int, _missing_ingredients: Array) -> void:
	if _recipe_key != request:
		return
	bubble_background.visible = true
	if _missing_ingredients.is_empty():
		chat_bubble.text = "Thanks for the " + request + "!"
	else:
		var ingredients_str: String = ", ".join(_missing_ingredients)
		chat_bubble.text = "You forgot " + ingredients_str + "... but I'll take it!"
	await get_tree().create_timer(1.5).timeout
	request_completed.emit()
	bubble_background.visible = false
	request = ""
