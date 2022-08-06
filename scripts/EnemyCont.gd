extends PathFollow2D

var anim_speed : float
onready var tween = $Tween

func ready():
	offset = 0
	
func on_beat():
	tween.interpolate_property(self, "offset", offset, offset+64, anim_speed)
	tween.start()
	if unit_offset >= .95:
		queue_free()
