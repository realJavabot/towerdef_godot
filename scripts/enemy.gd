extends PathFollow2D

onready var tween = $Tween
onready var path : Path2D = get_parent()

func _ready():
	pass 

func move():
	var old_pos := position
	offset = offset + 64
	tween.interpolate_property(self, "position", old_pos, position.snapped(Vector2(64,64)) - Vector2(32,-32), .5)
	tween.start()
