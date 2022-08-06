extends Node2D

onready var cursor := $cursor
onready var map := $TileMap
onready var build_menu := $CanvasLayer/Control/BuildMenu
onready var enemy_path := $enemy_path
onready var rad_option_scene = load("res://scenes/rad_option.tscn")
onready var enemy_scene = load("res://scenes/enemy.tscn")
onready var update_timer = $update_timer
onready var health_label = $CanvasLayer/Control/HealthLabel

const BPM = 200.0
const BPM_SEC = 60.0/BPM

enum TYPE {BUILD_AREA = 8, TOWER = 0}
const CELLDIM = 64;
var towers_info = []
var selected_pos : Vector2
var selected_cell_pos: Vector2
var health = 10 setget set_health
var enemies = []

signal health_changed(new_health)
signal on_beat

func _ready():
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
	
	connect("health_changed", health_label, "on_health_update")

func align_path():
	var curv = enemy_path.curve
	for i in range(0, curv.get_point_count()):
		curv.set_point_position(i, curv.get_point_position(i).snapped(Vector2(CELLDIM,CELLDIM)) + Vector2(CELLDIM/2.0,CELLDIM/2.0))

func _unhandled_input(event):
	if event is InputEventMouse:
		var tile_pos = (event.position - Vector2(CELLDIM/2.0,CELLDIM/2.0)).snapped(Vector2(CELLDIM,CELLDIM))
		if event is InputEventMouseMotion:
			cursor.position = tile_pos
		elif event is InputEventMouseButton and event.is_pressed():
			var cell_pos = tile_pos/CELLDIM
			match map.get_cellv(cell_pos):
				TYPE.BUILD_AREA: pos_menu(tile_pos, cell_pos)

func pos_menu(pos: Vector2, cell_pos: Vector2):
	build_menu.visible = true;
	build_menu.rect_position = pos - Vector2(100,100) + Vector2(CELLDIM/2.0, CELLDIM/2.0)
	selected_pos = pos
	selected_cell_pos = cell_pos

func construct(pos: Vector2, cell_pos: Vector2, tower_data: tower):
	if health <= 0:
		return
	var new_tower = tower_data.scene.instance()
	new_tower.position = pos + Vector2(CELLDIM/2.0, CELLDIM/2.0)
	new_tower.enemies = enemies
	
	connect("on_beat", new_tower, "on_beat")
	add_child(new_tower)
	
	map.set_cellv(cell_pos, 0)

func set_health(amt):
	health = amt
	emit_signal("health_changed", health)

func on_damage():
	self.health = health - 1
	if(health <= 0):
		$CanvasLayer/Control/lost.visible = true
		$update_timer.stop()
	$ShakeCamera2D.add_stress(.5)

func on_destroy(en):
	enemies.remove(enemies.find(en))
	
func _on_BuildMenu_selected(child):
	construct(selected_pos, selected_cell_pos, child.tower_data)
	build_menu.visible = false;

func _on_update_timer_timeout():
	var en = enemy_scene.instance()
	en.anim_speed = BPM_SEC * .6
	
	en.connect("damage", self, "on_damage")
	en.connect("destroyed", self, "on_destroy")
	connect("on_beat", en, "on_beat")
	
	enemy_path.add_child(en)
	enemies.push_back(en)
	
	emit_signal("on_beat")


func _on_restart_button_up():
	enemy_path.queue_free()
	get_tree().change_scene("res://scenes/main_menu.tscn")
