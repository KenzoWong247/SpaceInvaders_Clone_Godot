class_name Game extends Node2D

@export var enabled = true
@onready var lives_label: Label = $"Control/Lives Label"
@onready var score_label: Label = $"Control/Score Label"
@onready var level_label: Label = $"Control/Level Label"
@onready var game_over_label: Label = $"Control/Game Over Label"
@onready var game_controller: Node2D = $SubViewportContainer/SubViewport/GameController

signal GameOver(instance_id)

func _ready() -> void:
	if not enabled:
		queue_free()
	set_level_label(1)
	set_lives_label(3)
	set_score_label(0)
	
func game_over():
	GameOver.emit(get_instance_id())

func set_lives_label(lives):
	lives_label.text = "Lives: " + str(lives)
	
func set_score_label(score):
	score_label.text = "Score: " + str(score) 

func set_level_label(level):
	level_label.text = "Level: " + str(level)

func show_game_over():
	game_over_label.show()
	
	
