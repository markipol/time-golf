extends Node3D

func _ready():
	var screen_size = DisplayServer.screen_get_size()
	var half_size = screen_size / 2
	DisplayServer.window_set_size(half_size)
	
	# Center the window on screen
	var screen_pos = DisplayServer.screen_get_position()
	var centered_pos = screen_pos + (screen_size - half_size) / 2
	DisplayServer.window_set_position(centered_pos)
