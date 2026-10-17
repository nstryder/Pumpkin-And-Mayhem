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

var pumpkin_status := Status.NONE
var onion_status := Status.NONE
var garlic_status := Status.NONE

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


func has_all_mains() -> bool:
	return is_onion_done and is_garlic_done and is_pumpkin_done


func twist_select_correct(variable_name: String) -> void:
	print("That's correct!")
	set(variable_name + "_status", Status.NORMAL)


func twist_select_wrong(variable_name: String) -> void:
	print("That's wrong.")
	set(variable_name + "_status", Status.TWISTED)


func resolved_all_twists_main() -> bool:
	var statuses: Array[Status] = [pumpkin_status, garlic_status, onion_status]
	return statuses.all(func(status: Status) -> bool: return status != Status.NONE)


func resolved_all_twists_small() -> bool:
	var statuses: Array[Status] = [milk_status, cream_status, butter_status, shaker_status]
	return statuses.all(func(status: Status) -> bool: return status != Status.NONE)


func choose_sprite_small(status: Status, normal: Texture2D, twisted: Texture2D) -> Texture2D:
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


func choose_sprite_main(status: Status, normal: Texture2D, twisted: Texture2D) -> Texture2D:
	match status:
		Status.NORMAL:
			return normal
		Status.TWISTED:
			return twisted
		Status.NONE:
			if has_all_mains():
				print("Twisting since has all mains.")
				return twisted
			else:
				return normal
	return null


func get_sprite_onion() -> Texture2D:
	var normal: Texture2D = load("uid://c43figngusf10")
	var twisted: Texture2D = load("uid://ck87fpk0swyy")
	return choose_sprite_main(onion_status, normal, twisted)


func get_sprite_garlic() -> Texture2D:
	var normal: Texture2D = load("uid://bq8680d4gurff")
	var twisted: Texture2D = load("uid://s7r2riw6p8vk")
	return choose_sprite_main(garlic_status, normal, twisted)


func get_sprite_pumpkin() -> Texture2D:
	var normal: Texture2D = load("uid://bxia6ay2lv24e")
	var twisted: Texture2D = load("uid://dwkqv2bhedbat")
	return choose_sprite_main(pumpkin_status, normal, twisted)


func get_sprite_milk() -> Texture2D:
	var normal: Texture2D = load("uid://pvuyroskktye")
	var twisted: Texture2D = load("uid://btj42vo0f0d0o")
	return choose_sprite_small(milk_status, normal, twisted)


func get_sprite_cream() -> Texture2D:
	var normal: Texture2D = load("uid://b2ybjva3igr2j")
	var twisted: Texture2D = load("uid://bsajpet38tuqg")
	return choose_sprite_small(cream_status, normal, twisted)


func get_sprite_butter() -> Texture2D:
	var normal: Texture2D = load("uid://k3fhct5gnqag")
	var twisted: Texture2D = load("uid://cyumuhkyfbj6o")
	return choose_sprite_small(butter_status, normal, twisted)


func get_sprite_shaker() -> Texture2D:
	var normal: Texture2D = load("uid://dn6818hr3pdq3")
	var twisted: Texture2D = load("uid://cr8cmt03e8hq7")
	return choose_sprite_small(shaker_status, normal, twisted)
