extends Node2D

var enemies
var count = 3
var def_count = 3
var upgrade_count = 2
var tower_data

func on_beat():
	$text.visible = true
	count -= 1
	if count == 0:
		count = def_count + 1
		$text.visible = false
		$ring.play("ring")
	$text.bbcode_text = '[center]%d' % count

func ring():
	for en in enemies:
		if position.distance_to(en.position) < 64*2:
			en.hurt(2)

func upgrade():
	def_count -= 1
	upgrade_count -= 1
	$upgrade.text += "+"
