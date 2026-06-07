extends PanelContainer

@onready var item_list: RichTextLabel = $MarginContainer/HBoxContainer/MidContainer/ItemList
@onready var mix_button: Button = $MarginContainer/HBoxContainer/MidContainer/Mix
@onready var glass: Node2D = $MarginContainer/HBoxContainer/MidContainer/Glass

var crafting_ingredients = {}

func _ready() -> void:
	glass.ingredient_added.connect(_on_ingredient_added)
	GameManager.crafting_complete.connect(_on_crafting_complete)


func _add_ingredient(ingredient: String) -> void:
	if crafting_ingredients.has(ingredient):
		return

	if crafting_ingredients.size() < 3:
		crafting_ingredients[ingredient] = crafting_ingredients.get(ingredient, 0) + 1
		item_list.text += ingredient + "\n"

	if _get_total_ingredients() >= 3:
			get_tree().call_group("fluid_button", "set", "disabled", true)
			get_tree().call_group("fruit_button", "set", "disabled", true)
			print("Max ingredients reached. Buttons disabled!")

func _get_total_ingredients() -> int:
	var total = 0
	for count in crafting_ingredients.values():
		total += count
	return total

func reset() -> void:
	crafting_ingredients.clear()

	item_list.text = ""
	get_tree().call_group("fluid_button", "set", "disabled", false)
	get_tree().call_group("fruit_button", "set", "disabled", false)

func _on_mix_pressed():
	GameManager.create_recipe(crafting_ingredients)

func _on_crafting_complete(recipe_key) -> void:
	item_list.text += recipe_key + "\n"
	reset()

func _on_reset_pressed():
	reset()


func _on_ingredient_added(ingredient: String) -> void:
	_add_ingredient(ingredient)

# help me
func _on_soda_pressed():  _add_ingredient("soda")
func _on_milk_pressed():  _add_ingredient("milk")
func _on_water_pressed(): _add_ingredient("water")
func _on_white_wine_pressed(): _add_ingredient("white_wine")
func _on_lime_juice_pressed(): _add_ingredient("lime_juice")
func _on_coconut_cream_pressed(): _add_ingredient("coconut_cream")
func _on_ice_pressed(): _add_ingredient("ice")
