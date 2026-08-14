extends Node3D
var already_activated:bool= false
@export var sound: AudioStream
@export_range(0.0, 1.0) var sound_percent_volume: float = 1.0

func activate(_ball: RigidBody3D):
	if not already_activated:
		var tween = create_tween()
		tween.tween_property(self, "transform:origin:y", transform.origin.y + 0.3, 1.0)
		already_activated = true
		if sound:
			# Create a temporary player
			var p := AudioStreamPlayer3D.new()
			p.stream = sound
			add_child(p)
			var db = linear_to_db(sound_percent_volume)
			p.volume_db = db
			p.play()
			p.connect("finished", p.queue_free)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
