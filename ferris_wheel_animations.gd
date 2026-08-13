extends Node3D
@export var front_flap_AP: AnimationPlayer
@export var rear_flap_AP: AnimationPlayer
@export var fake_ball_AP: AnimationPlayer
@export var fake_ball: Node3D
var elapsed := 0.0
var phase1 := false
var phase2 := false
var hit_ball: Node3D
func ball_hit_entry(ball: RigidBody3D):
	if not phase1:
		front_flap_AP.play("fake-ballAction")
		rear_flap_AP.play("front-flapAction_001")
		fake_ball_AP.play("fake-ballAction")
		hit_ball = ball
		ball.hide()
		ball.stop_physics()
		fake_ball.show()
		elapsed = 0.0
		phase1 = true
func phase2start():
	phase2 = true

func _process(delta):
	if phase1:
		hit_ball.global_transform = fake_ball.global_transform
		elapsed += delta
		if elapsed >= 1.0 and not phase2:
			
			front_flap_AP.pause()
			rear_flap_AP.pause()
			fake_ball_AP.pause()
		elif phase2:
			front_flap_AP.play("fake-ballAction")
			rear_flap_AP.play("front-flapAction_001")
			fake_ball_AP.play("fake-ballAction")
			phase1 = false
			phase2 = false
			
