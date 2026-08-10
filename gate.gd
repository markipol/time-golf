extends Node3D

func activate():
	var tween = create_tween()
	tween.tween_property(self, "transform:origin:y", transform.origin.y + 0.3, 1.0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
