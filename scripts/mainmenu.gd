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
	$loadingLabelTimer.start()
	randomize()
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


func _on_loading_label_timer_timeout() -> void:
	$loadingLabelTimer.start()
	var rng = RandomNumberGenerator.new()
	rng = rng.randi_range(1, 30)
	if rng == 1:
		$loadingLabel.text = "Getting things ready..."
	elif rng == 2:
		$loadingLabel.text = "Importing sounds..."
	elif rng == 3:
		$loadingLabel.text = "Loading UI..."
	elif rng == 4:
		$loadingLabel.text = "Drawing graphs..."
	elif rng == 5:
		$loadingLabel.text = "Getting a cup of coffee..."
	elif rng == 6:
		$loadingLabel.text = "Fetching API..."
	elif rng == 7:
		$loadingLabel.text = "Getting something to eat..."
	elif rng == 8:
		$loadingLabel.text = "Loading effects..."
	elif rng == 9:
		$loadingLabel.text = "Fetching market data..."
	elif rng == 10:
		$loadingLabel.text = "Initializing synths..."
	elif rng == 11:
		$loadingLabel.text = "Loading audio engine..."
	elif rng == 12:
		$loadingLabel.text = "Tuning oscillators..."
	elif rng == 13:
		$loadingLabel.text = "Connecting to stock API..."
	elif rng == 14:
		$loadingLabel.text = "Calibrating delay..."
	elif rng == 15:
		$loadingLabel.text = "Normalizing audio channels..."
	elif rng == 16:
		$loadingLabel.text = "Generating waveforms..."
	elif rng == 17:
		$loadingLabel.text = "Loading instrument presets..."
	elif rng == 18:
		$loadingLabel.text = "Indexing stock symbols..."
	elif rng == 19:
		$loadingLabel.text = "Pre-rendering visualizers..."
	elif rng == 20:
		$loadingLabel.text = "Preparing tutorials..."
	elif rng == 21:
		$loadingLabel.text = "Preparing stock list sidebar..."
	elif rng == 22:
		$loadingLabel.text = "These loading messages are fake (shh)"
	elif rng == 23:
		$loadingLabel.text = "Making songs..."
	elif rng == 24:
		$loadingLabel.text = "Writing smart sounding loading messages..."
	elif rng == 25:
		$loadingLabel.text = "Waiting for this to finish..."
	elif rng == 26: 
		$loadingLabel.text = "Finalizing setup..."
	elif rng == 27:
		$loadingLabel.text = "Finalizing loading..."
	elif rng == 28:
		$loadingLabel.text = "Rendering stocks..."
	elif rng == 29:
		$loadingLabel.text = "Smoothing out graphs..."
	elif rng == 30:
		$loadingLabel.text = "Applying filters..."
