class_name GenericBall
extends RigidBody3D

signal red_button_hit(ball)
signal blue_button_hit(ball)
signal purple_button_hit(ball)
signal green_button_hit(ball)
var currently_in_motion_override = false
var grounded = false
# Sound vars
# --- Bounce SFX ---
var bounce_sounds := [
	preload("res://sounds/bounce1.wav"),
	preload("res://sounds/bounce2.wav"),
	preload("res://sounds/bounce3.wav")
]
var button_sound = preload("res://sounds/button-course.wav")
var bounce_cooldown := 0.05  # 50ms between sounds
var last_bounce_time := 0.0
var min_impact := 1.0        # ignore tiny taps
var button_cooldown := 0.1  # 100ms between button sounds
var last_button_time := 0.0
enum LastHit {
	NONE,
	WALL,
	RED,
	BLUE,
	PURPLE,
	GREEN
}

var last_hit: LastHit = LastHit.NONE
func stop_physics():
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	currently_in_motion_override = true
func start_physics():
	freeze = false
	currently_in_motion_override = false
func is_grounded(state: PhysicsDirectBodyState3D) -> bool:
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		if normal.dot(Vector3.UP) > 0.7:
			return true
	return false
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	grounded = is_grounded(state)
	for i in state.get_contact_count():
		var body = state.get_contact_collider_object(i)
		if body:

			if body.is_in_group("walls"):
				last_hit = LastHit.WALL
				var contact_vel := state.get_contact_local_velocity_at_position(i)
				var impact := contact_vel.length()
				
				if impact > min_impact:
					play_bounce_sound(impact)
			if body and body.is_in_group("buttons"):
				var button_name = body.name
				print("Hit ", button_name)
				match button_name:
					"red_button":
						red_button_hit.emit(self)
						if last_hit != LastHit.RED:
							play_button_sound()
							last_hit = LastHit.RED
					"blue_button":
						blue_button_hit.emit(self)
						if last_hit != LastHit.BLUE:
							play_button_sound()
							last_hit = LastHit.BLUE
					"purple_button":
						purple_button_hit.emit(self)
						if last_hit != LastHit.PURPLE:
							play_button_sound()
							last_hit = LastHit.PURPLE
						
					"green_button":
						green_button_hit.emit(self)
						if last_hit != LastHit.GREEN:
							play_button_sound()
							last_hit = LastHit.GREEN
						
					_:
						push_error("Button not named one of the allowed colors (red_button, blue_button, purple_button, green_button)")
								# Cooldown to prevent spam
				
func play_bounce_sound(impact: float) -> void:
	# Cooldown to prevent spam
	var now := Time.get_ticks_msec()
	if now - last_bounce_time < int(bounce_cooldown * 1000.0):
		return
	last_bounce_time = now
	# Pick a random bounce sound
	var stream = bounce_sounds.pick_random()

	# Create a temporary player
	var p := AudioStreamPlayer3D.new()
	p.stream = stream

	# Random pitch variation
	p.pitch_scale = randf_range(0.9, 1.1)

	# Volume based on impact strength
	p.volume_db = lerp(-18, 0, clamp(impact / 10.0, 0.0, 1.0))

	add_child(p)
	p.play()

	# Auto-delete when done
	p.connect("finished", p.queue_free)
func play_button_sound() -> void:
	var now := Time.get_ticks_msec()
	if now - last_button_time < int(button_cooldown * 1000.0):
		return
	last_button_time = now

	var p := AudioStreamPlayer3D.new()
	p.stream = button_sound
	p.pitch_scale = randf_range(0.95, 1.05)

	add_child(p)
	p.play()
	p.connect("finished", p.queue_free)
