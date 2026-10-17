extends ShakeInput


@export var twisted_sprite: Texture2D


func _ready() -> void:
	if GlobalState.shaker_status == GlobalState.Status.TWISTED:
		slider.add_theme_icon_override("grabber", twisted_sprite)
		slider.add_theme_icon_override("grabber_highlight", twisted_sprite)
		slider.add_theme_icon_override("grabber_disabled", twisted_sprite)
