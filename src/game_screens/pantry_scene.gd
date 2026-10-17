extends Node2D

@onready var pumpkin: ClickableArea = %Pumpkin
@onready var garlic: ClickableArea = %Garlic
@onready var onion: ClickableArea = $Onion
@onready var milk: ClickableArea = %Milk
@onready var cream: ClickableArea = %Cream
@onready var shaker: ClickableArea = %Shaker
@onready var butter: ClickableArea = %Butter

@onready var woosh: GPUParticles2D = %Woosh
@onready var woosh_animation: AnimationPlayer = %WooshAnimation
@onready var woosh_text_holder: Node2D = %WooshTextHolder


func _ready() -> void:
	if GlobalState.current_item == GlobalState.Items.PUMPKIN or GlobalState.is_pumpkin_done:
		pumpkin.queue_free()
	
	if GlobalState.current_item == GlobalState.Items.GARLIC or GlobalState.is_garlic_done:
		garlic.queue_free()
	
	if GlobalState.current_item == GlobalState.Items.ONION or GlobalState.is_onion_done:
		onion.queue_free()
	
	if GlobalState.got_milk:
		milk.queue_free()

	if GlobalState.got_cream:
		cream.queue_free()
	
	if GlobalState.got_shaker:
		shaker.queue_free()
	
	if GlobalState.got_butter:
		butter.queue_free()


func is_holding_item() -> bool:
	if GlobalState.is_holding_item():
		EventBus.prompt_requested.emit("I'm already holding something...")
		return true
	return false


func woosh_away(item: ClickableArea) -> void:
	woosh.global_position = item.global_position
	woosh.restart()

	woosh_animation.stop()
	woosh_text_holder.global_position = item.global_position
	woosh_animation.play("appear")
	
	item.queue_free()


func _on_pumpkin_clicked() -> void:
	if is_holding_item():
		return
	GlobalState.current_item = GlobalState.Items.PUMPKIN
	pumpkin.queue_free()


func _on_garlic_clicked() -> void:
	if is_holding_item():
		return
	GlobalState.current_item = GlobalState.Items.GARLIC
	garlic.queue_free()


func _on_onion_clicked() -> void:
	if is_holding_item():
		return
	GlobalState.current_item = GlobalState.Items.ONION
	onion.queue_free()


func _on_milk_clicked() -> void:
	GlobalState.got_milk = true
	woosh_away(milk)
	

func _on_cream_clicked() -> void:
	GlobalState.got_cream = true
	woosh_away(cream)


func _on_shaker_clicked() -> void:
	GlobalState.got_shaker = true
	woosh_away(shaker)


func _on_butter_clicked() -> void:
	GlobalState.got_butter = true
	woosh_away(butter)
