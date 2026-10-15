extends Node2D

@onready var pumpkin: ClickableArea = %Pumpkin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalState.current_item == GlobalState.Items.PUMPKIN or GlobalState.is_pumpkin_done:
		pumpkin.queue_free()


func _on_pumpkin_clicked() -> void:
	GlobalState.current_item = GlobalState.Items.PUMPKIN
	pumpkin.queue_free()
