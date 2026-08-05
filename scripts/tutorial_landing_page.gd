extends Node2D


# All of these either change the scene to the main menu or the tutorial that's been selected
func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_ap_itut_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/api_tutorial.tscn")


func _on_ap_itut_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_tutorial.tscn")


func _on_ap_itut_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/effects_tutorial.tscn")
