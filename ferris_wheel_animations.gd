extends Node3D
@export var front_flap_AP: AnimationPlayer
@export var rear_flap_AP: AnimationPlayer
@export var fake_ball_AP: AnimationPlayer
@export var fake_ball: Node3D
var locked := false
var phase2_delay := 0.0
var phase2_anim_time := 0.0
var elapsed := 0.0
var phase1 := false
var phase1done:= false
var phase2 := false
var hit_ball: Node3D
@export var cabin_raycast: RayCast3D

#func _ready():
	## Create raycast that points forward from the fake ball
	#cabin_raycast = RayCast3D.new()
	#cabin_raycast.target_position = Vector3.FORWARD * 10
	#cabin_raycast.enabled = true
	#fake_ball.add_child(cabin_raycast)
func ball_hit_entry(ball: RigidBody3D):
	if locked:
		return
	if not phase1:
		locked = true
		front_flap_AP.play("fake-ballAction")
		rear_flap_AP.play("front-flapAction_001")
		fake_ball_AP.play("fake-ballAction")
		hit_ball = ball
		ball.hide()
		ball.stop_physics()
		fake_ball.show()
		elapsed = 0.0
		phase1 = true
func checkForCabin():
	if phase1done:
		if cabin_raycast.is_colliding():
			var collider = cabin_raycast.get_collider()
			if collider.is_in_group("cabins"):
				print("Hit cabin: ", collider.name)
				phase2start()
func detect_cabin():
	cabin_raycast.force_raycast_update()
	if cabin_raycast.is_colliding():
		var collider = cabin_raycast.get_collider()
		if collider:
			return collider
	return null
func phase2start():
	phase2 = true
	phase2_delay = 0.0
	phase2_anim_time = 0.5
	
func reset_all():
	front_flap_AP.stop()
	rear_flap_AP.stop()
	fake_ball_AP.stop()

	front_flap_AP.seek(0.0, true)
	rear_flap_AP.seek(0.0, true)
	fake_ball_AP.seek(0.0, true)

	fake_ball.hide()

	phase1 = false
	phase1done = false
	phase2 = false
	locked = false
func _process(delta):
	if phase1:
		hit_ball.global_transform = fake_ball.global_transform
		
		elapsed += delta
		if elapsed >= 1.0 and not phase2:
			if not phase1done:
				front_flap_AP.pause()
				rear_flap_AP.pause()
				fake_ball_AP.pause()
				phase1done = true
			var cabin = detect_cabin()
			if cabin:
				print("Ball reached cabin: " + cabin.name)
				phase2start()
		elif phase2:
			if phase2_delay > 0.0:
				phase2_delay -= delta
				return
		# Then play phase2 animations
			if phase2_anim_time > 0.0:
				front_flap_AP.play("fake-ballAction")
				rear_flap_AP.play("front-flapAction_001")
				fake_ball_AP.play("fake-ballAction")

				phase2_anim_time -= delta
				return
			reset_all()
			
