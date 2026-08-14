class_name Cabin
extends Node3D
var held_ball: RigidBody3D
var p:AudioStreamPlayer3D
@onready var hit_sound: AudioStream = preload("res://sounds/boop.wav")
func _ready() -> void:
	p = AudioStreamPlayer3D.new()
	add_child(p)
	p.stream = hit_sound
func got_ball(b: RigidBody3D):
	print("got ball" + b.name)
	if b.get_parent().name != "BallController":
		held_ball = b
		b.show()
func _physics_process(delta: float) -> void:
	if held_ball:
		held_ball.global_transform = $PinJoint3D/cabin3/cabincapture/ball_placeholder.global_transform
func oomph(_ball_that_hit_button):
	print("oomfh")
	if held_ball:
		print("launching ball: " + held_ball.name)
		p.play()
		held_ball.start_physics()
		held_ball.apply_central_impulse(Vector3.FORWARD * 0.5)
		held_ball = null
