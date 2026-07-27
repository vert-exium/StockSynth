extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$EnterButton.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if $apiEnter.text != "":
		$EnterButton.disabled = false

func _on_button_pressed() -> void:
	Global.api_key = $apiEnter.text
	print("DEBUG: API key is " + str(Global.api_key))
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorialLandingPage.tscn")
