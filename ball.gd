class_name Ball
extends GenericBall



var angle: Vector2 = Vector2(0, 1)

var power:float = 0.0
var max_power :float = 100.0
var min_power :float= 0.0
var label: Label
var is_dragging :bool= false
var drag_vector :Vector2= Vector2.ZERO
var start_mouse_pos :Vector2= Vector2.ZERO
var angle_speed :float= 90.0    # degrees per second
var power_speed :float= 50.0    # units per second
var min_distance:float = 0.08
var max_distance:float = 0.3
@export var debug_rays: bool = false
@export var power_multiplier: float = 0.25
@onready var camera: Camera3D = %Camera3D
@export var fixed_camera:bool = false
var camera_offset: Vector3
var has_grounded_transform :bool = false
var original_global_transform_grounded: Transform3D

@export var SPEED_THRESHOLD :float= 0.5
@export var ANGULAR_THRESHOLD :float= 0.2
@export var SETTLE_FRAMES :int= 20
@export var settle_counter:int = 0
@onready var ghost_ball_scene:PackedScene = preload("res://ghost_ball.tscn")

var col_min:Color = Color.WHITE
var col_mid:Color = Color(1.0, 0.5, 0.0) # orange
var col_max :Color= Color.RED
var arrow_mat: StandardMaterial3D
var stem: MeshInstance3D
var arrow: MeshInstance3D
var shot_taken:bool = false
var previous_shots:Array = []
var hole_over: bool = false
#RAY
var red_ray: MeshInstance3D
var green_ray: MeshInstance3D


var p: AudioStreamPlayer3D 
@onready var hole_sound: AudioStream = preload("res://sounds/in_hole.wav")
@onready var hit_sound: AudioStream = preload("res://sounds/boop.wav")
var num_shots_taken: int = 0
var level_passed: Control
var during_hole: Control
func _ready() -> void:
	
	var scene_root = get_tree().current_scene
	level_passed = scene_root.get_node("CanvasLayer/LevelPassed")
	during_hole = scene_root.get_node("CanvasLayer/DuringHole")
	during_hole.show()
	level_passed.hide()
	p = AudioStreamPlayer3D.new()
	add_child(p)
	$InspectorArrow.hide()
	%ShotArrow.hide()
	if not fixed_camera:
		camera_offset = %Camera3D.global_transform.origin - global_transform.origin

		
	##RAY
	red_ray = MeshInstance3D.new()
	green_ray = MeshInstance3D.new()

	add_child(red_ray)
	add_child(green_ray)

	var red_material := StandardMaterial3D.new()
	red_material.albedo_color = Color.RED
	red_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var green_material := StandardMaterial3D.new()
	green_material.albedo_color = Color.GREEN
	green_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var red_mesh := CylinderMesh.new()
	red_mesh.top_radius = 0.05
	red_mesh.bottom_radius = 0.05
	red_mesh.height = 1.0

	var green_mesh := CylinderMesh.new()
	green_mesh.top_radius = 0.05
	green_mesh.bottom_radius = 0.05
	green_mesh.height = 1.0

	red_ray.mesh = red_mesh
	green_ray.mesh = green_mesh

	red_ray.material_override = red_material
	green_ray.material_override = green_material
	if not debug_rays:
		red_ray.hide()
		green_ray.hide()
	arrow_mat = StandardMaterial3D.new()
	stem = %ShotArrow.get_node("MeshInstance3D")
	arrow = %ShotArrow.get_node("MeshInstance3D2")
	
	stem.material_override = arrow_mat
	arrow.material_override = arrow_mat
	

