extends Node2D

@export var games = 1
@onready var game_positions = {}
@onready var games_folder: Node2D = $"Games Folder"
@onready var normal_camera: Camera2D = $"Normal Camera"
@onready var new_game_scene = preload("res://Scenes/game.tscn")
@onready var x_offset = 2176
@onready var y_offset = 1664

func _ready() -> void:
	#var game_count = 0 
	for i in range(0, games):
		create_new_game(Vector2((i % 5) * x_offset, floor(i / 5.0) * y_offset))
		
	#for game: Game in games_folder.get_children():
		#if game_count < games:
			#game_positions[game.get_instance_id()] = game.global_position
			#game.GameOver.connect(replace_game_instance)
		#else:
			#game.enabled = false
		#game_count += 1
		
	normal_camera.make_current()
	if games == 1:
		normal_camera.zoom = Vector2(0.5, 0.5)
	else:
		normal_camera.zoom = Vector2(0.2, 0.2)
		
		
func replace_game_instance(instance_id):
	var old_position = game_positions[instance_id]
	create_new_game(old_position)
	game_positions.erase(instance_id)
	
	
func create_new_game(pos: Vector2):
	var new_game = new_game_scene.instantiate()
	new_game.global_position = pos
	games_folder.add_child(new_game)
	game_positions[new_game.get_instance_id()] = new_game.global_position
	new_game.GameOver.connect(replace_game_instance)
	 
		
