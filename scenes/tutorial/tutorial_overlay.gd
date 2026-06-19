class_name TutorialOverlay
extends CanvasLayer

const DIM_COLOR := Color(0, 0, 0, 0.65)
const HOLE_PADDING := Vector2(12, 12)

@onready var _overlay_root: Control = $OverlayRoot
@onready var _highlight_template: PanelContainer = $OverlayRoot/HighlightBorder
@onready var _prompt_label: Label = $OverlayRoot/PromptPanel/MarginContainer/Label
@onready var _prompt_panel: PanelContainer = $OverlayRoot/PromptPanel

var _dim_pool: Array[ColorRect] = []
var _highlight_pool: Array[PanelContainer] = []


func _ready() -> void:
	layer = 200
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_highlight_template.visible = false
	_highlight_template.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for legacy_panel in [$OverlayRoot/Top, $OverlayRoot/Bottom, $OverlayRoot/Left, $OverlayRoot/Right]:
		legacy_panel.visible = false
		legacy_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_overlay()


static func rect_from_control(node: Control) -> Rect2:
	return node.get_global_rect()


static func rect_from_area(area: Area2D) -> Rect2:
	var points: PackedVector2Array = PackedVector2Array()
	for child in area.get_children():
		if child is CollisionPolygon2D:
			var collision := child as CollisionPolygon2D
			for point in collision.polygon:
				points.append(collision.global_transform * point)
	if points.is_empty():
		return Rect2(area.global_position, Vector2(64, 64))
	return rect_from_points(points)


static func rect_from_node2d(root: Node2D) -> Rect2:
	var points: PackedVector2Array = PackedVector2Array()
	_collect_node2d_points(root, points)
	if points.is_empty():
		return Rect2(root.global_position, Vector2(64, 64))
	return rect_from_points(points)


static func rect_from_points(points: PackedVector2Array) -> Rect2:
	var min_v := points[0]
	var max_v := points[0]
	for point in points:
		min_v = min_v.min(point)
		max_v = max_v.max(point)
	return Rect2(min_v, max_v - min_v)


static func _collect_node2d_points(node: Node, points: PackedVector2Array) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Control:
		var rect := rect_from_control(node as Control)
		points.append(rect.position)
		points.append(rect.end)
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		if sprite.texture == null:
			return
		var local_rect := sprite.get_rect()
		points.append(sprite.to_global(local_rect.position))
		points.append(sprite.to_global(Vector2(local_rect.end.x, local_rect.position.y)))
		points.append(sprite.to_global(local_rect.end))
		points.append(sprite.to_global(Vector2(local_rect.position.x, local_rect.end.y)))
	for child in node.get_children():
		_collect_node2d_points(child, points)


static func union_rects(rects: Array) -> Rect2:
	if rects.is_empty():
		return Rect2()
	var result: Rect2 = rects[0]
	for i in range(1, rects.size()):
		result = result.merge(rects[i])
	return result


func show_highlight(hole: Rect2, message: String) -> void:
	show_highlight_holes([hole], message)


func show_highlight_rects(rects: Array, message: String) -> void:
	show_highlight_holes(rects, message)


func show_highlight_holes(holes: Array, message: String) -> void:
	visible = true
	var padded: Array[Rect2] = []
	for hole in holes:
		if hole.size == Vector2.ZERO:
			continue
		padded.append(
			hole.grow_individual(HOLE_PADDING.x, HOLE_PADDING.y, HOLE_PADDING.x, HOLE_PADDING.y)
		)
	if padded.is_empty():
		return

	_prompt_label.text = message
	var prompt_rect := _compute_prompt_rect(union_rects(padded))
	var all_holes: Array[Rect2] = padded.duplicate()
	all_holes.append(prompt_rect)
	_layout_holes(all_holes)
	_prompt_panel.global_position = prompt_rect.position
	_overlay_root.move_child(_prompt_panel, -1)


func hide_overlay() -> void:
	visible = false
	_hide_pool(_dim_pool)
	_hide_pool(_highlight_pool)


func _layout_holes(holes: Array[Rect2]) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var dim_regions := _regions_minus_holes(Rect2(Vector2.ZERO, viewport_size), holes)

	for i in dim_regions.size():
		var panel := _ensure_dim_panel(i)
		panel.visible = true
		panel.position = dim_regions[i].position
		panel.size = dim_regions[i].size

	for i in range(dim_regions.size(), _dim_pool.size()):
		_dim_pool[i].visible = false

	for i in holes.size():
		var border := _ensure_highlight(i)
		border.visible = true
		border.global_position = holes[i].position
		border.size = holes[i].size

	for i in range(holes.size(), _highlight_pool.size()):
		_highlight_pool[i].visible = false


func _regions_minus_holes(viewport: Rect2, holes: Array[Rect2]) -> Array[Rect2]:
	var regions: Array[Rect2] = [viewport]
	for hole in holes:
		var next: Array[Rect2] = []
		for region in regions:
			next.append_array(_subtract_hole(region, hole))
		regions = next
	return regions


func _subtract_hole(region: Rect2, hole: Rect2) -> Array[Rect2]:
	if not region.intersects(hole):
		return [region]

	var pieces: Array[Rect2] = []
	var region_end := region.end
	var hole_end := hole.end

	if hole.position.y > region.position.y:
		pieces.append(Rect2(region.position, Vector2(region.size.x, hole.position.y - region.position.y)))
	if hole_end.y < region_end.y:
		pieces.append(Rect2(Vector2(region.position.x, hole_end.y), Vector2(region.size.x, region_end.y - hole_end.y)))

	var band_top := maxf(region.position.y, hole.position.y)
	var band_bottom := minf(region_end.y, hole_end.y)
	if band_bottom > band_top:
		if hole.position.x > region.position.x:
			pieces.append(Rect2(
				Vector2(region.position.x, band_top),
				Vector2(hole.position.x - region.position.x, band_bottom - band_top)
			))
		if hole_end.x < region_end.x:
			pieces.append(Rect2(
				Vector2(hole_end.x, band_top),
				Vector2(region_end.x - hole_end.x, band_bottom - band_top)
			))
	return pieces


func _ensure_dim_panel(index: int) -> ColorRect:
	while _dim_pool.size() <= index:
		var panel := ColorRect.new()
		panel.color = DIM_COLOR
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		_overlay_root.add_child(panel)
		_dim_pool.append(panel)
	return _dim_pool[index]


func _ensure_highlight(index: int) -> PanelContainer:
	while _highlight_pool.size() <= index:
		var panel: PanelContainer
		if _highlight_pool.is_empty():
			panel = _highlight_template
		else:
			panel = _highlight_template.duplicate() as PanelContainer
			panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_overlay_root.add_child(panel)
		_highlight_pool.append(panel)
	return _highlight_pool[index]


func _hide_pool(pool: Array) -> void:
	for node in pool:
		node.visible = false


func _compute_prompt_rect(reference: Rect2) -> Rect2:
	_prompt_panel.reset_size()
	var viewport_size := get_viewport().get_visible_rect().size
	var prompt_y := reference.end.y
	if prompt_y + _prompt_panel.size.y > viewport_size.y:
		prompt_y = reference.position.y - _prompt_panel.size.y
	var position := Vector2(
		clampf(reference.position.x, 0.0, viewport_size.x - _prompt_panel.size.x),
		clampf(prompt_y, 0.0, viewport_size.y - _prompt_panel.size.y)
	)
	return Rect2(position, _prompt_panel.size)
