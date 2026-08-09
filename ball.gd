extends RigidBody3D

var angle := Vector2(0, 1)
var yaw := 0.0             # degrees
var power := 0.0
var max_power := 100.0
var min_power := 0.0
@export var label: Label
var is_dragging := false
var drag_vector := Vector2.ZERO
var start_mouse_pos := Vector2.ZERO
var angle_speed := 90.0    # degrees per second
var power_speed := 50.0    # units per second
var min_distance = 0.08
var max_distance = 0.3
@export var debug_rays: bool = false
@onready var camera: Camera3D = %Camera3D
var original_offset: Vector3
#RAY
var red_ray: MeshInstance3D
var green_ray: MeshInstance3D
func _ready() -> void:
	yaw = rad_to_deg(rotation.y)
	$InspectorArrow.hide()
	%ShotArrow.show()
	original_offset = %Camera3D.global_transform.origin - global_transform.origin
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
	
func draw_ray(mesh_instance: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var direction := to - from
	var length := direction.length()

	if length < 0.001:
		return

	mesh_instance.global_position = (from + to) / 2.0
	mesh_instance.scale = Vector3(1, length, 1)

	mesh_instance.look_at(to, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI / 2.0)
func _physics_process(delta):
	
	var mouse_pos := get_viewport().get_mouse_position()

	

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


	#print("Mouse: ", mouse_pos)
	#print("Ray origin: ", ray_origin)
	#print("Ray direction: ", ray_direction)
	#print("Mouse world: ", mouse_world_pos)
	#print("Ball: ", global_position)
	
	%Camera3D.global_transform.origin = global_transform.origin + original_offset
	## --- AIM LEFT/RIGHT ---
	#if Input.is_action_pressed("ui_left"):
		#yaw += angle_speed * delta
		#
	#if Input.is_action_pressed("ui_right"):
		#yaw -= angle_speed * delta
		#
	#%ShotArrow.rotation.y = deg_to_rad(yaw) + PI
	#%ShotArrow.rotation.x = 0
	#%ShotArrow.rotation.z = 0
	#%ShotArrow.position = position
	#
	## Convert yaw to a direction vector on XZ plane
	#angle = Vector2(
		#sin(deg_to_rad(yaw)),
		#cos(deg_to_rad(yaw))
	#)
	#if mouse_world_pos != null:
		##print("Distance: ", global_position.distance_to(mouse_world_pos))
		#var direction = global_position - mouse_world_pos
		#direction.y = 0
#
		#if direction.length_squared() > 0.001:
			#direction = direction.normalized()
#
			## This is now the ball's aim direction
			#angle = Vector2(direction.x, direction.z)

	%ShotArrow.rotation.y = atan2(angle.x, angle.y) + PI
	%ShotArrow.rotation.z = 0
	%ShotArrow.rotation.x = 0
	%ShotArrow.position = position
	## --- POWER CONTROL ---
	#if Input.is_action_just_pressed("ui_up"):
		#power += power_speed * delta
		#print("Power: ", power)
	#if Input.is_action_just_pressed("ui_down"):
		#power -= power_speed * delta
		#print("Power: ", power)
#
	#power = clamp(power, min_power, max_power)

	# --- SHOOT ---
	if mouse_world_pos !=null:
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
		%ShotArrow.scale = Vector3(clamped_power_meter,clamped_power_meter,clamped_power_meter)
		var power: float = clamped_power_meter * 5
		#print("Power: ", str(power))
		
		if Input.is_action_just_pressed("shoot"):
			print("SHOT!")
			print("Power: ", power)

			# Apply force in the aimed direction
			var force := Vector3(angle.x, 0, angle.y) * power
			apply_central_impulse(force)


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("i knew you could do it")
	label.show()


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("i knew you could do it")
	label.show()
