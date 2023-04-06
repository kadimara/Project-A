extends Camera2D

var baseSize = Vector2(240, 240)
var windowSize = DisplayServer.window_get_size()
var isShaking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var zoomValue = round(windowSize.y / baseSize.y)
	zoomValue = 4
	zoom = Vector2(zoomValue, zoomValue)
	
func _process(delta):
	if isShaking:
		shake()
	
func shake():
	offset.x = randi_range(-1, 1)
	offset.y = randi_range(-1, 1)
