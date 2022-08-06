extends Node2D

#set by main
var enemies
onready var proj_scene = load("res://scenes/projectile.tscn")
onready var anim = $sprite/AnimationPlayer

func on_beat():
	for en in enemies:
		if position.distance_to(en.position) <= 64*2:
			anim.play("shoot")
			var proj = proj_scene.instance()
			proj.target = weakref(en)
			add_child(proj)
			return
