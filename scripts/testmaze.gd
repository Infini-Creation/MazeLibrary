extends Node2D

var maze : Maze

#Maze2D: wall version
# use a layer like Cosmos, and drawline to make walls
# TLM => get screen coord

func _ready() -> void:
	maze = Maze.new()
	maze.init(888)
	maze.buildBazeMaze(10, 10, Maze.PickMethod.Random) #, 5, 3)

	maze.GenerateTWMaze_GrowingTree()

	maze.dumpMaze()
	print("1st="+str(maze.firstCell)+"  last="+str(maze.lastCell))
	var bmaze = maze.lineToBlock()
	#print("BM="+str(bmaze))
	var sbmaze = maze.scaleBlockMaze(bmaze, 3)
