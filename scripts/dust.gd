extends Particles2D

func _ready():
	$free_timer.wait_time = lifetime
	$free_timer.start()

func _on_free_timer_timeout():
	queue_free()
