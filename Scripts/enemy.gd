class_name Enemy extends Node2D

@onready var xspeed = 50
@onready var yspeed = 30
@onready var area_2d: Area2D = $Area2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var explosion_scene = preload("res://Scenes/explosion.tscn")
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var move_direction = 1
@onready var in_front = false
@export var enemy_type = 0
var EnemyHitSignal

func _ready() -> void:
	check_front()

func fire():
	var bullet: Bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.enemy_owned(position)

func check_front():
	in_front = not ray_cast_2d.is_colliding()
	return in_front

func change_direction():
	move_direction *= -1

func move_horizontal():
	global_position.x += xspeed * move_direction
	
func move_down():
	global_position.y += yspeed

func _enemy_died():
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	EnemyHitSignal.emit(enemy_type)
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		get_parent().enemy_hit_wall()
		
	if area.get_parent().is_in_group("player_bullet"):
		_enemy_died()
		
