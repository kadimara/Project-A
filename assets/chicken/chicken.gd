extends Area2D

var speed_base: int = 32
var speed_scale: float = 1.2
var speed: float = speed_base * speed_scale

@onready var pathfinder = get_tree().current_scene.find_child('astar')
@onready var astar: AStar2D = pathfinder.astar
var path = []

var time = 0
var target: Area2D = null

func _ready():
	var id = pathfinder.get_closest_point(global_position)
#	astar.set_point_disabled(id)

func _process(delta):
	if path.size() == 0:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0
		if target:
			find_path()
		return
	var toPosition = path[0]
	position = position.move_toward(toPosition, delta * speed)
	if toPosition == position:
		path.remove_at(0)
	
	$AnimatedSprite2D.play()
	if position.direction_to(toPosition).x != 0:
		$AnimatedSprite2D.flip_h = position.direction_to(toPosition).x < 0
		
	pass

func find_path():
	var direction = position.direction_to(target.position)
	var radians = randf_range(-1, 1)
	var runDirection = direction.rotated(radians)
	path = pathfinder.find_path(position, position + runDirection * -1 * 32)
	if path.size() == 1:
		path = pathfinder.find_path(position, position + runDirection * 32) 

func take_damage(damage: int):
	pass

func _on_area_2d_area_entered(area):
	if area.name != 'player':
		return
	target = area

func _on_area_2d_area_exited(area):
	if area.name != 'player':
		return
	target = null
	pass # Replace with function body.
