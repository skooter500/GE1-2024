extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	$AudioStreamPlayer2D.play()
	pass # Replace with function body.


func _on_timer_timeout() -> void:

	pass # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	print(value)
	var ps:AudioEffectPitchShift =  AudioServer.get_bus_effect(0, 0)
	ps.pitch_scale = value
	
	$AudioStreamPlayer2D.pitch_scale = value
	pass # Replace with function body.


func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
	pass # Replace with function body.
