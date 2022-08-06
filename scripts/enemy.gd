extends PathFollow2D

signal damage
signal destroyed(enem)

onready var tween = $Tween
onready var path : Path2D = get_parent()
onready var health_bar = $health_bar
var anim_speed : float
export var health := 2

func _ready():
	offset = 0
	health_bar.max_value = health
	health_bar.value = health
	pass 

func on_beat():
	tween.interpolate_property(self, "offset", offset, offset+64, anim_speed)
	tween.start()

func _physics_process(_delta):
	if unit_offset >= .99:
		emit_signal("damage")
		destroy()

func destroy():
	emit_signal("destroyed", self)
	queue_free()

func hurt(amt):
	health -= amt
	health_bar.value = health
	if health <= 0:
		destroy()
