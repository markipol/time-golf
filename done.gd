extends Area3D
@export var copy_from: Node3D 

func _physics_process(delta: float) -> void:
	global_transform = copy_from.global_transform
