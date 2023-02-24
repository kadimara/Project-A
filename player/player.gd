extends Area2D

var speed_base: int = 48
var speed_scale: float = 1
var speed: float = speed_base * speed_scale
var mouse_position: Vector2
var float_position: Vector2

@onready var sync = $MultiplayerSynchronizer
@export var isMultiplayer = true 

@onready var pathfinder = get_tree().current_scene.find_child('astar')
var path = []

var directionDict = {
	Vector2(0, 0): 's',
	Vector2(0, 1): 's',
	Vector2(1, 0): 'e',
	Vector2(0, -1): 'n',
	Vector2(-1, 0): 'w'
}
var direction = Vector2(0, 0)

func _ready():
	$AnimatedSprite2D.play()
	mouse_position = position
	float_position = position
	
#	if isMultiplayer:
#		var id = name.to_int()
#		sync.set_multiplayer_authority(id)
#
#		var hasAuthority = sync.is_multiplayer_authority();
#		set_process(hasAuthority)
#		set_process_unhandled_input(hasAuthority)

func _physics_process(delta):
	animate()
	
	if path.size() == 0:
		return
		
	var toPosition = path[0]
	position = position.move_toward(toPosition, delta * speed)
	if toPosition == position:
		path.remove_at(0)
		pathfinder.debug_path(path)
		
	return

func _unhandled_input (event):
	if event is InputEventMouseButton and event.pressed:
		mouse_position = get_global_mouse_position()
		path = pathfinder.find_path(position, mouse_position)
		if path.size() > 1:
			if path[0].distance_to(path[1]) > position.distance_to(path[1]):
				path.remove_at(0)

func animate():
	if path.size() == 0:
		$AnimatedSprite2D.speed_scale = 1
		$AnimatedSprite2D.play('idle_' + directionDict[direction])
	else:
		var newDirection = sign(path[0] - position)
		if newDirection == Vector2(0, 0):
			return
		direction = sign(path[0] - position)
		$AnimatedSprite2D.speed_scale = speed_scale
		$AnimatedSprite2D.play('walk_' + directionDict[direction])

func save():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
