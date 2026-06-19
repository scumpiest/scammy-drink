extends PanelContainer
class_name NotesPanel

signal notes_saved(notes_content: Dictionary)
signal drink_cleared
signal line_scratched(line_index: int)

@onready var drink_name: NoteLine = $MarginContainer/VBoxContainer/DrinkName
@onready var ingredient1: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient1
@onready var ingredient2: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient2
@onready var ingredient3: NoteLine = $MarginContainer/VBoxContainer/VBoxContainer/Ingredient3
@onready var _save_button: Button = $MarginContainer/VBoxContainer/VBoxContainer/Save

const TUTORIAL_FAKE_BY_LINE: Dictionary = {
	1: "pineapple",
	2: "lemon",
}

const FLUID_KEYS: Array[String] = [
	"white_wine",
	"water",
	"soda",
	"milk",
	"lime_juice",
	"coconut_cream",
]

var random_chance: float = 0.0
var notes_content: Dictionary = {}


func update_display() -> void:
	_hide_save_button()
	var order_data: Dictionary = get_order_data()

	random_chance = order_data["random_chance"]

	drink_name.update_from_order(order_data["fake_name"])
	update_ingredients(order_data["ingredients"], random_chance)


func set_tutorial_display(recipe_key: String, fake_line_indices: Array[int]) -> void:
	_hide_save_button()
	var recipe_data: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var real_ingredients: Array = recipe_data["ingredients"].keys()
	var ordered_ingredients: Array = _put_fluid_first(real_ingredients)
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	var fake_pool: Array[String] = []
	for key in GameManager.inventory.keys():
		if not real_ingredients.has(key):
			fake_pool.append(key)
	fake_pool.sort()
	var fake_pick_index: int = 0

	drink_name.update_from_order(recipe_data["fake_name"])

	for i in ingredient_lines.size():
		var ingredient: String = ""
		if fake_line_indices.has(i):
			var preferred: String = TUTORIAL_FAKE_BY_LINE.get(i, "")
			if not preferred.is_empty() and preferred in fake_pool:
				ingredient = preferred
			elif fake_pick_index < fake_pool.size():
				ingredient = fake_pool[fake_pick_index]
				fake_pick_index += 1
			else:
				ingredient = ordered_ingredients[i]
		else:
			ingredient = ordered_ingredients[i]
		ingredient_lines[i].update_from_order(ingredient)


func update_notes_content() -> void:
	notes_content = {
		"recipe_key": GameManager.get_order(),
		"drink_name": drink_name.text,
		"ingredients": [ingredient1.text, ingredient2.text, ingredient3.text],
	}

func get_order_data() -> Dictionary:
	var recipe_key: String = GameManager.get_order()
	var recipe_data: Dictionary = CraftingRecipe.crafting_dict[recipe_key]
	var ingredients: Dictionary = recipe_data["ingredients"]
	var fake_name: String = recipe_data["fake_name"]
	var ingredients_array: Array = ingredients.keys()

	return {
		"recipe_key": recipe_key,
		"ingredients": ingredients_array,
		"random_chance": recipe_data["random_chance"],
		"fake_name": fake_name,
	}


func update_ingredients(real_ingredients: Array, chance: float) -> void:
	var ordered_ingredients: Array = _put_fluid_first(real_ingredients)
	var inventory_keys: Array = GameManager.inventory.keys()
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	var used_ingredients: Array[String] = []

	var fake_pool: Array = []
	for key in inventory_keys:
		if not real_ingredients.has(key):
			fake_pool.append(key)

	var has_fakes_available: bool = not fake_pool.is_empty()

	for i in ingredient_lines.size():
		var ingredient: String = ""

		if randf() < chance or not has_fakes_available:
			ingredient = ordered_ingredients[i]
		else:
			var available_fakes: Array = []
			for key in fake_pool:
				if not used_ingredients.has(key):
					if i == 0 and not _is_fluid(key):
						continue
					available_fakes.append(key)

			if available_fakes.is_empty():
				ingredient = ordered_ingredients[i]
			else:
				var random_index: int = randi_range(0, available_fakes.size() - 1)
				ingredient = available_fakes[random_index]

		used_ingredients.append(ingredient)
		ingredient_lines[i].update_from_order(ingredient)


func _is_fluid(ingredient: String) -> bool:
	return FLUID_KEYS.has(ingredient)


func _put_fluid_first(ingredients: Array) -> Array:
	var ordered: Array = ingredients.duplicate()
	for i in ordered.size():
		if _is_fluid(ordered[i]):
			if i > 0:
				var fluid: String = ordered[i]
				ordered.remove_at(i)
				ordered.insert(0, fluid)
			return ordered
	return ordered


func try_scratch_at_position(global_pos: Vector2, replacement: String) -> bool:
	var lines: Array[NoteLine] = [drink_name, ingredient1, ingredient2, ingredient3]
	for line in lines:
		if line.get_global_rect().has_point(global_pos):
			return _scratch_line(line, replacement)
	return false


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.get("type", "") == "ingredient"):
		return false
	var global_pos := get_global_transform() * at_position
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	for line in ingredient_lines:
		if line.get_global_rect().has_point(global_pos) and not line.is_scratched:
			return true
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var ingredient: String = data.get("name", "")
	var global_pos := get_global_transform() * at_position
	var ingredient_lines: Array[NoteLine] = [ingredient1, ingredient2, ingredient3]
	for line in ingredient_lines:
		if line.get_global_rect().has_point(global_pos):
			_scratch_line(line, ingredient)
			return


func get_ingredient_line(index: int) -> NoteLine:
	match index:
		0:
			return ingredient1
		1:
			return ingredient2
		2:
			return ingredient3
		_:
			return ingredient1


func get_save_button_global_rect() -> Rect2:
	return _save_button.get_global_rect()


func _scratch_line(line: NoteLine, replacement: String) -> bool:
	if line.is_scratched:
		return false
	line.scratch(replacement)
	var line_index: int = _ingredient_line_index(line)
	line_scratched.emit(line_index)
	return true


func _ingredient_line_index(line: NoteLine) -> int:
	if line == ingredient1:
		return 0
	if line == ingredient2:
		return 1
	if line == ingredient3:
		return 2
	return -1


func show_save_button() -> void:
	_save_button.visible = true


func _hide_save_button() -> void:
	_save_button.visible = false


func _on_save_pressed():
	update_notes_content()
	GameManager.save_session_notes(notes_content)
	SignalBus.notes_saved.emit(notes_content)
	_hide_save_button()
	drink_cleared.emit()
