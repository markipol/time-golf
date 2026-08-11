extends Node3D

@export var merged_mesh_name := "MergedCourse"
@export var collision_name := "CourseCollision"

func _ready():
	var mesh_instances := get_mesh_instances()
	if mesh_instances.is_empty():
		print("No mesh instances found under Course")
		return

	var merged_mesh := merge_meshes(mesh_instances)
	if merged_mesh == null:
		print("Mesh merge failed")
		return

	# Create merged mesh instance
	var merged_instance := MeshInstance3D.new()
	merged_instance.name = merged_mesh_name
	merged_instance.mesh = merged_mesh
	add_child(merged_instance)

	# Create collision
	var collision := CollisionShape3D.new()
	collision.name = collision_name
	collision.shape = create_concave_shape(merged_mesh)
	add_child(collision)

	# Optional: hide or delete original pieces
	for mi in mesh_instances:
		mi.hide()
		# mi.queue_free()  # uncomment if you want them gone

	print("Course merged successfully")
	
func get_mesh_instances() -> Array:
	var arr := []
	for child in get_tree().get_nodes_in_group("mesh_instances"):
		arr.append(child)
	return arr
