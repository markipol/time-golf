extends Node
var levels = [
	"res://levels/course1.tscn",
	"res://levels/course2.tscn",
	"res://levels/course3.tscn",
	"res://levels/ferris_wheel.tscn",
	
]
var current_level := 0
func load_next_level():
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene_to_file(levels[current_level])
	else:
		print("No more levels!")
