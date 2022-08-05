extends Node2D

onready var cursor := $cursor
onready var map := $TileMap
onready var build_menu := $CanvasLayer/Control/BuildMenu
onready var enemy_path := $enemy_path
onready var rad_option_scene = load("res://scenes/rad_option.tscn")
onready var enemy_scene = load("res://scenes/enemy.tscn")

enum TYPE {BUILD_AREA = 8, TOWER = 0}
const CELLDIM = 64;
var towers = []
var selected_pos : Vector2

func _ready():
	var directory = Directory.new()
	var error = directory.open("res://towers/")
	if error == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while (file_name != ""):
			if !directory.current_is_dir() and file_name.ends_with(".tres"):
				towers.push_front(load("res://towers/%s" % file_name))
			file_name = directory.get_next()
	else:
		print("Error opening directory")
	
	for t in towers:
		var tower_inst = rad_option_scene.instance()
		tower_inst.tower_data = t
		build_menu.add_button(tower_inst)

func _unhandled_input(event):
	if event is InputEventMouse:
		var tile_pos = (event.position - Vector2(32,32)).snapped(Vector2(CELLDIM,CELLDIM))
		if event is InputEventMouseMotion:
			cursor.position = tile_pos
		elif event is InputEventMouseButton:
			var cell_pos = tile_pos/CELLDIM
			match map.get_cellv(cell_pos):
				TYPE.BUILD_AREA: pos_menu(cell_pos)

func pos_menu(cell_pos: Vector2):
	build_menu.visible = true;
	build_menu.rect_position = (cell_pos + Vector2(.5,.5)) * CELLDIM - Vector2(100,100)
	selected_pos = cell_pos

func construct(cell_pos: Vector2, tower_data: tower):
	map.set_cellv(cell_pos, tower_data.cell_index);
	pass

func _process(delta):
	
	pass


func _on_BuildMenu_selected(child):
	construct(selected_pos, child.tower_data)
	build_menu.visible = false;

func _on_update_timer_timeout():
	var en = enemy_scene.instance()
	enemy_path.add_child(en)
	
	for enemy in enemy_path.get_children():
		enemy.move()
