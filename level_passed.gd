class_name LevelPassed
extends Control
func _on_next_level_pressed():
	var number = get_tree().current_scene.name
			# 1

	var next_number = str(int(number) + 1)
	var next_path = "res://levels/"+ next_number + ".tscn"     # "res://2.tscn"

	print("Loading:", next_path)
	
	if FileAccess.file_exists(next_path):
		get_tree().change_scene_to_file(next_path)
	else:
		get_tree().change_scene_to_file("res://levels/mainmenu.tscn")
func update_shots_taken(shots: int):
	$CenterContainer/VBoxContainer/HBoxContainer/Number.text = str(shots)
func main_menu():
	get_tree().change_scene_to_file("res://levels/mainmenu.tscn")
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().set_input_as_handled()
