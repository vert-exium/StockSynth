extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$synth.visible = false
	$startButton.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $apiEnter.text != "":
		$confirmKeyButton.disabled = false


func _on_start_button_pressed() -> void:
	$startButton.visible = false
	$synth.visible = true
	$warnLabel.visible = false
	$Control/LabelNo1.visible = true
	$Control/LabelNo2.visible = true
	$Control/LabelNo3.visible = true
	$Control/LabelNo4.visible = true


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_confirm_key_button_pressed() -> void:
	Global.api_key = $apiEnter.text
	$apiEnter.editable = false
	$confirmKeyButton.disabled = true
	$startButton.disabled = false
	$startButton.visible = true
