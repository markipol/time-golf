extends Area3D
@export var target: Node
@export var method_name: String = "activate"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if target and target.has_method(method_name):
		target.call(method_name)
	else:
		push_warning("Target has no method '%s'" % method_name)
