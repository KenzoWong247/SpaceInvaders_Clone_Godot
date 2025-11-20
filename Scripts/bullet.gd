class_name Bullet extends Node2D

const SPEED = 1000
@onready var velocity = 1
@onready var time_elapsed = 0.0
@onready var lifetime = 5 
@onready var area_2d: Area2D = $Area2D

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	global_position.y += delta * SPEED * velocity
	
	if time_elapsed > lifetime:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("bottom_boundary") or area.get_parent() is Bullet:
		velocity = 0
		var explosion = load("res://Scenes/explosion.tscn").instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
	queue_free()

func player_owned(new_position: Vector2):
	position = new_position
	velocity = -1
	area_2d.set_collision_mask_value(3, true)
	area_2d.set_collision_layer_value(3, true)
	add_to_group("player_bullet")

func enemy_owned(new_position: Vector2):
	position = new_position
	velocity = 1
	area_2d.set_collision_mask_value(2, true)
	area_2d.set_collision_layer_value(2, true)
	add_to_group("enemy_bullet")
