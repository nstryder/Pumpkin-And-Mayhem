extends Node2D

signal sliced

@onready var high_area: Area2D = $HighArea
@onready var mid_area: Area2D = $MidArea
@onready var low_area: Area2D = $LowArea

var is_dragging: bool = false

var start_position: Vector2
var end_position: Vector2

# Dragging starts if player clicks on a high or low area. 
# Dragging ends if any occurs: 
	# The mouse leaves the valid area (need to make this)
	# Left click is released 


func _unhandled_input(event: InputEvent) -> void:
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
	if not point_touches_areas(click_position, [high_area, low_area]):
		return

	start_position = click_position
	is_dragging = true


func _on_release() -> void:
	if not is_dragging:
		return

	is_dragging = false
	end_position = get_global_mouse_position()
	if is_valid_slice():
		sliced.emit()


## A valid slice occurs if:
## The formed line starts from one extreme and ends on the opposite extreme. 
## [br]Ex: Top to bottom, or bottom to top
## [br]and 
## [br]The formed line touches the middle area.
func is_valid_slice() -> bool:
	var line_touches_extremes: bool = (
		(point_touches_areas(start_position, [high_area]) and point_touches_areas(end_position, [low_area]))
		or (point_touches_areas(start_position, [low_area]) and point_touches_areas(end_position, [high_area]))
	)
	return line_touches_extremes and line_touches_area(start_position, end_position, mid_area)
	

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


func line_touches_area(from: Vector2, to: Vector2, area: Area2D) -> bool:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var line := SegmentShape2D.new()
	line.a = from
	line.b = to
	var query := PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.shape = line
	var results: Array[Dictionary] = space.intersect_shape(query)
	for dict in results:
		var collided_area: Area2D = dict.collider
		if collided_area == area:
			return true
	return false


func _draw() -> void:
	pass
