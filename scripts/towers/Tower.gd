extends Node2D

#set by main
var enemies
onready var proj_scene = load("res://scenes/projectile.tscn")
onready var anim = $sprite/AnimationPlayer
var damage = 1
var tower_data
var upgrade_count = 2

func on_beat():
	var nearest = null
	for en in enemies:
		if position.distance_to(en.position) <= 64*2 && (nearest == null || en.container.offset > nearest.container.offset):
			nearest = en
	if nearest == null:
		return
	get_tree().root.get_node("Main/shoot").play()
	anim.play("shoot")
	var proj = proj_scene.instance()
	proj.damage = damage
	proj.target = weakref(nearest)
	add_child(proj)

func upgrade():
	damage += 1
	upgrade_count -= 1
	$upgrade.text += "+"

func destroy():
	get_tree().root.get_node("Main").taken_pos.erase(position.snapped(Vector2(64,64))/64.0 - Vector2(1,0))
	queue_free()
