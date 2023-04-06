extends Area2D

var speed_base: int = 48
var speed_scale: float = 1.2
var speed: float = speed_base * speed_scale
var mouse_position: Vector2
var float_position: Vector2

@onready var sync = $MultiplayerSynchronizer
@export var isMultiplayer = true 

@onready var pathfinder = get_tree().current_scene.find_child('astar')
var path = []

var healthBarSize = Vector2(10, 2)
var healthBarPosition = Vector2(-healthBarSize.x / 2, -14)
var maxHp = 5
var hp = maxHp

var directionDict = {
	Vector2(0, 0): 's',
	Vector2(0, 1): 's',
	Vector2(1, 0): 'e',
	Vector2(0, -1): 'n',
	Vector2(-1, 0): 'w'
}
var direction = Vector2(0, 0)

func _ready():
	position = Vector2(-8, -8)  + round(position / 16) * 16
	mouse_position = position
	float_position = position
	
	print($AnimatedSprite2D.sprite_frames)
	
#	if isMultiplayer:
#		var id = name.to_int()
#		sync.set_multiplayer_authority(id)
#
#		var hasAuthority = sync.is_multiplayer_authority();
#		set_process(hasAuthority)
#		set_process_unhandled_input(hasAuthority)

func _process(delta):
	animate()
	queue_redraw()
	
	if path.size() == 0:
		return
		
	var toPosition = path[0]
	position = position.move_toward(toPosition, delta * speed)
	if toPosition == position:
		path.remove_at(0)
	return

func _unhandled_input (event):
	if event is InputEventMouseButton and event.pressed:
		mouse_position = get_global_mouse_position()
		get_target(mouse_position)
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

func _draw():
	if hp < maxHp:
		var healthBarPercentage = float(hp) / float(maxHp) * healthBarSize.x
		draw_rect(Rect2(healthBarPosition, healthBarSize), Color.html('#333'))
		draw_rect(Rect2(healthBarPosition, Vector2(healthBarPercentage, healthBarSize.y)), Color.INDIAN_RED)
	
	draw_square(round(mouse_position) - position, 1, Color(0, 0, 0, 0.8))
	for pos in path:
		draw_square(pos - position, 1, Color(0, 0, 0, 0.2))

func save():
	return {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		# Vector2 is not supported by JSON
		"pos_x" : position.x,
		"pos_y" : position.y,
	}

func take_damage(damage: int):
	hp = max(0, hp - damage)
	var sprite = $AnimatedSprite2D
	var frameSpeed = 1.0 / 6
	var tween = get_tree().create_tween()
	tween.tween_property(sprite.material, "shader_parameter/opacity", 1, 0)
	tween.tween_interval(frameSpeed)
	tween.tween_property(sprite.material, "shader_parameter/opacity", 0, 0)

func draw_square(position, radius, color):
	draw_rect(Rect2(position.x - radius, position.y - radius, radius * 2, radius * 2), color)
	
func get_target(pos):
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.collide_with_bodies = false
	params.collide_with_areas = true
	params.position = pos
	var collision_objects = space.intersect_point(params, 1)
	if collision_objects:
		var target = collision_objects[0].collider
		hit_target(target)

func hit_target(target: Area2D):
	if target.has_method("take_damage"):
		target.take_damage(1)
	
