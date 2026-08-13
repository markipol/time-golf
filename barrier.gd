extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	hide()
	$MeshInstance3D/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
func activate(ball: RigidBody3D):
	hide()
	$MeshInstance3D/StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
