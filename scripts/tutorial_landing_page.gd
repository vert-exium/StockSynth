extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_ap_itut_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/api_tutorial.tscn")


func _on_ap_itut_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_tutorial.tscn")


func _on_ap_itut_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/effects_tutorial.tscn")
