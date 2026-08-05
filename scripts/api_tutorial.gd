extends Node2D

var slide = 1


# Sets up the first slide
func _process(delta: float) -> void:
	if slide == 1:
		$prevButton.disabled = true
		$curSlideLabel.text = "1/6"
		_hide_all()
		$MainLabel.text = "This will walk you through the steps necessary to get an API key!"
	else:
		$prevButton.disabled = false

# Hides all of the textures, much more efficient to call this than copy/paste large lines of code
func _hide_all():
	$texture1.visible = false
	$texture2.visible = false
	$texture3.visible = false
	$texture4.visible = false
	$texture5.visible = false
	$linkButton.visible = false





# Checks if the slide is below the max, and then advances, and then applies the correct text on the labels according to the current slide
func _on_advance_button_pressed() -> void:
	if slide < 6:
		slide += 1
	if slide == 2:
		_hide_all()
		$curSlideLabel.text = "2/6"
		$texture1.visible = true
		$MainLabel.text = "First, click on the above link or go to twelvedata.com"
		$linkButton.visible = true
	if slide == 3:
		_hide_all()
		$curSlideLabel.text = "3/6"
		$texture2.visible = true
		$MainLabel.text = "Next, fill in the info and press create account. You may have to verify via. an email code."
	if slide == 4:
		_hide_all()
		$curSlideLabel.text = "4/6"
		$texture3.visible = true
		$MainLabel.text = "Now, navigate to the API keys tab."
	if slide == 5:
		_hide_all()
		$curSlideLabel.text = "5/6"
		$texture4.visible = true
		$MainLabel.text = "Now, press 'reveal' and copy your key."
	if slide == 6:
		_hide_all()
		$curSlideLabel.text = "6/6"
		$texture5.visible = true
		$MainLabel.text = "You're done! Just paste that into the box on the main menu and press start!"

# Same as above, advances the slide if needed and then updates text
func _on_prev_button_pressed() -> void:
	if slide > 1:
		slide -= 1
	if slide == 2:
		_hide_all()
		$curSlideLabel.text = "2/6"
		$texture1.visible = true
		$MainLabel.text = "First, click on the above link or go to twelvedata.com"
		$linkButton.visible = true
	if slide == 3:
		_hide_all()
		$curSlideLabel.text = "3/6"
		$texture2.visible = true
		$MainLabel.text = "Next, fill in the info and press create account. You may have to verify via. an email code."
	if slide == 4:
		_hide_all()
		$curSlideLabel.text = "4/6"
		$texture3.visible = true
		$MainLabel.text = "Now, navigate to the API keys tab."
	if slide == 5:
		_hide_all()
		$curSlideLabel.text = "5/6"
		$texture4.visible = true
		$MainLabel.text = "Now, press 'reveal' and copy your key."
	if slide == 6:
		_hide_all()
		$curSlideLabel.text = "6/6"
		$texture5.visible = true
		$MainLabel.text = "You're done! Just paste that into the box on the main menu!"

# Changes the scene to the main menu
func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
