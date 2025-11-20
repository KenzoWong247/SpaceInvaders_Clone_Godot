class_name AI_Node extends Node

@export var enabled = false
@export var websocket_uri = "ws://localhost:8001"
@onready var sub_viewport: SubViewport = $"../SubViewportContainer/SubViewport"

var socket = WebSocketPeer.new()
var count = 0
var gather_frames = true
var frame_buffer = []
var action


func _ready() -> void:
	if not enabled:
		queue_free()
	else:
		var err = socket.connect_to_url(websocket_uri)
		if err != OK:
			print("Unable to connect")
			set_process(false)
		else:
			# Wait for the socket to connect.
			await get_tree().create_timer(2).timeout

			await RenderingServer.frame_post_draw

func save_viewport_frame():
	var image = sub_viewport.get_texture().get_image()
	frame_buffer.append(image)
	
func _physics_process(_delta: float) -> void:
	if gather_frames and count < 4:
		save_viewport_frame()
		count += 1
	else:
		if action:
			Input.action_release(action)
		gather_frames = false
	
		socket.poll()
		var state = socket.get_ready_state()
		
		if state == WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				var server_data = socket.get_packet().get_string_from_utf8()
				#print("Got data from server: ", server_data)
				var parsed_data = JSON.parse_string(server_data)
				if parsed_data:
					# TODO: Pass action data to game
					_receive_data(parsed_data)
					gather_frames = true
				
		elif state == WebSocketPeer.STATE_CLOSED:
			var code = socket.get_close_code()
			print("WebSocket closed with code: " + str(code))
			_stop_computing()
		
func _send_data() -> void:
	var data = {}
	var image_data = []
	for img in frame_buffer:
		# May throw an error
		image_data.append_array(img.get_data())
	socket.send_text(JSON.stringify(data))
	frame_buffer = []
	
func _receive_data(data: Dictionary):
	if "action" in data:
		match data["action"]:
			0:
				action = "move_left"
			1:
				action = "move_right"
			2:
				action = "fire_weapon"
			3:
				action = null
		# TODO: This currently controls every game. Make it so its individualistic
		Input.action_press(action)
	else:
		action = null
		
#func wait_frames(count: int) -> void:
	#for i in count:
		#await RenderingServer.frame_post_draw
		
func _stop_computing() -> void:
		set_process(false)
		set_physics_process(false)
		gather_frames = false
		print("ML Node Processing stopped")
