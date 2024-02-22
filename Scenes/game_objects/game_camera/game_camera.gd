extends Camera2D

var targer_position = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	aquire_targert()
	global_position = global_position.lerp(targer_position, 1.0 - exp(-delta * 20))
	
	
func aquire_targert():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		targer_position = player.global_position


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					zoom += Vector2(.5,.5)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom - Vector2(.5,.5) <= Vector2.ZERO:
					return
				else:
					zoom -= Vector2(.5,.5)
