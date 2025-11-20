class_name EnemyController extends Node2D

@onready var move_timer = 1
@onready var shot_timer = 1
@onready var hit_wall = false
@onready var shot_time_elapsed = 0
@onready var move_time_elapsed = 0
@onready var hold_movement = false
@onready var enemy_count = get_child_count()
@onready var front_line = []
signal move_horizontal
signal change_direction
signal move_down
signal EnemyHit(enemy_type: int)

func _ready() -> void:
	for enemy in get_children():
		if enemy is Enemy:
			enemy_count += 1
			move_horizontal.connect(enemy.move_horizontal)
			change_direction.connect(enemy.change_direction)
			move_down.connect(enemy.move_down)		
			enemy.EnemyHitSignal = EnemyHit
			if enemy.check_front():
				front_line.append(enemy)
			
func level_scale(level: int):
	shot_timer = max(0.05, 1 - (level - 1) * 0.1)
	move_timer = max(0.02, 1 - (level - 1) * 0.2)
	for enemy in get_children():
		if enemy is Enemy:
			enemy.xspeed = enemy.xspeed + (level - 1) * 10
			
func _physics_process(delta: float) -> void:
	if not hold_movement:
		shot_time_elapsed += delta
		move_time_elapsed += delta
		if move_time_elapsed > move_timer:
			move_time_elapsed = 0
			_move()
		
		if shot_time_elapsed > shot_timer:
			shot_time_elapsed = 0
			_enemy_frontline_fire()
	
func _enemy_frontline_fire():
	if get_child_count() < enemy_count:
		front_line = []
		for enemy in get_children():
			if enemy is Enemy:
				if enemy.check_front():
					front_line.append(enemy)
	
	if front_line:
		var fire_enemy = front_line[randi_range(0, len(front_line) - 1)]
		if fire_enemy:
			fire_enemy.fire()

func enemy_hit_wall():
	hit_wall = true
	
func clear_bullets():
	for child in get_children():
		if child is Bullet:
			child.queue_free()

func _move() -> void:
	if not hit_wall:
		move_horizontal.emit()
	else:
		move_down.emit()
		change_direction.emit()
		hit_wall = false

func disable_movement(disabled: bool):
	# Will pause if disabled = true
	hold_movement = disabled
	
