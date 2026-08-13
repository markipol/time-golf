extends MeshInstance3D
var spinning: bool = true
var speed: float = 120 # degrees per second

func _physics_process(delta: float) -> void:
	if spinning:
		rotate_z(deg_to_rad(speed * delta))
func activate(ball: RigidBody3D):
	spinning = false
