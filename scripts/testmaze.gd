extends Node2D

var maze : Maze

#Maze2D: wall version
# use a layer like Cosmos, and drawline to make walls
# TLM => get screen coord

func _ready() -> void:
	maze = Maze.new()
	maze.buildBazeMaze(3, 3)

	maze.GenerateTWMaze_GrowingTree()

	maze.dumpMaze()
