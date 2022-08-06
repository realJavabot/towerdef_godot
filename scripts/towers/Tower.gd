extends Sprite

#set by main
var enemies
onready var proj_scene = load("res://scenes/projectile.tscn")

func on_beat():
	for en in enemies:
		if position.distance_to(en.position) <= 65*2:
			var proj = proj_scene.instance()
			proj.target = weakref(en)
			add_child(proj)
			return
