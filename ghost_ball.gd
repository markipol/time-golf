extends RigidBody3D

signal red_button_hit(ball)
signal blue_button_hit(ball)
signal purple_button_hit(ball)
signal green_button_hit(ball)
var currently_in_motion_override = false
func stop_physics():
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	currently_in_motion_override = true
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	for i in state.get_contact_count():
		var body = state.get_contact_collider_object(i)

		if body and body.is_in_group("buttons"):
			var button_name = body.name
			print("Hit ", button_name)
			match button_name:
				"red_button":
					red_button_hit.emit(self)
				"blue_button":
					blue_button_hit.emit(self)
				"purple_button":
					purple_button_hit.emit(self)
				"green_button":
					green_button_hit.emit(self)
