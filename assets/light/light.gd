extends PointLight2D

@onready var daynight: CanvasModulate = get_tree().current_scene.find_child('daynight')
@onready var energy_initial = energy
@export var flicker: bool = false

var time = 0

func _ready():
	var light = $PointLight2D
	light.energy = energy
	light.color = color
	light.scale = scale

func _process(delta):
	var color = daynight.color
	var grayValue = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
	var energyScale = 1 - grayValue / 100 * 100
	energy = energy_initial * energyScale

	if flicker:
		time += delta
		if time < 0.1:
			energy -= 0.1 * energyScale
		elif time > 0.2:
			time = 0
	
	$PointLight2D.energy = energy / 2
