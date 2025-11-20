class_name GameController extends Node2D


@onready var bonus_spawn_left: Marker2D = $"Bonus/Bonus Spawn Left"
@onready var bonus_spawn_right: Marker2D = $"Bonus/Bonus Spawn Right"
@onready var bonus_spawn_timer: Timer = $"Bonus/Bonus Spawn Timer"
@onready var enemy_controller: EnemyController = $EnemyController
@onready var ship: Ship = $Ship

@onready var game: Game = $"../../.."
@onready var lives = 3
@onready var level = 1
@onready var score = 0
@onready var bonus_ship_scene = preload("res://Scenes/Characters/bonus_ship.tscn")
@onready var bonus_ship: BonusShip = null
@onready var bonus_points = 800
@onready var bonus_min = 30
@onready var bonus_max = 60
@onready var enemy_counter = 0
@onready var enemy_controller_start_pos
signal ShipHit

func _ready() -> void:
	ShipHit.connect(player_died)
	enemy_controller.EnemyHit.connect(enemy_died)
	enemy_controller.level_scale(level)
	bonus_spawn_timer.start(randi_range(bonus_min, bonus_max))
	enemy_counter = enemy_controller.get_child_count()
	enemy_controller_start_pos = enemy_controller.position
	
func reset_game_state():
	ship.is_alive = false
	enemy_controller.queue_free()
	if bonus_ship:
		bonus_ship.queue_free()
	await get_tree().process_frame
	var enemy_controller_scene = load("res://Scenes/Characters/enemy_controller.tscn")
	enemy_controller = enemy_controller_scene.instantiate()
	await get_tree().process_frame
	await call_deferred("add_child", enemy_controller)
	enemy_controller.position = enemy_controller_start_pos
	enemy_controller.disable_movement(true)
	enemy_controller.EnemyHit.connect(enemy_died)
	await get_tree().process_frame
	enemy_controller.level_scale(level)
	bonus_spawn_timer.start(randi_range(bonus_min, bonus_max))
	ship.respawn()
	enemy_counter = enemy_controller.get_child_count()
	enemy_controller.disable_movement(false)

func game_over():
	game.show_game_over()
	bonus_spawn_timer.stop()
	await Wait(3)
	game.game_over()
	queue_free()
	
func _clear_bullets():
	for child in get_children():
		if child is Bullet:
			child.area_2d.set_collision_layer_value(3, false)
			child.queue_free()

func player_died():
	enemy_controller.disable_movement(true)
	enemy_controller.clear_bullets()
	lives -= 1
	game.set_lives_label(lives)
	_clear_bullets()
	await Wait(2)
	if lives > 0:
		ship.respawn()
		enemy_controller.disable_movement(false)
	else:
		game_over()
	
	
func enemy_died(enemy_type):
	# Type 4 is the bonus
	if enemy_type < 4:
		score += enemy_type * 10
	game.set_score_label(score)
	enemy_counter -= 1
	if enemy_counter <= 0:
		level += 1
		lives += 1
		game.set_lives_label(lives)
		game.set_level_label(level)
		reset_game_state()

func Wait(seconds: float, ignore_engine_scale: bool = true) -> void:
	if get_tree():
		await get_tree().create_timer(seconds, false, false, ignore_engine_scale).timeout
	else:
		print("Failed to wait")


func bonus_ship_hit():
	score += bonus_points
	game.set_score_label(score)
	bonus_spawn_timer.start(randi_range(bonus_min, bonus_max))
	
func bonus_ship_despawn():
	bonus_spawn_timer.start(randi_range(bonus_min, bonus_max))
	

func _on_bonus_spawn_timer_timeout() -> void:
	var side = randi_range(0, 1)
	bonus_ship = bonus_ship_scene.instantiate()
	add_child(bonus_ship)
	if side <= 0:
		bonus_ship.global_position = bonus_spawn_left.global_position
	else:
		bonus_ship.global_position = bonus_spawn_right.global_position
		bonus_ship.direction = -1
