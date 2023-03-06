extends CanvasModulate

@export var dayColor = Color('#ffffff') 
@export var dawnColor = Color('#9e6873')
@export var nightColor = Color('#091d3a') 

var dayHour = 6
var dawnHour = 16
var nightHour = 19
var hour = 10
var transition = 2

func _ready():
	pass # Replace with function body.

func _process(delta):
	var timeDict = Time.get_time_dict_from_system()
	hour = float(timeDict.second) / 60 * 24
	hour = 12
	if nightHour < hour || hour < dayHour:
		var weight = get_weight(hour - nightHour)
		color = dawnColor.lerp(nightColor, weight)
	elif dawnHour < hour:
		var weight = get_weight(hour - dawnHour)
		color = dayColor.lerp(dawnColor, weight)
	elif dayHour < hour:
		var weight = get_weight(hour - dayHour)
		color = nightColor.lerp(dayColor, weight)

func get_weight(hour):
	return min(abs(hour) / transition, 1)
