extends Node


enum Items {
	NONE,
	PUMPKIN,
	ONION,
	GARLIC,
}

enum Status {
	NONE,
	NORMAL,
	TWISTED
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


var got_milk: bool = false
var got_cream: bool = false
var got_butter: bool = false
var got_shaker: bool = false
var fixed_twist_smalls: bool = false

var milk_status := Status.NONE
var cream_status := Status.NONE
var butter_status := Status.NONE
var shaker_status := Status.NONE


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)


func is_holding_item() -> bool:
	return current_item != Items.NONE


func has_all_smalls() -> bool:
	return got_milk and got_cream and got_butter and got_shaker


func twist_select_correct(variable_name: String) -> void:
	print("That's correct!")
	set(variable_name + "_status", Status.NORMAL)


func twist_select_wrong(variable_name: String) -> void:
	print("That's wrong.")
	set(variable_name + "_status", Status.TWISTED)
