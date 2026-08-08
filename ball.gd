extends RigidBody3D

var angle := Vector2(0, 1)
var yaw := 0.0             # degrees
var power := 0.0
var max_power := 100.0
var min_power := 0.0

var angle_speed := 90.0    # degrees per second
var power_speed := 50.0    # units per second

func _ready() -> void:
	yaw = rad_to_deg(rotation.y)
	$InspectorArrow.hide()
	
func _physics_process(delta):
	# --- AIM LEFT/RIGHT ---
	if Input.is_action_pressed("ui_left"):
		yaw += angle_speed * delta
		
	if Input.is_action_pressed("ui_right"):
		yaw -= angle_speed * delta
		
	%ShotArrow.rotation.y = deg_to_rad(yaw) + PI
	%ShotArrow.rotation.x = 0
	%ShotArrow.rotation.z = 0
	%ShotArrow.position = position
	
	# Convert yaw to a direction vector on XZ plane
	angle = Vector2(
		sin(deg_to_rad(yaw)),
		cos(deg_to_rad(yaw))
	)
	
	# --- POWER CONTROL ---
	if Input.is_action_just_pressed("ui_up"):
		power += power_speed * delta
		print("Power: ", power)
	if Input.is_action_just_pressed("ui_down"):
		power -= power_speed * delta
		print("Power: ", power)

	power = clamp(power, min_power, max_power)

	# --- SHOOT ---
	if Input.is_action_just_pressed("shoot"):
		print("SHOT!")
		print("Yaw (deg): ", yaw)
		print("Power: ", power)

		# Apply force in the aimed direction
		var force := Vector3(angle.x, 0, angle.y) * power
		apply_central_impulse(force)
