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


func resolved_all_twists_small() -> bool:
	var statuses: Array[Status] = [milk_status, cream_status, butter_status, shaker_status]
	return statuses.all(func(status: Status) -> bool: return status != Status.NONE)


func choose_sprite(status: Status, normal: Texture2D, twisted: Texture2D) -> Texture2D:
	match status:
		Status.NORMAL:
			return normal
		Status.TWISTED:
			return twisted
		Status.NONE:
			if has_all_smalls():
				return twisted
			else:
				return normal
	return null


func get_sprite_milk() -> Texture2D:
	var normal: Texture2D = load("uid://pvuyroskktye")
	var twisted: Texture2D = load("uid://btj42vo0f0d0o")
	return choose_sprite(milk_status, normal, twisted)


func get_sprite_cream() -> Texture2D:
	var normal: Texture2D = load("uid://b2ybjva3igr2j")
	var twisted: Texture2D = load("uid://bsajpet38tuqg")
	return choose_sprite(cream_status, normal, twisted)


func get_sprite_butter() -> Texture2D:
	var normal: Texture2D = load("uid://k3fhct5gnqag")
	var twisted: Texture2D = load("uid://cyumuhkyfbj6o")
	return choose_sprite(butter_status, normal, twisted)


func get_sprite_shaker() -> Texture2D:
	var normal: Texture2D = load("uid://dn6818hr3pdq3")
	var twisted: Texture2D = load("uid://cr8cmt03e8hq7")
	return choose_sprite(shaker_status, normal, twisted)
