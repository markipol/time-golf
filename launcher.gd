extends Node3D


# ============================================================
# NODE REFERENCES
# ============================================================

@export_category("Nodes")

@export var button: Area3D
@export var ball_rigidbody: RigidBody3D
@export var fake_ball: CharacterBody3D

@export var ball_start: Marker3D
@export var ball_end: Marker3D

@export var flap_pivot: Node3D


# ============================================================
# BALL SETTINGS
# ============================================================

@export_category("Ball")

# How quickly the fake ball travels toward BallEnd.
@export var ball_speed: float = 5.0

# How close the fake ball needs to get to BallEnd
# before the sequence finishes.
@export var ball_end_distance: float = 0.05


# ============================================================
# FLAP SETTINGS
# ============================================================

@export_category("Flap")

# Maximum amount the flap gets pushed.
@export var max_flap_angle: float = -60.0

# Which local rotation axis the flap uses.
# Change this if Z isn't the correct axis.
@export_enum("X", "Y", "Z") var flap_axis: String = "Z"

# Positions along the ball's travel path where the flap
# starts and finishes being pushed.
#
# These are DISTANCES from BallStart along the
# BallStart -> BallEnd path.
@export var flap_push_start: float = 1.0
@export var flap_push_end: float = 2.0

# How quickly the flap returns to its resting position.
@export var flap_return_time: float = 0.1


# ============================================================
# INTERNAL VARIABLES
# ============================================================

var flap_rest_rotation: Vector3

var ball_active := false
var sequence_finished := false
var returning_flap := false


# ============================================================
# READY
# ============================================================

func _ready():

	# Remember exactly how the flap was originally rotated.
	flap_rest_rotation = flap_pivot.rotation

	# Listen for the real Rigidbody ball hitting the button.
	#button.body_entered.connect(_on_button_hit)

	# Make sure our fake ball isn't active yet.
	fake_ball.visible = false


# ============================================================
# BUTTON HIT
# ============================================================

func _on_button_hit(body: Node3D):
	# Don't start another sequence if one is already happening.
	if ball_active:
		return

	start_ball_sequence()


# ============================================================
# START FAKE BALL SEQUENCE
# ============================================================

func start_ball_sequence():

	ball_active = true
	sequence_finished = false
	returning_flap = false


	# --------------------------------------------------------
	# Freeze the real physics ball.
	# --------------------------------------------------------

	ball_rigidbody.freeze = true


	# Stop any velocity it had.
	ball_rigidbody.linear_velocity = Vector3.ZERO
	ball_rigidbody.angular_velocity = Vector3.ZERO


	# Hide the real ball.
	ball_rigidbody.visible = false


	# --------------------------------------------------------
	# Put fake ball at starting position.
	# --------------------------------------------------------

	fake_ball.global_position = ball_start.global_position

	fake_ball.global_rotation = ball_rigidbody.global_rotation

	fake_ball.visible = true


	# --------------------------------------------------------
	# Reset flap.
	# --------------------------------------------------------

	flap_pivot.rotation = flap_rest_rotation


# ============================================================
# PROCESS
# ============================================================

func _physics_process(delta):

	if not ball_active:
		return

	if sequence_finished:
		return

	move_fake_ball(delta)

	update_flap()


# ============================================================
# MOVE FAKE BALL
# ============================================================

func move_fake_ball(delta):

	var start_position = ball_start.global_position
	var end_position = ball_end.global_position


	# Direction from start to end.
	var direction = end_position - start_position

	if direction.length_squared() <= 0.0001:
		return

	direction = direction.normalized()


	# Move fake ball.
	fake_ball.global_position += direction * ball_speed * delta


	# Check whether we've reached the end.
	var distance_to_end = (
		fake_ball.global_position.distance_to(end_position)
	)


	if distance_to_end <= ball_end_distance:

		fake_ball.global_position = end_position

		finish_ball_sequence()


# ============================================================
# UPDATE FLAP
# ============================================================

func update_flap():

	var start_position = ball_start.global_position
	var end_position = ball_end.global_position


	# Direction of ball travel.
	var travel_direction = end_position - start_position

	var total_distance = travel_direction.length()

	if total_distance <= 0.0001:
		return

	travel_direction = travel_direction.normalized()


	# --------------------------------------------------------
	# Work out how far the ball has travelled.
	# --------------------------------------------------------

	var ball_offset = (
		fake_ball.global_position - start_position
	)

	var distance_travelled = ball_offset.dot(travel_direction)


	# --------------------------------------------------------
	# Convert ball distance into flap progress.
	#
	# 0 = flap hasn't moved
	# 1 = flap is at maximum angle
	# --------------------------------------------------------

	var flap_progress = inverse_lerp(
		flap_push_start,
		flap_push_end,
		distance_travelled
	)

	flap_progress = clamp(flap_progress, 0.0, 1.0)


	# --------------------------------------------------------
	# Calculate flap angle.
	# --------------------------------------------------------

	var angle = lerp(
		0.0,
		max_flap_angle,
		flap_progress
	)


	# --------------------------------------------------------
	# Apply rotation.
	# --------------------------------------------------------

	var new_rotation = flap_rest_rotation

	match flap_axis:

		"X":
			new_rotation.x += deg_to_rad(angle)

		"Y":
			new_rotation.y += deg_to_rad(angle)

		"Z":
			new_rotation.z += deg_to_rad(angle)


	flap_pivot.rotation = new_rotation


# ============================================================
# FINISH
# ============================================================

func finish_ball_sequence():

	if sequence_finished:
		return

	sequence_finished = true


	# --------------------------------------------------------
	# Smoothly return flap to vertical.
	# --------------------------------------------------------

	var tween = create_tween()

	tween.tween_property(
		flap_pivot,
		"rotation",
		flap_rest_rotation,
		flap_return_time
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


	await tween.finished


	# --------------------------------------------------------
	# Hide fake ball.
	# --------------------------------------------------------

	fake_ball.visible = false


	# --------------------------------------------------------
	# Reset the real Rigidbody.
	#
	# Remove these if you don't want the original ball
	# to become active again.
	# --------------------------------------------------------

	ball_rigidbody.global_position = ball_end.global_position

	ball_rigidbody.linear_velocity = Vector3.ZERO
	ball_rigidbody.angular_velocity = Vector3.ZERO

	ball_rigidbody.freeze = false
	ball_rigidbody.visible = true


	# --------------------------------------------------------
	# Done.
	# --------------------------------------------------------

	ball_active = false
