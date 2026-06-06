extends PanelContainer

@onready var item_list: RichTextLabel = $MarginContainer/HBoxContainer/MidContainer/ItemList
@onready var mix_button: Button = $MarginContainer/HBoxContainer/MidContainer/Mix

var crafting_ingredients = {}

func _ready() -> void:
	GameManager.crafting_complete.connect(_on_crafting_complete)


func _add_ingredient(ingredient: String) -> void:
	if crafting_ingredients.size() < 3 or crafting_ingredients.has(ingredient):
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

func _on_mix_pressed():
	GameManager.create_recipe(crafting_ingredients)

func _on_crafting_complete(recipe_key: String) -> void:
	mix_button.disabled = true
	item_list.text += recipe_key + "\n"

func _on_reset_pressed():
	get_tree().call_group("fluid_button", "set", "disabled", false)
	get_tree().call_group("fruit_button", "set", "disabled", false)
	mix_button.disabled = false
	item_list.text = ""
	crafting_ingredients = {}

# help me
func _on_soda_pressed():  _add_ingredient("soda")
func _on_milk_pressed():  _add_ingredient("milk")
func _on_water_pressed(): _add_ingredient("water")
func _on_white_wine_pressed(): _add_ingredient("white_wine")
func _on_lime_juice_pressed(): _add_ingredient("lime_juice")
func _on_coconut_cream_pressed(): _add_ingredient("coconut_cream")
func _on_ice_pressed(): _add_ingredient("ice")

func _on_mixed_fruits_pressed(): _add_ingredient("mixed_fruits")
func _on_orange_pressed(): _add_ingredient("orange")
func _on_pineapple_pressed(): _add_ingredient("pineapple")
func _on_apple_pressed(): _add_ingredient("apple")
func _on_lemon_pressed(): _add_ingredient("lemon")
func _on_mint_pressed(): _add_ingredient("mint")
func _on_strawberry_pressed(): _add_ingredient("strawberry")
