extends Node2D

onready var cursor := $cursor
onready var map := $TileMap
onready var build_menu := $CanvasLayer/Control/BuildMenu
onready var upgrade_menu := $CanvasLayer/Control/UpgradeMenu
onready var enemy_path := $enemy_path
onready var rad_option_scene = load("res://scenes/rad_option.tscn")
onready var enemy_scene = load("res://scenes/enemy.tscn")
onready var big_enemy_scene = load("res://scenes/enemy_big.tscn")
onready var fast_enemy_scene = load("res://scenes/enemy_fast.tscn")
onready var exploding_enemy_scene = load("res://scenes/enemy_explode.tscn")
onready var enemy_cont_scene = load("res://scenes/EnemyCont.tscn")
onready var update_timer = $update_timer
onready var gold_label = $CanvasLayer/Control/gold/gold_label
onready var time_bar = $CanvasLayer/Control/center/TimeBar
onready var distortion = $CanvasLayer/Control/distortion_effect
onready var ysort = $ysort
onready var tower_hits = $sounds/tower_hit.get_children()

const BPM = 80.0
const BPM_SEC = 60.0/BPM
const BEAT_END_FIRST_WAVE = 20
const BEAT_END_SECOND_WAVE = 30
const BEAT_END_THIRD_WAVE = 40
const BEAT_END_FOURTH_WAVE = 60
const BEAT_END_FIFTH_WAVE = 100
const BEAT_END_SIXTH_WAVE = 150
const BEAT_END = 200

var build_area_indices = [9,10,11]
const CELLDIM = 64;
var towers_info = []
var selected_pos : Vector2
var selected_cell_pos: Vector2
var health = 10 setget set_health
var gold = 10 setget setgold
var enemies = []
var time_bar_amt = 0 setget time_bar_set
var time_bar_max = 30.0
var beat_count = 0
var bomb_count = 0

var taken_pos = {}

export (Array, Texture) var time_bar_tex_array

signal health_changed(new_health)
signal on_beat
signal freeze(state)

var amount_contructed = 0

func _ready():
	setgold(gold)
	update_timer.wait_time = BPM_SEC
	var directory = Directory.new()
	var error = directory.open("res://towers/")
	if error == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while (file_name != ""):
			if !directory.current_is_dir() and file_name.ends_with(".tres"):
				towers_info.push_front(load("res://towers/%s" % file_name))
			file_name = directory.get_next()
	else:
		print("Error opening directory")
	
	for t in towers_info:
		var tower_inst = rad_option_scene.instance()
		tower_inst.tower_data = t
		build_menu.add_button(tower_inst)
	
	align_path()

func align_path():
	var curv = enemy_path.curve
	for i in range(0, curv.get_point_count()):
		curv.set_point_position(i, curv.get_point_position(i).snapped(Vector2(CELLDIM,CELLDIM)) + Vector2(CELLDIM/2.0,CELLDIM/2.0))

func _input(event):
	if update_timer.is_stopped():
		return
	if event is InputEventMouse:
		var tile_pos = (event.position - Vector2(CELLDIM/2.0,CELLDIM/2.0)).snapped(Vector2(CELLDIM,CELLDIM))
		if event is InputEventMouseMotion:
			cursor.position = tile_pos
		elif event is InputEventMouseButton and event.is_pressed():
			var cell_pos = tile_pos/CELLDIM
			if map.get_cellv(cell_pos) in build_area_indices:
				pos_menu(tile_pos, cell_pos)
	if event.is_action_pressed("freeze") and time_bar_amt == time_bar_max:
		$distortion_tween.interpolate_method(self, "distort", 0, 1.0, .6)
		$distortion_tween.start()
		emit_signal('freeze', true)
		$FreezeTimer.start()
		self.time_bar_amt = 0
		

func distort(time):
	distortion.material.set_shader_param("radius", time)
	$ShakeCamera2D.add_stress(.03)

func pos_menu(pos: Vector2, cell_pos: Vector2):
	var menu = build_menu
	if cell_pos in taken_pos:
		var tow = taken_pos[cell_pos]
		var upgrade_button = upgrade_menu.get_node("upgrade")
		upgrade_button.visible = tow.upgrade_count != 0
		menu = upgrade_menu
		upgrade_button.text = 'upgrade(%d)' % (tow.tower_data.cost - 2)
	menu.visible = true;
	menu.rect_position = pos - Vector2(100,100) + Vector2(CELLDIM/2.0, CELLDIM/2.0)
	selected_pos = pos
	selected_cell_pos = cell_pos

func construct(pos: Vector2, cell_pos: Vector2, tower_data: tower):
	if health <= 0 || tower_data.cost > gold:
		return
	var new_tower = tower_data.scene.instance()
	new_tower.position = pos + Vector2(CELLDIM/2.0, CELLDIM/2.0 - 10)
	new_tower.enemies = enemies
	new_tower.tower_data = tower_data
	
	self.gold = gold - tower_data.cost
	
	amount_contructed += 1
	if(amount_contructed % 2):
		for tow in towers_info:
			tow.cost += 2
		for ch in build_menu.get_children():
			ch.update()
	taken_pos[cell_pos] = new_tower
	connect("on_beat", new_tower, "on_beat")
	ysort.get_node('towers').add_child(new_tower)

