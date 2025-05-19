extends Node2D
class_name Maze2D

# class to display maze with thin wall

enum WALLS { North = 1, South = 2, East = 4, West = 8 }
const ALLWALLS = WALLS.North |  WALLS.South |  WALLS.East |  WALLS.West

@onready var tlm = $MarginContainer/VBoxContainer/SubViewportContainer/SubViewport/TileMapLayer

@export var offset : Vector2i = Vector2i.ZERO
@export var maze2D : bool = true
@export var displayVCellDelay : float = 0.15

#TODO add load/save maze (in both maze class for aw data, here for button)
#TODO split 2D rendering and test scene

var maze : Maze

var screenCoord : Vector2i
var walls : Array
var tileSize : Vector2i = Vector2i(-1, -1)
var blmaze : Array
var walkTheMaze : bool = false
var timeSpent : float = 0.0
var vcidx : int = 0
var currentWalkedCell : Vector2i
var wallsToDisplay : int = 0

var wallColors : Array[Color] = [Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
var wallColorsDebug : Array[Color] = [Color.WHITE, Color.RED, Color.BLUE, Color.GREEN]


func _ready() -> void:
	maze = Maze.new()
	maze.buildBazeMaze(5, 5)
	maze.debugNoRandom = true
	maze.GenerateTWMaze_GrowingTree(Maze.PickMethod.Newest)
	#maze.maze=[[12, 9, 8], [10, 6, 3], [6, 5, 1]]
	#maze.dumpMaze()
	
	maze.debugNoRandom = true
	print("WALLS N="+str(WALLS.North)+"  S="+str(WALLS.South)+"  E="+str(WALLS.East)+"  W="+str(WALLS.West))
	offset = Vector2i(64, 64)
	
	walls = []
	walls.resize(4)
	
	if tlm != null:
		maze.debug("get tileset size")
		var tileset : TileSet = tlm.tile_set
		tileSize = tileset.tile_size
		maze.debug("TS="+str(tileSize))

		draw_maze(maze)
		
		maze.lineToBlock()
	else:
		print("ERROR: tilemap is required !")


func _process(delta: float) -> void:
	timeSpent += delta
	
	if walkTheMaze == true:
		if maze.visited_cells.size() > 0:
			if vcidx < maze.visited_cells.size():
				
				if $MarginContainer/VBoxContainer/SubViewportContainer.visible == true: #tlm.visible == true:
					tlm.set_cell(maze.visited_cells[vcidx], 1, Vector2i(1,1))
					if vcidx > 0:
						tlm.set_cell(maze.visited_cells[vcidx - 1], 1, Vector2i(0,1))

				if timeSpent >= displayVCellDelay:
					currentWalkedCell = maze.visited_cells[vcidx]
					timeSpent = 0.0
					vcidx += 1


func _draw() -> void:
	if maze2D == true:
		for x in range(0, maze.width):
			for y in range(0, maze.height):
				maze.debug("cell["+str(x)+"]["+str(y)+"]="+str(maze.maze[x][y]))
				#here add walls to an array
				for widx in range(0, 4):
					walls[widx] = [Vector2i.ZERO, Vector2i.ZERO]

				screenCoord = offset + Vector2i(tlm.map_to_local(Vector2i(x,y)))
				maze.debug("SC="+str(screenCoord))

				if maze.maze[x][y] & Maze.Direction.North == 0:
					maze.debug("carve to north")
					walls[0] = [screenCoord, screenCoord + Vector2i(tileSize.x, 0)]
					#draw_line(screenCoord, screenCoord+Vector2i(16, 0), Color.WHITE, 2.0)

				if maze.maze[x][y] & Maze.Direction.South == 0:
					maze.debug("carve to south")
					walls[1] = [screenCoord + Vector2i(0,tileSize.y), screenCoord + Vector2i(tileSize.x,tileSize.y)]
					#draw_line(screenCoord + Vector2i(16,16), screenCoord + Vector2i(16,16) + Vector2i(16, 0), Color.WHITE, 2.0)
				if maze.maze[x][y] & Maze.Direction.East == 0:
					maze.debug("carve to east")
					walls[2]= [screenCoord + Vector2i(tileSize.x, 0), screenCoord + Vector2i(tileSize.x,tileSize.y)]
				if maze.maze[x][y] & Maze.Direction.West == 0:
					maze.debug("carve to west")
					walls[3] = [screenCoord, screenCoord + Vector2i(0,tileSize.y)]
						
				for widx in range(0, 4):
					maze.debug("walls td="+str(wallsToDisplay & (1 << widx)) + "  pow="+str(1 << widx))
					if wallsToDisplay & (1 << widx) != 0:
						draw_line(walls[widx][0], walls[widx][1], wallColors[widx], 2.0)
					# ~draw_multiline with all line data
	#debug: draw each sides independantly, then combine
	# or switch buttons N/S/W/E/ALL


func draw_maze(_maze : Maze) -> void:
	queue_redraw()


func _on_button_pressed() -> void:
	print("Generate a new maze")
	walkTheMaze = false
	var width = int($MarginContainer/VBoxContainer/HBoxContainer/TextEdit.text)
	var height = int($MarginContainer/VBoxContainer/HBoxContainer/TextEdit2.text)
	var pmet = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton.selected
	maze.debug("pickmet="+str(pmet))
	if width <= 0 or width > 50:
		width = 5
	if height <= 0 or height > 50:
		height = 5
		
	maze.buildBazeMaze(width, height)
	maze.GenerateTWMaze_GrowingTree(pmet)
	$MarginContainer/VBoxContainer/SubViewportContainer.hide()
	draw_maze(maze)
	$MarginContainer/VBoxContainer/HBoxContainer/Button3.disabled = false


func _on_button_2_pressed() -> void:
	print("Generate block type maze")
	
	walkTheMaze = false

	if maze.generated == false:
		var width = int($MarginContainer/VBoxContainer/HBoxContainer/TextEdit.text)
		var height = int($MarginContainer/VBoxContainer/HBoxContainer/TextEdit2.text)
		var pmet = $MarginContainer/VBoxContainer/HBoxContainer/OptionButton.selected
		maze.buildBazeMaze(width, height)
		maze.GenerateTWMaze_GrowingTree(pmet)
	blmaze = maze.lineToBlock()
	
	$MarginContainer/VBoxContainer/SubViewportContainer.show()
	tlm.clear()

	#ISSUE: nothing displayed !
	for x in range(0, blmaze.size()):
		for y in range(0, blmaze[0].size()):
			tlm.set_cell(Vector2i(x,y), 1, Vector2i(blmaze[x][y], 0)) 


func _on_button_3_pressed() -> void:
	if maze.generated == true:
		$MarginContainer/VBoxContainer/SubViewportContainer.show()
		tlm.clear()
		walkTheMaze = true
		$MarginContainer/VBoxContainer/HBoxContainer/Button5.show()


func _on_button_4_pressed() -> void:
	tlm.hide()


func _on_button_5_pressed() -> void:
	walkTheMaze = false


func _on_wall_1_pressed() -> void:
	wallsToDisplay = WALLS.North
	maze.debug("WTD N="+str(wallsToDisplay))
	draw_maze(maze)

func _on_wall_2_pressed() -> void:
	wallsToDisplay = WALLS.South
	maze.debug("WTD S="+str(wallsToDisplay))
	draw_maze(maze)

func _on_wall_3_pressed() -> void:
	wallsToDisplay = WALLS.East
	maze.debug("WTD E="+str(wallsToDisplay))
	draw_maze(maze)

func _on_wall_4_pressed() -> void:
	wallsToDisplay = WALLS.West
	maze.debug("WTD W="+str(wallsToDisplay))
	draw_maze(maze)

func _on_walls_pressed() -> void:
	wallsToDisplay = ALLWALLS
	maze.debug("WTD A="+str(wallsToDisplay))
	draw_maze(maze)
