extends TextureButton



func _on_Button_mouse_entered():
	$anim.play("wiggle")


func _on_Button_mouse_exited():
	$anim.stop()
	rect_rotation = 0
