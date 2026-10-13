extends ColorRect
class_name TimelineActionItem


const SELF_SCENE = preload("uid://41g1rrdsc4h")


var prompt_text: String

@onready var label: Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = prompt_text


static func construct(prompt: String) -> TimelineActionItem:
	var instance: TimelineActionItem = SELF_SCENE.instantiate()
	instance.prompt_text = prompt
	return instance
