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
		
func get_closest_point(position: Vector2):
	var cell = get_cell_position(position)
	return astar.get_closest_point(cell)

func get_id_path(from_id, to_id):
	return astar.get_id_path(from_id, to_id)
	
func get_point_position(id):
	return map_to_local(cells[id])

func get_cell_position(global_position):
	return local_to_map(global_position)

func find_path(start: Vector2, target: Vector2) -> PackedVector2Array:
	var start_cell = get_cell_position(start)
	var start_id = astar.get_closest_point(start_cell)
	var target_cell = get_cell_position(target)
	var target_id = astar.get_closest_point(target_cell)
	var path = astar.get_point_path(start_id, target_id)
	
	for i in path.size():
		path[i] = map_to_local(path[i])

	return path
