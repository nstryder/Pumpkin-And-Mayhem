extends Node


@export_file_path(".tscn") var new_scene_path: String



func request_new_scene() -> void: 
	EventBus.scene_change_requested.emit(new_scene_path)
