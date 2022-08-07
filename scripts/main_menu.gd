extends Control


func _on_Button_button_up():
	get_tree().change_scene("res://scenes/Main.tscn")

func _ready():
	$CenterContainer/VBoxContainer/title/anim.play("float")
