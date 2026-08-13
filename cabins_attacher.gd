
extends Node3D
@export var ball: Ball

func _ready():
	for cabin: Cabin in get_children():
		ball.red_button_hit.connect(cabin.oomph)
