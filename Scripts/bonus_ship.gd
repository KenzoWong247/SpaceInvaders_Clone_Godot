class_name BonusShip extends Node2D

const SPEED = 200
@onready var area_2d: Area2D = $Area2D
@onready var explosion_scene = preload("res://Scenes/explosion.tscn")
@onready var direction = 1
@onready var despawn_timer: Timer = $"Despawn Timer"
@onready var boundary_count = 0

func _physics_process(delta: float) -> void:
	global_position.x += direction * delta * SPEED

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		boundary_count += 1
		if boundary_count >= 2:
			despawn_timer.start(2)
		
	if area.get_parent().is_in_group("player_bullet"):
		_bonus_ship_hit()
		queue_free()

func _bonus_ship_hit():
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	get_parent().bonus_ship_hit()
	queue_free()

func _on_despawn_timer_timeout() -> void:
	get_parent().bonus_ship_despawn()
	queue_free()
	
