extends Node2D

@onready var pumpkin: ClickableArea = %Pumpkin
@onready var garlic: ClickableArea = %Garlic
@onready var onion: ClickableArea = $Onion


func _ready() -> void:
	if GlobalState.current_item == GlobalState.Items.PUMPKIN or GlobalState.is_pumpkin_done:
		pumpkin.queue_free()
	
	if GlobalState.current_item == GlobalState.Items.GARLIC or GlobalState.is_garlic_done:
		garlic.queue_free()
	
	if GlobalState.current_item == GlobalState.Items.ONION or GlobalState.is_onion_done:
		onion.queue_free()


func is_holding_item() -> bool:
	if GlobalState.is_holding_item():
		EventBus.prompt_requested.emit("I'm already holding something...")
		return true
	return false


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
