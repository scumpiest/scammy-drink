extends RichTextLabel

var statement: String

func _process(delta: float) -> void:
	for item in GameManager.inventory:
		statement = (statement + str(GameManager.inventory[item]) + ": " + item + "\n")
	self.text = statement
	statement = ""
