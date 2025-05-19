extends Node2D

@export var speed : float = 0.15
@export var width : int = 8
@export var height : int = 8

@onready var tmls : MazeLayer = $VBoxContainer/SubViewportContainer


var maze : Maze
var runfunc : bool = true
var moveForward : bool = false
var currentTime : float = 0.0
var tmpdump : bool = false


var funcGlobalVars : Dictionary = {
	"var1" : 0,
	"forloop-val" : [1, 2, 3, 4],
	"forloop-idx" : 0
	}


func _ready() -> void:
	maze = Maze.new()
	maze.buildBazeMaze(width, height)
	maze.debugNoRandom = true
	
	tmls.init_tml(width, height)
	


func _process(delta: float) -> void:
	currentTime += delta
	moveForward = false
	
	if currentTime >= speed:
		moveForward = true
		currentTime = 0.0
	
	if runfunc == true:
		#if demoFuncSteps(moveForward) == true:
		#	runfunc = false
		runfunc = !maze.GenerateTWMaze_GrowingTree_interactive(moveForward, Maze.PickMethod.Newest)
		$VBoxContainer/HBoxContainer/CurrentCell.text = str(maze.interactiveMazeData["currentCell"])
		$VBoxContainer/HBoxContainer/PrevCell.text = str(maze.interactiveMazeData["previousCell"])
		$VBoxContainer/HBoxContainer/Cell.text = str(maze.maze[maze.interactiveMazeData["previousCell"].x][maze.interactiveMazeData["previousCell"].y])
		
		#~skip colouring and end of function call when no more unvisited cells exists
		tmls.set_cell(maze.interactiveMazeData["currentCell"], 0, Vector2i(1,0))
		#draw walls carved after each step
		
		# here only backtracking, when pick a previously selected cell/fully processed cell
		#tmls.set_cell(maze.interactiveMazeData["previousCell"], 0, Vector2i(2,0))
	else:
		if tmpdump == false:
			maze.dumpMaze() #do it once
			tmpdump = true



func demoFuncSteps(step : bool = false) -> bool:
	var theend : bool = false
	
	if step == true:
		print("check stepLoop")
		if funcGlobalVars["var1"] < 10:
			print("v1="+str(funcGlobalVars["var1"]))
			if (funcGlobalVars["forloop-idx"] < funcGlobalVars["forloop-val"].size()):
				print("fv="+str(funcGlobalVars["forloop-val"][funcGlobalVars["forloop-idx"]]))
				funcGlobalVars["forloop-idx"] += 1
			else:
				print("reset inner for loop, inc whileloop var")
				funcGlobalVars["forloop-idx"] = 0
				#print("fv2="+str(funcGlobalVars["forloop-val"][funcGlobalVars["forloop-idx"]]))
				#funcGlobalVars["forloop-idx"] += 1
				funcGlobalVars["var1"] += 1
		else:
			print("stepLoop end")
			theend = true
		
	return theend


func _on_start_pressed() -> void:
	runfunc = true


func _on_pause_pressed() -> void:
	runfunc = false
