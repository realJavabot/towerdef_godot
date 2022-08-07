extends Sprite

var target
var damage = 1

func _physics_process(delta):
	var t_ref = target.get_ref()
	if !t_ref:
		queue_free()
		return
	global_position = global_position.move_toward(t_ref.position, delta * 400)
	if(global_position.distance_squared_to(t_ref.position) < .01):
		t_ref.hurt(damage)
		queue_free()
		
