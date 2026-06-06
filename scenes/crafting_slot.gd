class_name CraftingSlot
extends Control

signal item_received(item: Area2D)


@onready var area_2d: Area2D = $Area2D

var held_item: Area2D = null


func receive_item(item: Area2D) -> bool:
	if held_item != null:
		return false

	held_item = item
	item.drag_and_drop.drag_started.connect(release_item, CONNECT_ONE_SHOT)
	var snap_position := area_2d.global_position
	var tween := item.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(item, "global_position", snap_position, 0.2)
	item_received.emit(item)
	return true


func release_item() -> Area2D:
	var item := held_item
	held_item = null
	return item
