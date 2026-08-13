extends Node3D
@export var front_flap_AP: AnimationPlayer
@export var rear_flap_AP: AnimationPlayer
@export var fake_ball_AP: AnimationPlayer
@export var fake_ball: Node3D
var hit_ball: Node3D #hit_ball is the ball that hit the invisible button originally
var timer = 0.0
var cabin
@export var cabin_raycast: RayCast3D
enum BallState {
	NO_BALL,
	PHASE1_PLAYING,
	WAITING_FOR_CABIN,
	PHASE2_PLAYING
}

var state : BallState = BallState.NO_BALL
#func _ready():
	## Create raycast that points forward from the fake ball
	#cabin_raycast = RayCast3D.new()
	#cabin_raycast.target_position = Vector3.FORWARD * 10
	#cabin_raycast.enabled = true
	#fake_ball.add_child(cabin_raycast)
func ball_hit_entry(ball: RigidBody3D):
	if state != BallState.NO_BALL:
		return
	state = BallState.PHASE1_PLAYING
	hit_ball = ball
	ball.hide()
	ball.stop_physics()
	fake_ball.show()
	front_flap_AP.play("fake-ballAction")
	rear_flap_AP.play("front-flapAction_001")
	fake_ball_AP.play("fake-ballAction")
	timer = 0.0


func detect_cabin():
	cabin_raycast.force_raycast_update()
	if cabin_raycast.is_colliding():
		var collider = cabin_raycast.get_collider()
		if collider:
			return collider
	return null
func start_phase2():
	state = BallState.PHASE2_PLAYING
	front_flap_AP.play("fake-ballAction")
	rear_flap_AP.play("front-flapAction_001")
	fake_ball_AP.play("fake-ballAction")
	
	
func reset_all():
	front_flap_AP.stop()
	rear_flap_AP.stop()
	fake_ball_AP.stop()

	front_flap_AP.seek(0.0, true)
	rear_flap_AP.seek(0.0, true)
	fake_ball_AP.seek(0.0, true)

	fake_ball.hide()
	state = BallState.NO_BALL
func _process(delta):
	match state:
		BallState.PHASE1_PLAYING:
			hit_ball.global_transform = fake_ball.global_transform
			timer += delta
			if timer >= 1.0:
				front_flap_AP.pause()
				rear_flap_AP.pause()
				fake_ball_AP.pause()
				state = BallState.WAITING_FOR_CABIN
				timer = 0.0
		BallState.WAITING_FOR_CABIN:
			cabin = detect_cabin()
			if cabin:
				print("Ball reached cabin: " + cabin.name)
				start_phase2()
		BallState.PHASE2_PLAYING:

				timer += delta
				if timer >= 0.5:
					reset_all()
					cabin.get_parent().get_parent().get_parent().got_ball(hit_ball)
		BallState.NO_BALL:
			pass
			# Wait for animations to finish
	#if phase1:
		#hit_ball.global_transform = fake_ball.global_transform
		#
		#elapsed += delta
		#if elapsed >= 1.0 and not phase2:
			#if not phase1done:
				#front_flap_AP.pause()
				#rear_flap_AP.pause()
				#fake_ball_AP.pause()
				#phase1done = true
			#var cabin = detect_cabin()
			#if cabin:
				#print("Ball reached cabin: " + cabin.name)
				#phase2start()
		#elif phase2:
			#if phase2_delay > 0.0:
				#phase2_delay -= delta
				#return
		## Then play phase2 animations
			#if phase2_anim_time > 0.0:
				#front_flap_AP.play("fake-ballAction")
				#rear_flap_AP.play("front-flapAction_001")
				#fake_ball_AP.play("fake-ballAction")
#
				#phase2_anim_time -= delta
				#return
			#reset_all()
			