func draw_ray(mesh_instance: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var direction := to - from
	var length := direction.length()

	if length < 0.001:
		return

	mesh_instance.global_position = (from + to) / 2.0
	mesh_instance.scale = Vector3(1, length, 1)

	mesh_instance.look_at(to, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI / 2.0)
func copy_button_signal_connections(source: Node, target: Node):
	for signal_name in [
		"red_button_hit",
		"blue_button_hit",
		"purple_button_hit",
		"green_button_hit"
	]:
		for connection in source.get_signal_connection_list(signal_name):
			target.connect(signal_name, connection.callable)
func take_previous_shots():
	for shot in previous_shots:
		var g = ghost_ball_scene.instantiate()
		g.global_transform = original_global_transform_grounded
		
		%ghost_balls.add_child(g)
		copy_button_signal_connections(self, g)
		g.apply_central_impulse(shot)
func update_during_hole_num_shots(num: int):
	during_hole.update_shots_taken(num)
func finish_shot():
	
	
	for child in %ghost_balls.get_children():
		child.queue_free()
	take_previous_shots()
	global_transform = original_global_transform_grounded
	shot_taken = false
	settle_counter = 0
	%ShotArrow.show()
func _physics_process(_delta):
	var mouse_pos := get_viewport().get_mouse_position()
	if not fixed_camera:
		%Camera3D.global_transform.origin = global_transform.origin + camera_offset
	if not original_global_transform_grounded:
		if grounded:
			settle_counter += 1
		else:
			settle_counter = 0
		if settle_counter >= SETTLE_FRAMES:
			%ShotArrow.show()
			original_global_transform_grounded = global_transform
			has_grounded_transform = true
			settle_counter = 0
	elif shot_taken:
		var speed = linear_velocity.length()
		var spin = angular_velocity.length()
		if speed < SPEED_THRESHOLD and spin < ANGULAR_THRESHOLD:
			settle_counter += 1
		else:
			settle_counter = 0
		if settle_counter >= SETTLE_FRAMES and not currently_in_motion_override:
			finish_shot()
	else:
	
		

		

		# -------------------------------------------------
		# RAY FROM CAMERA THROUGH MOUSE
		# -------------------------------------------------

		var ray_origin := camera.project_ray_origin(mouse_pos)
		var ray_direction := camera.project_ray_normal(mouse_pos)

		var ray_end := ray_origin + ray_direction * 100.0


		# -------------------------------------------------
		# FIND WHERE THAT RAY HITS THE BALL'S HORIZONTAL PLANE
		# -------------------------------------------------

		var plane := Plane(Vector3.UP, global_position.y)

		var mouse_world_pos = plane.intersects_ray(
			ray_origin,
			ray_direction
		)

		# Camera -> mouse ray
		if debug_rays:
			draw_ray(red_ray, ray_origin, ray_end)

			# Mouse -> ball ray
			if mouse_world_pos != null:
				draw_ray(
					green_ray,
					mouse_world_pos,
					global_position
				)



		%ShotArrow.rotation.y = atan2(angle.x, angle.y) + PI
		%ShotArrow.rotation.z = 0
		%ShotArrow.rotation.x = 0
		%ShotArrow.position = position


		# --- SHOOT ---
		if  not hole_over and mouse_world_pos !=null:
			var shot_direction = global_position - mouse_world_pos
			shot_direction.y = 0
			if shot_direction.length_squared() > 0.001:
				shot_direction = shot_direction.normalized()
				angle = Vector2(shot_direction.x, shot_direction.z)
			var distance  = global_position.distance_to(mouse_world_pos)
			#print("Unclamped distance" + str(distance))
			distance = clamp(distance,min_distance,max_distance)
			#print("Clamped distance" + str(distance))
			var percent_power_meter = (distance - min_distance) / (max_distance - min_distance)
			#print("Percent power meter" + str(percent_power_meter))
			var clamped_power_meter = clamp(percent_power_meter, 0.2, 1)
			#print("Clamped power meter" + str(percent_power_meter))
			%ShotArrow.scale = Vector3(clamped_power_meter,clamped_power_meter,clamped_power_meter)
			var t = clamp((clamped_power_meter - 0.2) / (1.0 - 0.2), 0.0, 1.0)
			var col: Color
			if t < 0.5:
				col = col_min.lerp(col_mid, t * 2.0)
			else:
				col = col_mid.lerp(col_max, (t - 0.5) * 2.0)
			
			
			arrow_mat.albedo_color = col
			#print("PM", power_multiplier)
			#print("Clamped power meter" + str(percent_power_meter))
			power = clamped_power_meter * power_multiplier
			#print("Power: ", str(power))
			
			if not hole_over and Input.is_action_just_pressed("shoot"):
				num_shots_taken += 1
				update_during_hole_num_shots(num_shots_taken)
				#print("SHOT!")
				#print("Power: ", power)
				
				
				p.pitch_scale = randf_range(0.9, 1.1)
				p.volume_db = lerp(-28.0, -1.0, clamped_power_meter)
				p.stream = hit_sound
				p.play()
				
				# Apply force in the aimed direction
				var force := Vector3(angle.x, 0, angle.y) * power
				apply_central_impulse(force)
				previous_shots.append(force)
				shot_taken = true
				%ShotArrow.hide()






func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is GenericBall:
		currently_in_motion_override = true
		hole_over = true
		%ShotArrow.hide()
		print("i knew you could do it")
		var hole_player :AudioStreamPlayer3D= AudioStreamPlayer3D.new()
		hole_player.stream = hole_sound
		# Random pitch variation
		hole_player.pitch_scale = randf_range(0.9, 1.1)
		hole_player.volume_db = 12.0
		add_child(hole_player)
		hole_player.play()

		# Auto-delete when done
		hole_player.connect("finished", hole_player.queue_free)
		
		during_hole.hide()
		level_passed.update_shots_taken(num_shots_taken)
		level_passed.show()
	
