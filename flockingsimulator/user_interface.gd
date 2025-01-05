extends Control

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("pause"):
		#get_tree().paused = !get_tree().paused
	#if event.is_action_pressed("show_crosshair"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		##$Crosshair.show()
	#if event.is_action_released("show_crosshair"):
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		##$Crosshair.hide()
