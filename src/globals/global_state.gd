extends Node


enum Items {
	NONE,
	PUMPKIN,
	ONION,
	GARLIC,
}

var current_item := Items.NONE

var is_pumpkin_done: bool = false
var is_onion_done: bool = false
var is_garlic_done: bool = false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
