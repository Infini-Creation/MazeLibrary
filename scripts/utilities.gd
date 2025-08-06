extends Node
class_name Utilities

var maze : Maze

const SPREAD_THRESHOLD : float = 0.88

func spread_items(blockMaze : Array, items : int, threshold : float = SPREAD_THRESHOLD) -> Array[Vector2i]:
	var items_coordinates : Array[Vector2i]
	
	if blockMaze == null or blockMaze.size() == 0:
		return []
	if items <= 0:
		return []
	
	var remain : int = items
	var coordIdx : int = 0
	
	items_coordinates.resize(items)
	
	#~ generate N random values first to make a bit more randomness
	# OR just don't use ranGen !!
	for dummy in maze.randGen.randi_range(5, 40):
		maze.randGen.randf()

	for x in range (0, blockMaze.size()):
			for y in range (0, blockMaze[0].size()):
				if blockMaze[x][y] != 1:
					if maze.randGen.randf() > threshold:
						#print("si: randf="+str(maze.randGen.randf()))
						if remain > 0:
							items_coordinates[coordIdx] = Vector2i(x, y)
							coordIdx += 1
							remain -=1
						else:
							break
	#~count number of coords generated, if < items
	#loop again with lowered threshold (-0.02 or 0.2 for inst)

	return items_coordinates
