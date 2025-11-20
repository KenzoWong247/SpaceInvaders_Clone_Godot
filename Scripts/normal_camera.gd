extends Camera2D

@onready var min_zoom = 0.09
@onready var max_zoom = 0.5
@onready var zoom_speed = 0.01
@onready var dragging = false
@onready var last_mouse_pos = Vector2.ZERO
@onready var velocity = Vector2.ZERO
@onready var friction = 3.0
@onready var drag_sens = 3

func _zoom_camera(zoom_delta: float):
	set_zoom(Vector2.ONE * clamp(get_zoom().x + zoom_delta, min_zoom, max_zoom))
		
func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		_zoom_camera(zoom_speed)
	if event.is_action("zoom_out"):
		_zoom_camera(-zoom_speed)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			last_mouse_pos = event.position
			dragging = true
		else:
			dragging = false
		
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		position -= delta * drag_sens
		last_mouse_pos = event.position
