extends Node2D


# Hides the synth window and start button right away
func _ready() -> void:
	$synth.visible = false
	$startButton.visible = false


# Checks if there is any text in the api key field, and if there is then it enables the start button
func _process(delta: float) -> void:
	if $apiEnter.text != "":
		$confirmKeyButton.disabled = false

# Sets up everything when the start button is pressed
func _on_start_button_pressed() -> void:
	$startButton.visible = false
	$synth.visible = true
	$warnLabel.visible = false
	$Control/LabelNo1.visible = true
	$Control/LabelNo2.visible = true
	$Control/LabelNo3.visible = true
	$Control/LabelNo4.visible = true


# Sets the scene back to the main menu
func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


# Stores the API key and hides the start button
func _on_confirm_key_button_pressed() -> void:
	Global.api_key = $apiEnter.text
	$apiEnter.editable = false
	$confirmKeyButton.disabled = true
	$startButton.disabled = false
	$startButton.visible = true
