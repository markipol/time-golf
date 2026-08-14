extends Control

func load_level(num:int):
	get_tree().change_scene_to_file("res://levels/" + str(num) +".tscn")
