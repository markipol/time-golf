extends Node3D
var held_ball: RigidBody3D
func got_ball(b: RigidBody3D):
	print("got ball" + b.name)
	held_ball = b
	b.show()
func _physics_process(delta: float) -> void:
	if held_ball:
		held_ball.global_transform = $PinJoint3D/cabin3/cabincapture/ball_placeholder.global_transform
