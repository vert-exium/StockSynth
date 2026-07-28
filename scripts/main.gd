extends Control

var stockListIsShown = false
var tween: Tween

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
	
