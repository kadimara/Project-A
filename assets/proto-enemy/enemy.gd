extends Area2D

var speed_base: int = 48
var speed_scale: float = 1
var speed: float = speed_base * speed_scale

var target: Node2D;

@onready var pathfinder = get_tree().current_scene.find_child('astar')
var path = []
var direction = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 0.5:
		time -= 0.5
		path = get_path_to_target()
		
	animate()
	if path.size() == 0:
		return
		
	var toPosition = path[0]
	position = position.move_toward(toPosition, delta * speed)
	if toPosition == position:
		path.remove_at(0)

func get_path_to_target():
	if target == null: return []
	var path: PackedVector2Array = pathfinder.find_path(position, target.position)
	
	if path.size() > 0:
		path.remove_at(path.size() - 1)
	if path.size() > 1:
		if path[0].distance_to(path[1]) > position.distance_to(path[1]):
			path.remove_at(0)
	return path

var directionDict = {
	Vector2(0, 0): 's',
	Vector2(0, 1): 's',
	Vector2(1, 0): 'e',
	Vector2(0, -1): 'n',
	Vector2(-1, 0): 'w'
}
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


func _on_area_entered(area):
	target = area
	pass # Replace with function body.
