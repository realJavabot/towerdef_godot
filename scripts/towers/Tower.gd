extends Node2D

#set by main
var enemies
onready var proj_scene = load("res://scenes/projectile.tscn")
onready var anim = $sprite/AnimationPlayer
var damage = 1
var tower_data
var upgrade_count = 2

func on_beat():
	for en in enemies:
		if position.distance_to(en.position) <= 64*2:
			anim.play("shoot")
			var proj = proj_scene.instance()
			proj.damage = damage
			proj.target = weakref(en)
			add_child(proj)
			return

func upgrade():
	damage += 1
	upgrade_count -= 1
	$upgrade.text += "+"
