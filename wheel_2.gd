extends Node3D
var spinning: bool = true
var speed: float = 15 # degrees per second
var sound: AudioStream = preload("res://sounds/ferris_wheel_movement.wav")
func _ready() -> void:
	var p: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	add_child(p)
	p.stream = sound
	p.play()
	#
	#var nodes: Array[Node] = find_children("cabincapture","Area3D",true,false)
	#for n: Area3D in nodes:
		#n.body_entered.connect(%BallController/Ball.capture)
		#print(n.name + " connected")
	

func _physics_process(delta: float) -> void:
	if spinning:
		rotate_z(deg_to_rad(speed * delta))
func activate():
	spinning = false
