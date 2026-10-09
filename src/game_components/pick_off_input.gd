@tool
extends Node2D
class_name PickOffInput

## This component spawns draggables inside the Pick Off Zone 
## and emits a completion signal once all draggables are dragged out of the Pick Off Zone. 

signal completed

## The draggable scene to spawn 
@export var draggable_scene: PackedScene:
	set(value):
		draggable_scene = value
		update_configuration_warnings()

## The number of draggables to spawn
@export var spawn_count: int = 3

## Determines how far from the center the draggables can spawn
@export var spawn_radius: int = 96


var draggables_left: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	draggables_left = spawn_count
	for i in spawn_count:
		spawn_draggable(i)


func _get_configuration_warnings() -> PackedStringArray:
	if not draggable_scene:
		return ["A draggable scene must be set for this node."]
	else:
		return []


# Strategy to spawn items semi-evenly spread out:
# Spawn each item at a regular angle interval so it looks perfectly divided 
# Offset their angles a little so it's still a bit scattered
# This should look more even than naively picking 3 random points on a circle
func spawn_draggable(idx: int) -> void:
	var spawn_point_base := Vector2.RIGHT * spawn_radius * sqrt(randf())
	var arc_segment: float = TAU / spawn_count
	var base_angle: float = arc_segment * idx
	var offset_limit: float = arc_segment / 4
	var spawn_point: Vector2 = spawn_point_base.rotated(base_angle + randf_range(-offset_limit, offset_limit))
	
	var draggable: DraggableArea = draggable_scene.instantiate()
	add_child(draggable)
	draggable.position = spawn_point


func _on_pick_off_zone_area_exited(area: Area2D) -> void:
	area.queue_free()
	draggables_left -= 1
	if draggables_left == 0:
		completed.emit()
