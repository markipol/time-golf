extends Control
func update_shots_taken(shots: int):
	$MarginContainer3/HBoxContainer/Number.text = str(shots)


func _on_reset_hole_pressed() -> void:
	get_tree().reload_current_scene()
func main_menu():
	get_tree().change_scene_to_file("res://levels/mainmenu.tscn")
