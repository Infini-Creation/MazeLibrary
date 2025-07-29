extends Node2D

var maze : Maze

#Maze2D: wall version
# use a layer like Cosmos, and drawline to make walls
# TLM => get screen coord

func _ready() -> void:
	maze = Maze.new()
	maze.debugEnabled = true
	maze.init(888)
	maze.buildBazeMaze(10, 10, Maze.PickMethod.Kitt) #, 5, 3)

	maze.GenerateTWMaze_GrowingTree()

	maze.dumpMaze()
	print("1st="+str(maze.firstCell)+"  last="+str(maze.lastCell))
	var bmaze = maze.lineToBlock()
	#print("BM="+str(bmaze))
	var sbmaze = maze.scaleBlockMaze(bmaze, 3)
	
	var ntree : GNode = null
	ntree = GNode.new()
	ntree.cell = maze.pick_a_free_cell_in_blockmaze(bmaze)
	print("FC="+str(ntree.cell))

	ntree.name = str(ntree.cell)
	ntree.length = 1
	maze.prepare_longest_path(bmaze, ntree)
	
	var bounds = maze.get_longest_path(ntree)
	print("GLP="+str(bounds))
