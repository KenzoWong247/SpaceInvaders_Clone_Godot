extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var time_elapsed = 0
@onready var frame_count = 0
@onready var animation_frames = 6
@onready var animation_length = 10
@onready var expansion = 8
@onready var fps = 30

func _expand():
	var new_region = sprite_2d.region_rect.grow(expansion)
	sprite_2d.region_rect = new_region

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	
	if time_elapsed >= 1.0/fps:
		time_elapsed = 0
		
		# Only Expand for x frames
		if frame_count < animation_frames:
			_expand()
	
		frame_count += 1
		
		# Extend animation persistence on screen
		if frame_count >= animation_length:
			queue_free()
		
