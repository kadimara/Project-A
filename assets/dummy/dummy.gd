extends Area2D

@onready var pathfinder = get_tree().current_scene.find_child('astar')
@onready var astar: AStar2D = pathfinder.astar
var time = 0

func _ready():
	var id = pathfinder.get_closest_point(global_position)
	astar.set_point_disabled(id)

func take_damage(damage: int):
	$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play()
