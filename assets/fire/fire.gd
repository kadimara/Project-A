extends Area2D

var targets: Array = []

var time = 0
func _process(delta):
	time += delta
	if time < 1:
		return
		
	time -= 1
	if targets.size() > 0:
		for target in targets:
			target.hit()

func _on_area_entered(area: Area2D):
	if area.has_method('hit'):
		targets.push_back(area)

func _on_area_exited(area: Area2D):
	if targets.has(area):
		var index = targets.find(area)
		targets.remove_at(index)
