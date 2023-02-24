extends TileMap

var astar = AStar2D.new() 
@onready var cells = get_used_cells(0)

func _ready():
	
	# assign unique IDs to each used cell
	for i in cells.size():
		var cell_pos = cells[i]
		astar.add_point(i, cell_pos)
		
	# connect each cell to its adjacent cells
	for i in cells.size():
		var cell_pos = cells[i]
		var neighbors = [
			cell_pos + Vector2i.RIGHT, 
			cell_pos + Vector2i.DOWN,
		]
		for neighbor_pos in neighbors:
			if cells.has(neighbor_pos):
				var neighbor_id = cells.find(neighbor_pos)
				astar.connect_points(i, neighbor_id, true)
		
func get_closest_point(position):
	return astar.get_closest_point((position) / 16)

func get_id_path(from_id, to_id):
	return astar.get_id_path(from_id, to_id)
	
func get_point_position(id):
	return local_to_map(astar.get_point_position(id))

func get_cell_position(global_position):	
	return to_global(map_to_local(global_position))

var draw_target: Vector2 = Vector2(0,0)
var draw_path: PackedVector2Array = []
func _draw():
	draw_circle(round(draw_target), 1, Color(0, 0, 0, 1))
	for pos in draw_path:
		draw_circle(pos, 1, Color(0, 0, 0, 0.8))

func find_path(start: Vector2, target: Vector2) -> PackedVector2Array:
	draw_target = target
	
	var start_cell = local_to_map(start)
	var start_id = astar.get_closest_point(start_cell)
	var target_cell = local_to_map(target)
	var target_id = astar.get_closest_point(target_cell)
	var path = astar.get_point_path(start_id, target_id)
	
	for i in path.size():
		path[i] = map_to_local(path[i])

	return path
	
func debug_path(p):
	draw_path = p
	queue_redraw()
