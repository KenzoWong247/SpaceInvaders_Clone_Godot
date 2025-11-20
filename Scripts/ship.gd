class_name Ship extends Node2D

const SPEED = 500
@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitting_left_boundary = false
@onready var hitting_right_boundary = false
@onready var cooldown_time = 0.2
@onready var cooldown_timer = 0.0
@onready var on_cooldown = false
@onready var gun_offset = Vector2(0, 33)
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var explosion_scene = preload("res://Scenes/explosion.tscn")
@onready var start_pos = global_position
@onready var is_alive = true
@onready var ai_control_pressed = -1
@onready var ai_control_counter = 0
@onready var ai_controlled = false

func _physics_process(delta: float) -> void:
	if on_cooldown:
		cooldown_timer += delta
		if cooldown_timer > cooldown_time:
			on_cooldown = false
			cooldown_timer = 0
			
	var direction = 0
	if is_alive:
		if ai_controlled and ai_control_counter < 4:
			if ai_control_pressed == 1 or ai_control_pressed == 3 and not hitting_left_boundary:
				direction -= 1
			if ai_control_pressed == 2 or ai_control_pressed == 4 and not hitting_right_boundary:
				direction += 1
			if ai_control_pressed > 2 and not on_cooldown:
				on_cooldown = true
				_fire()
			ai_control_counter += 1
		else:
			if Input.is_action_pressed("move_left") and not hitting_left_boundary:
				direction -= 1
			if Input.is_action_pressed("move_right") and not hitting_right_boundary:
				direction += 1
			if Input.is_action_just_pressed("fire_weapon") and not on_cooldown:
				on_cooldown = true
				_fire()
		
	global_position.x += direction * delta * SPEED
		
func ai_set_control(control_num: int):
	clear_ai_control()
	# Control Scheme: 0 = Left, 1 = Right, 2 = Shoot, 3 = Shoot/Left, 4 = Shoot/Right
	ai_control_pressed = control_num
	
func clear_ai_control():	
	ai_control_pressed = 0
	ai_control_counter = 0

func _fire():
	var bullet: Bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.player_owned(position - gun_offset)
	
func respawn():
	area_2d.set_collision_layer_value(2, true)
	global_position = start_pos
	sprite_2d.show()
	is_alive = true
	
func _player_died():
	is_alive = false
	area_2d.set_collision_layer_value(2, false)
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	sprite_2d.hide()
	get_parent().add_child(explosion)
	get_parent().ShipHit.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("left_boundary"):
		hitting_left_boundary = true
	
	if area.is_in_group("right_boundary"):
		hitting_right_boundary = true
		
	if area.is_in_group("enemy"):
		get_parent().GameOver.emit()
		
	if area.get_parent().is_in_group("enemy_bullet"):
		_player_died()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("left_boundary"):
		hitting_left_boundary = false

	if area.is_in_group("right_boundary"):
		hitting_right_boundary = false
