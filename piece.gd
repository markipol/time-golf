extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	if not mesh_instance:
		push_warning("No MeshInstance3D child for piece " + name +  " found.")
		return

	var mesh: Mesh = mesh_instance.mesh
	if not mesh:
		push_warning("MeshInstance3D child of piece " + name +  " has no mesh.")
		return

	# Generate the concave trimesh collision
	var shape = ConcavePolygonShape3D.new()
	shape.data = mesh.get_faces()

	# Create a CollisionShape3D node automatically
	var collision = CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

	# Optional: ensure transform matches mesh
	collision.transform = mesh_instance.transform


	
