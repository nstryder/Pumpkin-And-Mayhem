extends Node2D


const MAIN = preload("res://src/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_packed(MAIN)
