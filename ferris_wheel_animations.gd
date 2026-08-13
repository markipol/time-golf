extends Node3D
@export var front_flap_AP: AnimationPlayer
@export var rear_flap_AP: AnimationPlayer
@export var fake_ball_AP: AnimationPlayer

func ball_hit_entry():
	front_flap_AP.play("fake-ballAction")
	rear_flap_AP.play("front-flapAction_001")
	fake_ball_AP.play("fake-ballAction")
