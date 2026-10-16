extends Node


enum Items {
	NONE,
	PUMPKIN,
	ONION,
	GARLIC,
}

var current_item := Items.NONE

signal recipe_read
var is_recipe_read: bool = false:
	set(value):
		is_recipe_read = value
		if is_recipe_read:
			recipe_read.emit()


var is_pumpkin_done: bool = false:
	set(value):
		is_pumpkin_done = value
		Audio.play_instrument(Audio.Instruments.VIOLIN)
		Audio.play_instrument(Audio.Instruments.FLUTE)
var is_onion_done: bool = false:
	set(value):
		is_onion_done = value
		Audio.play_instrument(Audio.Instruments.OBOE)
		Audio.play_instrument(Audio.Instruments.CLARINET)
var is_garlic_done: bool = false:
	set(value):
		is_garlic_done = value
		Audio.play_instrument(Audio.Instruments.GUITAR)
		Audio.play_instrument(Audio.Instruments.CELLO)


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)


func is_holding_item() -> bool:
	return current_item != Items.NONE
