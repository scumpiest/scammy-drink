extends Control

enum Step {
	INSPECT_NOTES,
	POUR_FLUID,
	ADD_FRUIT_1,
	ADD_FRUIT_2,
	CUSTOMER_FEEDBACK,
	SCRATCH_LINE_3,
	MIX,
	SAVE_NOTES,
	CHECK_RECIPE_BOOK,
	COMPLETE,
}

const PLAY_SCENE: String = "uid://omqlt0501aof"
const DIALOGUE_HIGHLIGHT_WIDTH_EXTRA: float = 200.0
const DIALOGUE_HIGHLIGHT_X_OFFSET: float = 15.0
const MIX_BUTTON_HIGHLIGHT_X_OFFSET: float = 15.0
const MIX_BUTTON_HIGHLIGHT_Y_OFFSET: float = -20.0

@onready var _counter_ui: Control = $CounterUi
@onready var _overlay: TutorialOverlay = $TutorialOverlay

var _step: Step = Step.INSPECT_NOTES
var _waiting_for_space: bool = false

var _crafting_counter: Node2D
var _blender: Node2D
var _notes: PanelContainer
var _capy_notes: CapyNotesPanel
var _customer: Customer
var _recipe_button: Control
var _recipe_book: Control
var _settings_button: Control


func _ready() -> void:
	_crafting_counter = _counter_ui.get_node("CraftingCounter")
	_blender = _crafting_counter.get_node("Blender")
	_notes = _counter_ui.get_node("Notes") as NotesPanel
	_capy_notes = _counter_ui.get_node("CapyNotes") as CapyNotesPanel
	_customer = _counter_ui.customer
	_recipe_button = _counter_ui.get_node("RecipeButton")
	_recipe_book = _counter_ui.get_node("RecipeBook")
	_settings_button = _counter_ui.get_node("SettingsButton")

	_recipe_button.visible = false
	_settings_button.visible = false

	_crafting_counter.drink_ingredient_added.connect(_on_drink_ingredient_added)
	_notes.line_scratched.connect(_on_line_scratched)
	_crafting_counter.mix_animation_finished.connect(_on_mix_animation_finished)
	SignalBus.notes_saved.connect(_on_notes_saved)
	_recipe_button.pressed.connect(_on_recipe_button_pressed)
	_recipe_book.get_node("CloseButton").pressed.connect(_on_recipe_book_closed)
	_customer.tutorial_feedback_ready.connect(_on_tutorial_feedback_ready)
	_customer.ingredient_dialogue_finished.connect(_on_ingredient_dialogue_finished)
	_notes.save_button_shown.connect(_on_save_button_shown)

	call_deferred("_begin_tutorial")


func _begin_tutorial() -> void:
	_advance_to_step(Step.INSPECT_NOTES)


func _input(event: InputEvent) -> void:
	if not _waiting_for_space:
		return
	if not event.is_action_pressed("next_tutorial_box"):
		return
	get_viewport().set_input_as_handled()
	_set_waiting_for_space(false)
	_advance_step()


func _advance_step() -> void:
	match _step:
		Step.INSPECT_NOTES:
			_advance_to_step(Step.POUR_FLUID)
		Step.CUSTOMER_FEEDBACK:
			_advance_to_step(Step.ADD_FRUIT_2)
		Step.COMPLETE:
			_finish_tutorial()
		_:
			pass


func _advance_to_step(next_step: Step) -> void:
	_step = next_step
	_set_waiting_for_space(false)

	match _step:
		Step.INSPECT_NOTES:
			_overlay.show_highlight(
				TutorialOverlay.rect_from_control(_notes),
				"Check the order. Something is wrong! Our coworker gave us the wrong recipe. We need to find a way to fix it."
			)
			_set_waiting_for_space(true)
		Step.POUR_FLUID:
			var soda_button: Control = _crafting_counter.get_node("Soda")
			_show_ingredient_highlight(
				TutorialOverlay.rect_from_control(soda_button),
				"Lets start by pouring the soda onto the mixer."
			)
		Step.ADD_FRUIT_1:
			var pineapple_area: Area2D = _crafting_counter.get_node("Pineapple")
			_show_ingredient_highlight(
				TutorialOverlay.rect_from_area(pineapple_area),
				"Now add the pineapple to the mixer."
			)
		Step.CUSTOMER_FEEDBACK:
			_overlay.show_highlight(
				_dialogue_highlight_rect(),
				"The customer noticed something. The note was misleading, listen to what they say."
			)
		Step.ADD_FRUIT_2:
			var ice_area: Area2D = _crafting_counter.get_node("Ice")
			_show_ingredient_highlight(
				TutorialOverlay.rect_from_area(ice_area),
				"Add the ice to finish the drink."
			)
		Step.SCRATCH_LINE_3:
			_show_scratch_step(2, 2, "Drag the ice from Capy Notes onto the lemon line to fix it.")
		Step.MIX:
			_overlay.show_highlight(
				_mix_button_highlight_rect(),
				"Mix the drink!"
			)
		Step.SAVE_NOTES:
			pass
		Step.CHECK_RECIPE_BOOK:
			_recipe_button.visible = true
			_overlay.show_highlight(
				TutorialOverlay.rect_from_control(_recipe_button),
				"You can check the recipe book to see your saved notes."
			)
		Step.COMPLETE:
			_overlay.show_highlight(
				Rect2(get_viewport().get_visible_rect().size * 0.5 - Vector2(160, 40), Vector2(320, 80)),
				"You're ready!"
			)
			_set_waiting_for_space(true)


