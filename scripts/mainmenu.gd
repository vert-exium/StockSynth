extends Node2D

var percentTween: Tween
var opacityTween: Tween



# Called when the node enters the scene tree for the first time.
func _ready():
	$EnterButton.disabled = true
	$progBar.value = 0
	percentTween = create_tween()
	percentTween.set_trans(Tween.TRANS_CIRC)
	percentTween.set_ease(Tween.EASE_OUT_IN)
	$opacityTimer.start()
	percentTween.tween_property($progBar, "value", 100, 4.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if $apiEnter.text != "":
		$EnterButton.disabled = false
	$percentLabel.text = str($progBar.value) + "%"



func _on_button_pressed() -> void:
	Global.api_key = $apiEnter.text
	print("DEBUG: API key is " + str(Global.api_key))
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorialLandingPage.tscn")


func _on_opacity_timer_timeout() -> void:
	opacityTween = create_tween()
	opacityTween.set_parallel(true)
	opacityTween.set_trans(Tween.TRANS_EXPO)
	opacityTween.set_ease(Tween.EASE_IN_OUT)
	$backRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$progBar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	opacityTween.tween_property($texture, "modulate:a", 0, 2.0)
	opacityTween.tween_property($backRect, "modulate:a", 0, 2.0)
	opacityTween.tween_property($percentLabel, "modulate:a", 0, 2.0)
	opacityTween.tween_property($loadingLabel, "modulate:a", 0, 2.0)
	opacityTween.tween_property($progBar, "modulate:a", 0, 3.0)
