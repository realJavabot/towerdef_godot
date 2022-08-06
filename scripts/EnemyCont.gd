extends PathFollow2D

var anim_speed : float
onready var tween = $Tween
var enemy_node

func _ready():
	$RemoteTransform2D.remote_path = enemy_node.get_ref().get_path()
	
func on_beat():
	var e_ref = enemy_node.get_ref()
	if !e_ref:
		queue_free()
		return
	if(e_ref.frozen):
		return
	tween.interpolate_property(self, "offset", offset, offset+64, anim_speed)
	tween.start()
	if unit_offset >= .95:
		queue_free()
