@tool
extends Node2D

signal sliced

## How long the line will be, in pixels. 
@export var line_length: int = 24:
	set(value):
		line_length = value
		_setup_areas()

## The width of the slice detection. Wider is more lenient for classifying a slice. 
@export var detection_width: int = 24:
	set(value):
		detection_width = value
		_setup_areas()

## How much extra space around the detection areas to add. This makes click detection more lenient. 
@export var detection_padding: int = 8:
	set(value):
		detection_padding = value
		_setup_areas()


var is_dragging: bool = false:
	set(value):
		is_dragging = value
		trail.enabled = value

var start_position: Vector2
var end_position: Vector2

@onready var high_area: Area2D = $HighArea
@onready var mid_area: Area2D = $MidArea
@onready var low_area: Area2D = $LowArea
@onready var valid_area: Area2D = $ValidArea
@onready var trail: Trail = $Trail
@onready var slice_vfx: SliceVfx = $SliceVfx


# Dragging starts if player clicks on a high or low area. 
# Dragging ends if any occurs: 
	# The mouse leaves the valid area
	# Left click is released 
# Detection areas are considered as units in a 3x3 grid. 


func _setup_areas() -> void:
	var valid_area_rect: RectangleShape2D = _get_area_rect(valid_area)
	valid_area_rect.size = Vector2(detection_width, line_length) + (Vector2.ONE * detection_padding)

	var high_area_rect: RectangleShape2D = _get_area_rect(high_area)
	high_area.position.y = - line_length / 3
	var low_area_rect: RectangleShape2D = _get_area_rect(low_area)
	low_area.position.y = line_length / 3
	for rect: RectangleShape2D in [high_area_rect, low_area_rect]:
		rect.size.x = detection_width
		rect.size.y = line_length / 3
	
	var mid_area_rect: RectangleShape2D = _get_area_rect(mid_area)
	mid_area_rect.size = Vector2(detection_width, line_length) / 3


func _get_area_rect(area: Area2D) -> RectangleShape2D:
	return (area.get_node("CollisionShape2D") as CollisionShape2D).shape


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if not _event_is_left_click(event):
		return

	var button_event: InputEventMouseButton = event
	if button_event.pressed:
		_on_press()
	else:
		_on_release()


func _event_is_left_click(event: InputEvent) -> bool:
	if event is not InputEventMouseButton:
		return false

	var button_event: InputEventMouseButton = event
	return button_event.button_index == MOUSE_BUTTON_LEFT


func _on_press() -> void:
	if is_dragging:
		return
	
	var click_position: Vector2 = get_global_mouse_position()
	start_position = click_position
	is_dragging = true
	print("Starting slice at ", start_position)


func _on_release() -> void:
	if not is_dragging:
		return

	is_dragging = false
	end_position = get_global_mouse_position()
	print("Ending slice at ", end_position)
	if is_valid_slice():
		sliced.emit()
		var polarity: int = 1 if start_position.y < end_position.y else -1
		var vfx_distance: float = (line_length / 2.0) + 24
		slice_vfx.show_slice(Vector2(0, -polarity * vfx_distance), Vector2(0, polarity * vfx_distance), 0.1)


## A valid slice occurs if the formed line touches all 3 areas.
func is_valid_slice() -> bool:
	return line_touches_all_areas(start_position, end_position, [high_area, mid_area, low_area])


func point_touches_areas(point: Vector2, areas: Array[Area2D]) -> bool:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results: Array[Dictionary] = space.intersect_point(query)
	for dict in results:
		var collided_area: Area2D = dict.collider
		if collided_area in areas:
			return true
	return false


func line_touches_all_areas(from: Vector2, to: Vector2, areas: Array[Area2D]) -> bool:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var line := SegmentShape2D.new()
	line.a = from
	line.b = to
	var query := PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape = line
	var results: Array[Dictionary] = space.intersect_shape(query)
	var colliders: Array[Area2D]
	colliders.assign(results.map(func(dict: Dictionary) -> Area2D:
		return dict.collider
	))

	# Return the moment an area is not found in the collided areas. 
	# This is because all areas must be touched. 
	for area in areas:
		if area not in colliders:
			return false
	return true


func _draw() -> void:
	var line_start := Vector2(0, -line_length / 2)
	var line_end := Vector2(0, line_length / 2)
	draw_dashed_line(line_start, line_end, Color.BLACK, 2, 1, true, false)


func _on_valid_area_mouse_exited() -> void:
	_on_release()
