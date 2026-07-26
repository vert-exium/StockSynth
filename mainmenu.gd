extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if $apiEnter.text != "":
		$Button.disabled = false

func _on_button_pressed() -> void:
	Global.apiKey = $apiEnter.text
	print("DEBUG: API key is " + str(Global.apiKey))
	get_tree().change_scene_to_file("res://synth.tscn")
