extends Node2D

signal damage
signal destroyed(enem)

onready var tween = $Tween
onready var health_bar = $health_bar
onready var anim = $AnimationPlayer
onready var health_anim = $health_anim
onready var dust_cloud = load("res://scenes/dust.tscn")
export var health := 5
export var speed := 1

var frozen := false
var container

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color("#bada55"))
	health_bar.add_stylebox_override("fg", new_style)

func on_beat():
	if frozen:
		return
	anim.play("wiggle")

func destroy():
	emit_signal("destroyed", self)
	queue_free()

func hurt(amt):
	health -= amt
	health_bar.value = health
	health_anim.play("healthbar_flash")
	if health <= 0:
		var dust = dust_cloud.instance()
		dust.position = position
		dust.emitting = true
		get_tree().root.add_child(dust)
		var main = get_tree().root.get_node("Main")
		main.get_node('dead').play()
		main.time_bar_amt = main.time_bar_amt + 1
		main.gold = main.gold + 1
		destroy()

func on_freeze(state):
	frozen = state

func _on_VisibilityNotifier2D_screen_exited():
	if health <= 0:
		return
	emit_signal("damage")
	destroy()