func _set_waiting_for_space(waiting: bool) -> void:
	_waiting_for_space = waiting
	_overlay.set_continue_hint_visible(waiting)


func _show_ingredient_highlight(ingredient_rect: Rect2, message: String) -> void:
	_overlay.show_highlight_rects(
		[ingredient_rect, TutorialOverlay.rect_from_node2d(_blender)],
		message
	)


func _mix_button_highlight_rect() -> Rect2:
	var mix_button: Control = _crafting_counter.get_node("Blender/BlenderButton") as Control
	var rect := TutorialOverlay.rect_from_control(mix_button)
	rect.position.x += MIX_BUTTON_HIGHLIGHT_X_OFFSET
	rect.position.y += MIX_BUTTON_HIGHLIGHT_Y_OFFSET
	return rect


func _dialogue_highlight_rect() -> Rect2:
	var rect := TutorialOverlay.rect_from_control(_customer.bubble_background)
	rect.position.x += DIALOGUE_HIGHLIGHT_X_OFFSET
	rect.size.x += DIALOGUE_HIGHLIGHT_WIDTH_EXTRA
	return rect


func _on_save_button_shown() -> void:
	if _step != Step.SAVE_NOTES:
		return
	_show_save_highlight()


func _show_save_highlight() -> void:
	if _step != Step.SAVE_NOTES:
		return
	await get_tree().process_frame
	if _step != Step.SAVE_NOTES:
		return
	_overlay.show_highlight(
		TutorialOverlay.rect_from_control(_notes.get_save_button()),
		"Save your corrected notes."
	)


func _show_scratch_step(line_index: int, chip_index: int, message: String) -> void:
	call_deferred("_show_scratch_step_impl", line_index, chip_index, message)


func _show_scratch_step_impl(line_index: int, chip_index: int, message: String) -> void:
	var line: NoteLine = _notes.get_ingredient_line(line_index)
	var chip_rect := _capy_notes.get_chip_rect_by_index(chip_index)
	var rects: Array = [TutorialOverlay.rect_from_control(line)]
	if chip_rect.size != Vector2.ZERO:
		rects.append(chip_rect)
	_overlay.show_highlight_rects(rects, message)


func _on_drink_ingredient_added(ingredient: String) -> void:
	match _step:
		Step.POUR_FLUID:
			if ingredient == "soda":
				_advance_to_step(Step.ADD_FRUIT_1)
		Step.ADD_FRUIT_1:
			if ingredient == "pineapple":
				_advance_to_step(Step.CUSTOMER_FEEDBACK)
		Step.ADD_FRUIT_2:
			if ingredient == "ice":
				_advance_to_step(Step.SCRATCH_LINE_3)


func _on_tutorial_feedback_ready() -> void:
	if _step == Step.CUSTOMER_FEEDBACK:
		_overlay.show_highlight(
			_dialogue_highlight_rect(),
			"The customer noticed something — the note was misleading."
		)


func _on_ingredient_dialogue_finished() -> void:
	if _step != Step.CUSTOMER_FEEDBACK:
		return
	_set_waiting_for_space(true)


func _on_line_scratched(line_index: int) -> void:
	if _step == Step.SCRATCH_LINE_3 and line_index == 2:
		_advance_to_step(Step.MIX)


func _on_mix_animation_finished() -> void:
	if _step == Step.MIX:
		_advance_to_step(Step.SAVE_NOTES)


func _on_notes_saved(_notes_content: Dictionary) -> void:
	if _step == Step.SAVE_NOTES:
		_advance_to_step(Step.CHECK_RECIPE_BOOK)


func _on_recipe_button_pressed() -> void:
	if _step != Step.CHECK_RECIPE_BOOK:
		return
	call_deferred("_show_cedevita_highlight")


func _show_cedevita_highlight() -> void:
	if _step != Step.CHECK_RECIPE_BOOK or not _recipe_book.visible:
		return
	var cedevita: Control = _recipe_book.get_drink_panel(GameManager.get_order())
	if cedevita == null:
		return
	var close_button: Control = _recipe_book.get_node("CloseButton")
	_overlay.show_highlight_rects(
		[
			TutorialOverlay.rect_from_control(cedevita),
			TutorialOverlay.rect_from_control(close_button),
		],
		"Your saved notes appear here. Close the book when you're done."
	)


func _on_recipe_book_closed() -> void:
	if _step != Step.CHECK_RECIPE_BOOK:
		return
	_advance_to_step(Step.COMPLETE)


func _finish_tutorial() -> void:
	_overlay.hide_overlay()
	GameManager.complete_tutorial()
	SceneManager.switch_scene(PLAY_SCENE)
