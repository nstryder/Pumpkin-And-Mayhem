extends Node

const BGM_FADE_DURATION = 0.5

enum Instruments {
	CELLO,
	CLARINET,
	FLUTE,
	GUITAR,
	OBOE,
	PERCUSSION,
	PIANO,
	VIOLIN,
}

@onready var bgm: AudioStreamPlayer = $BGM


func _ready() -> void:
	# Only piano should play at the beginning. More instruments will be added during gameplay.
	for i in _get_sync_list().stream_count:
		if i == Instruments.PIANO:
			continue
		_get_sync_list().set_sync_stream_volume(i, -100)


func _get_sync_list() -> AudioStreamSynchronized:
	var sync_list: AudioStreamSynchronized = bgm.stream
	return sync_list


# Needed because tween_method only tweens the first argument
func set_volume_instrument(volume_db: float, instrument: Instruments) -> void:
	_get_sync_list().set_sync_stream_volume(instrument, volume_db)


func play_instrument(instrument: Instruments) -> void:
	var current_volume: float = _get_sync_list().get_sync_stream_volume(instrument)
	var tween := create_tween()
	tween.tween_method(set_volume_instrument.bind(instrument), current_volume, 0, BGM_FADE_DURATION)


func mute_instrument(instrument: Instruments) -> void:
	var current_volume: float = _get_sync_list().get_sync_stream_volume(instrument)
	var tween := create_tween()
	tween.tween_method(set_volume_instrument.bind(instrument), current_volume, -60, BGM_FADE_DURATION)
