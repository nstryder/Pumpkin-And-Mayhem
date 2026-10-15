extends Node2D

@onready var current_scene: Node2D = %CurrentScene


func _ready() -> void:
	EventBus.scene_change_requested.connect(_on_scene_change_requested)


func _on_scene_change_requested(new_scene_path: String) -> void:
	current_scene.get_child(0).queue_free()
	var new_scene: PackedScene = load(new_scene_path)
	var instance: Node = new_scene.instantiate()
	current_scene.add_child(instance)
