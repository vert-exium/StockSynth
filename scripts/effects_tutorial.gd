extends Node2D


var currentSlide = 1

# sets up the header and body label texts
func _ready() -> void:
	$HeaderLabel.text = "Welcome to the effects tutorial!"
	$bodyLabel.text = "This tutorial will teach you how effects work and what each effect does!"
	_hideall()



# Checks if the current slide number is at the minimum or maximum, and if so it will disable/enable the correct buttons
func _process(delta: float) -> void:
	if currentSlide < 2:
		$backButton.disabled = true
	else: 
		$backButton.disabled = false
	if currentSlide > 5:
		$fwdButton.disabled = true
	else: 
		$fwdButton.disabled = false

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

# Same as the back button, checks what the currentslide number is and then updates the header and body label texts to match.
func _on_fwd_button_pressed() -> void:
	if currentSlide < 6:
		currentSlide += 1
	if currentSlide == 1:
		_hideall()
		$HeaderLabel.text = "Welcome to the effects tutorial!"
		$bodyLabel.text = "This tutorial will teach you how effects work and what each effect does!"
	elif currentSlide == 2:
		_hideall()
		$gradientTexture1.visible = true
		$gradientTexture2.visible = true
		$HeaderLabel.text = "Slide 1: Rates, pitch, and volume offsets."
		$bodyLabel.text = "First, we need to learn about the update rate slider. This slider changes how often the selected instrument plays, from 30ms to 1920ms (almost 2 seconds). For something like a sine wave synth, you can set it pretty low, because you want it to constaly update. For something like a kick or hihat, you might want to increase the update rate so it isn't constantly repeating at a fast pace. For each graph, the volume is constantly being adjusted according to the pitch of isntruments, so the lower frequencies are boosted while the higher frequencies are reduced. The volume offset applies the automatic volume adjustment, and then adds or subtracts the selected offset to that number. Basically, it just makes instruments quieter or louder. The pitch offset is similar. The pitch is constantly changed according to how low or high the graph goes. If you want to make sounds higher or lower pitched you can use this slider. Press next when you're ready to go to the next slide!"
	elif currentSlide == 3:
		_hideall()
		$gradientTexture3.visible = true
		$HeaderLabel.text = "Slide 2: Reverb"
		$bodyLabel.text = "This slider will control the reverb applied to your audio. Reverb is similar to an echo, but it sounds like you're in a room instead of a deep cave. This can be used to make your song sound more atmospheric."
	elif currentSlide == 4:
		_hideall()
		$gradientTexture4.visible = true
		$HeaderLabel.text = "Slide 3: Distortion"
		$bodyLabel.text = "This slider controls the amount of distortion applied to your audio. This changes the audio and makes it sound harsher instead of smooth. This can be great with synths!"
	elif currentSlide == 5:
		_hideall()
		$gradientTexture5.visible = true
		$HeaderLabel.text = "Slide 4: Delay"
		$bodyLabel.text = "This slider controls the delay of your sound. Delay is when a sound is played, and then played again after a certain amount of time. This can be used creatively in many ways. You should try playing with reverb and delay and seeing how they change your song differently!"
	elif currentSlide == 6:
		_hideall()
		$HeaderLabel.text = "Good luck!"
		$bodyLabel.text = "That's it for this tutorial! Press the return to main menu button if you're ready to start, or press the back button to go back to any slide in this tutorial! Have fun!"


# Checks what # currentslide is and updates the header and body label texts to match the current slide
func _on_back_button_pressed() -> void:
	if currentSlide > 1:
		currentSlide -= 1 
	if currentSlide == 1:
		_hideall()
		$HeaderLabel.text = "Welcome to the effects tutorial!"
		$bodyLabel.text = "This tutorial will teach you how effects work and what each effect does!"
	elif currentSlide == 2:
		_hideall()
		$gradientTexture1.visible = true
		$gradientTexture2.visible = true
		$HeaderLabel.text = "Slide 1: Rates, pitch, and volume offsets."
		$bodyLabel.text = "First, we need to learn about the update rate slider. This slider changes how often the selected instrument plays, from 30ms to 1920ms (almost 2 seconds). For something like a sine wave synth, you can set it pretty low, because you want it to constaly update. For something like a kick or hihat, you might want to increase the update rate so it isn't constantly repeating at a fast pace. For each graph, the volume is constantly being adjusted according to the pitch of isntruments, so the lower frequencies are boosted while the higher frequencies are reduced. The volume offset applies the automatic volume adjustment, and then adds or subtracts the selected offset to that number. Basically, it just makes instruments quieter or louder. The pitch offset is similar. The pitch is constantly changed according to how low or high the graph goes. If you want to make sounds higher or lower pitched you can use this slider. Press next when you're ready to go to the next slide!"
	elif currentSlide == 3:
		_hideall()
		$gradientTexture3.visible = true
		$HeaderLabel.text = "Slide 2: Reverb"
		$bodyLabel.text = "This slider will control the reverb applied to your audio. Reverb is similar to an echo, but it sounds like you're in a room instead of a deep cave. This can be used to make your song sound more atmospheric."
	elif currentSlide == 4:
		_hideall()
		$gradientTexture4.visible = true
		$HeaderLabel.text = "Slide 3: Distortion"
		$bodyLabel.text = "This slider controls the amount of distortion applied to your audio. This changes the audio and makes it sound harsher instead of smooth. This can be great with synths!"
	elif currentSlide == 5:
		_hideall()
		$gradientTexture5.visible = true
		$HeaderLabel.text = "Slide 4: Delay"
		$bodyLabel.text = "This slider controls the delay of your sound. Delay is when a sound is played, and then played again after a certain amount of time. This can be used creatively in many ways. You should try playing with reverb and delay and seeing how they change your song differently!"
	elif currentSlide == 6:
		_hideall()
		$HeaderLabel.text = "Good luck!"
		$bodyLabel.text = "That's it for this tutorial! Press the return to main menu button if you're ready to start, or press the back button to go back to any slide in this tutorial! Have fun!"


# A function to hide all of the gradient texture, gets called when every slide is checked
# this saves a lot of lines of code as we can just call this instead of copy pasting text over and over
func _hideall():
	$gradientTexture1.visible = false
	$gradientTexture2.visible = false
	$gradientTexture3.visible = false
	$gradientTexture4.visible = false
	$gradientTexture5.visible = false
