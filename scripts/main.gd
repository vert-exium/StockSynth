extends Control

var stockListIsShown = false
var tween: Tween


# When the stock list button is pressed, checks if the list is extended or it hasn't been toggled, and then starts a cooldown timer, changes the text of the button, and then creates a tween and starts it to change the position of the button and list
func _on_stock_list_button_pressed() -> void:
	if stockListIsShown == false:
		$buttonCooldownTimer.start()
		$stockListButton.disabled = true
		var tween = create_tween()
		tween.set_parallel()
		tween.set_trans(Tween.TRANS_QUART)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($stockListButton, "position:x", 1475, 1.0)
		tween.tween_property($stocklist, "position:x", 1735, 1.0)
		$stockListButton.text = "Popular Stock List >"
		stockListIsShown = true
	elif stockListIsShown == true:
		$buttonCooldownTimer.start()
		$stockListButton.disabled = true
		var tween = create_tween()
		tween.set_parallel()
		tween.set_trans(Tween.TRANS_QUART)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($stockListButton, "position:x", 1665, 1.0)
		tween.tween_property($stocklist, "position:x", 1930, 1.0)
		$stockListButton.text = "Popular Stock List <"
		stockListIsShown = false



func _on_button_cooldown_timer_timeout() -> void:
	$stockListButton.disabled = false


# Starts the timer to update the tip label right away
func _ready() -> void:
	$tipUpdateTimer.start(10)



# When the timer ends, generates a random number ranging from 1-12 and then changes the text of the tip label according to which number was generated (also restarts the timer so it loops infinitely)
func _on_tip_update_label_timeout() -> void:
	$tipUpdateTimer.start(10)
	var rng = RandomNumberGenerator.new()
	rng = randi_range(1, 12)
	if rng == 1:
		$tipLabel.text = "Did you know there are multiple tutorials?"
	elif rng == 2:
		$tipLabel.text = "Tip: you can open a list of popular stocks in the top right!"
	elif rng == 3:
		$tipLabel.text = "Play with the effects to get your song sounding better!"
	elif rng == 4:
		$tipLabel.text = "Tip: You can change the stock currently being tracked and how long the history goes!"
	elif rng == 5:
		$tipLabel.text = "Play with the different options for instruments!"
	elif rng == 6:
		$tipLabel.text = "You can change the update rate of the sound! For synths you can set it low, but you can increase it for drums!"
	elif rng == 7:
		$tipLabel.text = "Reverb works best on melodic instruments!"
	elif rng == 8:
		$tipLabel.text = "You can toggle scanline particles on or off if you want a cleaner look."
	elif rng == 9:
		$tipLabel.text = "You can use up to 4 different instruments at once!"
	elif rng == 10:
		$tipLabel.text = "There's a cool visualizer!"
	elif rng == 11:
		$tipLabel.text = "Did you know all instruments have been handmade in FL Studio?"
	elif rng == 12:
		$tipLabel.text = "All of the UI has been hand built!"