func set_health(amt):
	health = amt
	emit_signal("health_changed", health)

func setgold(amt):
	gold = amt
	gold_label.text = str(gold)

func time_bar_set(amt):
	time_bar_amt = clamp(amt, 0, time_bar_max)
	time_bar.texture = time_bar_tex_array[floor(time_bar_amt/time_bar_max * 5.0)]

onready var full_hp = load("res://art/icons/fullheart.png")
onready var half_hp = load("res://art/icons/halfheart.png")

func on_damage():
	if health == 0:
		return
	self.health = health - 1
	var health_icons = $CanvasLayer/Control/health.get_children()
	var last_hp = health_icons[len(health_icons)-1]
	if last_hp.texture == full_hp:
		last_hp.texture = half_hp
	else:
		$CanvasLayer/Control/health.remove_child(last_hp)
	tower_hits[floor(len(tower_hits) * randf())].play()
	if(health <= 0):
		$CanvasLayer/Control/lost.visible = true
		$CanvasLayer/Control/rewind_effect.visible = true
		$lost.play()
		$music.volume_db = -80
		$update_timer.stop()
	$ShakeCamera2D.add_stress(.5)

func on_destroy(en):
	enemies.remove(enemies.find(en))
	if len(enemies) == 0:
		$CanvasLayer/Control/won.visible = true
	
func _on_BuildMenu_selected(child):
	if child == null:
		build_menu.visible = false;
		return
	construct(selected_pos, selected_cell_pos, child.tower_data)
	build_menu.visible = false;

var first_beat = true
func _on_update_timer_timeout():	
	if first_beat:
		first_beat = false
		$music.volume_db = 0
		$music.play()
	emit_signal("on_beat")
	beat_count += 1
	
	if !$FreezeTimer.is_stopped() || beat_count >= BEAT_END || (beat_count < BEAT_END_FIRST_WAVE && beat_count % 2 == 0):
		return
	
	var en = enemy_scene.instance()
	if beat_count > BEAT_END_SECOND_WAVE && randf() > .7:
		en = fast_enemy_scene.instance()
	elif bomb_count <= 2 && beat_count > BEAT_END_FIFTH_WAVE && randf() > .85:
		en = exploding_enemy_scene.instance()
		bomb_count+=1
	elif beat_count > BEAT_END_FOURTH_WAVE || (beat_count > BEAT_END_THIRD_WAVE && randf() > .8):
		en = big_enemy_scene.instance()
	
	if beat_count == BEAT_END_SIXTH_WAVE:
		bomb_count = 0
	
	en.connect("damage", self, "on_damage")
	en.connect("destroyed", self, "on_destroy")
	connect("on_beat", en, "on_beat")
	connect("freeze", en, "on_freeze")
	ysort.get_node('enemies').add_child(en)
	
	var en_cont = enemy_cont_scene.instance()
	en_cont.anim_speed = BPM_SEC * .6
	en_cont.enemy_node = weakref(en)
	
	connect("on_beat", en_cont, "on_beat")
	
	enemy_path.add_child(en_cont)
	enemies.push_back(en)
	en.container = en_cont

func _on_restart_button_up():
	enemy_path.queue_free()
	get_tree().change_scene("res://scenes/main_menu.tscn")


func _on_FreezeTimer_timeout():
	emit_signal('freeze', false)


func _on_music_finished():
	$music.play(78)


func _on_upgrade_pressed():
	var tow = taken_pos[selected_cell_pos]
	var upgrade_cost = tow.tower_data.cost - 2
	if gold >= upgrade_cost && tow.upgrade_count != 0:
		tow.upgrade()
		self.gold = gold - upgrade_cost
	upgrade_menu.visible = false

func _on_trash_pressed():
	var tow = taken_pos[selected_cell_pos]
	tow.destroy()
	upgrade_menu.visible = false
	


func _on_UpgradeMenu_selected(child):
	if child == null:
		upgrade_menu.visible = false

func rewind(time):
	$CanvasLayer/Control/rewind_effect.material.set_shader_param("strength", time)
	$CanvasLayer/Control/rewind_effect.material.set_shader_param("aberration", time/2.0)
	$ShakeCamera2D.add_stress(.032)

func rewind_done():
	get_tree().change_scene("res://scenes/main_menu.tscn")	

func _on_rewind_button_up():
	enemy_path.queue_free()
	$distortion_tween.interpolate_method(self, "rewind", 0, 1.0, .6)
	$distortion_tween.interpolate_callback(self, 1.0, "rewind_done")
	$distortion_tween.start()
