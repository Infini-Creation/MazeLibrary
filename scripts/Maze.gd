extends Node
class_name  Maze

# More information about GrowingTree algorithm used there :
# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm

const VERSION : int = 10000

enum PickMethod { Newest, Oldest, Random, Cyclic, Kitt, Collapse }
enum Direction  { North = 0x1, West = 0x2, South = 0x4, East = 0x8 }
#enum OppositeDirection  { South = 0x1, East = 0x2, North = 0x4, West = 0x8 }

var maze : Array
var generated : bool = false
var error : bool = false
var firstCell : Vector2i = Vector2i(-1, -1)
var lastCell : Vector2i = Vector2i(-1, -1)

var origin : Vector2i = Vector2i(-1, -1)
var cyclePick : int = -1
var kittCycle : bool = true # true = increase, false = decrease
var visited_cells : Array[Vector2i] = []

var randGen : RandomNumberGenerator

var interactiveMazeData : Dictionary = {
	"started" : false,
	"cells" : [], #Array[Vector2i]
	"cellPicked" : Vector2i.ZERO,
	"index" : 0, #int
	"direction" : [], #Array
	"move" : Vector2i.ZERO,
	"position" : Vector2i.ZERO,
	"for-directions" : null,
	"for-idx" : 8,
	"previousCell" : Vector2i.ZERO,
	"currentCell" : Vector2i.ZERO
}


@export var width : int
@export var height : int
@export var scale : int = 1
@export var pickMethod : int
@export var debugEnabled : bool = false
var debugNoRandom : bool = false

func init(rseed : int = -1) -> void:
	var randomSeed : int

	if randGen == null:
		randGen = RandomNumberGenerator.new()
	
	if rseed == -1:
		randomSeed = int(Time.get_unix_time_from_system ())
	else:
		randomSeed = rseed
	randGen.seed = randomSeed


func buildBazeMaze(_width : int, _height : int, _pickmethod : int = PickMethod.Newest, holes : int = -1, hole_radius : int = -1) -> void:
	
	var xr : int = -127
	var yr : int = -127
	var holex : int
	var holey : int
	var blockTiles : int
	
	seed(randGen.seed)

	if _width > 0 and _height > 0:
		width = _width
		height = _height
		pickMethod = _pickmethod

		maze.resize(_width)
		for idx in range(0, _width):
			maze[idx] = []
			maze[idx].resize(_height)
			maze[idx].fill(0)

		if holes > 0 and _width > 3 and _height > 3:
			for hcount in range (0, holes):
				holex = randGen.randi_range(0, _width - 1)
				holey = randGen.randi_range(0, _height - 1)
				
				maze[holex][holey] = 32
				blockTiles = randGen.randi_range(3, min(10, _width, _height))
				for btidx in range(0, blockTiles):
					while holex + xr < 0 or holex + xr >= _width:
						xr = randGen.randi_range(-hole_radius, hole_radius)
					while holey + yr < 0 or holey + yr >= _height:
						yr = randGen.randi_range(-hole_radius, hole_radius)
					maze[holex + xr][holey + yr] = 32
					
					xr = -127
					yr = -127
			
		debug("maze="+str(maze))
		print("bbm: hash="+str(hash(maze)))
	else:
		print("Invalid width and/or height value(s) : w=["+str(width)+"] h=["+str(height)+"]")
		error = true


func GenerateTWMaze_GrowingTree(pmethod : int = PickMethod.Newest) -> void:
	var cells : Array[Vector2i] = []

	var cellPicked : Vector2i
	var index : int
	var direction : Array
	var move : Vector2i
	var position : Vector2i

	if debugNoRandom == false:
		origin = Vector2i(randGen.randi_range(0, width-1), randGen.randi_range(0, height-1))
	else:
		origin = Vector2i(1, 1)

	cells.append(origin)
	firstCell = origin

	visited_cells.clear()
	visited_cells.append(origin)

	#~store cells picked, path taken
	
	debug("cells="+str(cells))
	
	while (cells.size() > 0):
		debug("loop start, cells="+str(cells.size()))
		index = chooseIndex(cells.size(), pmethod)
		cellPicked = cells[index] ##.pop_at()
		debug("cellp("+str(cells.size())+")="+str(cellPicked)+" idx="+str(index))
		
		##not these visited_cells.append(cellPicked)
		
		direction = RandomizeDirection()

		for dir : int in direction:
			debug("dir="+str(dir))
			
			move = DoAStep(dir)
			position = cellPicked + move
			debug("new pos="+str(position))
			
			debug("xy="+str(cellPicked)+"  nx,ny="+str(position))
			
			if position.x >= 0 and position.y >= 0 and position.x < width and position.y < height:
				debug("maze[nx,ny] val="+str(maze[position.x][position.y]))
				if maze[position.x][position.y] == 0:
					visited_cells.append(cellPicked)
					lastCell = cellPicked
					debug("maze["+str(cellPicked.x)+"]["+str(cellPicked.y)+"]="+str(maze[cellPicked.x][cellPicked.y])+"  dir="+str(dir))
					maze[cellPicked.x][cellPicked.y] |= dir
					debug("maze2["+str(cellPicked.x)+"]["+str(cellPicked.y)+"]="+str(maze[cellPicked.x][cellPicked.y]))
					debug("maze3["+str(position.x)+"]["+str(position.y)+"]="+str(maze[position.x][position.y])+"  oppdir="+str(OppositeDirection(dir)))
					maze[position.x][position.y] |= OppositeDirection(dir)
					debug("maze4["+str(position.x)+"]["+str(position.y)+"]="+str(maze[position.x][position.y]))
			
					cells.append(position)
					debug("cells("+str(cells.size())+")="+str(cells))
					index = -1
					debug("==break dir for loop==")
					break
				
		if index >= 0:
			debug("remove cell at:"+str(index))
			cells.remove_at(index)
			
		debug("==while loop end==")
	
	generated = true
	debug("visisted cells="+str(visited_cells))
	debug("maze="+str(maze))
	print("m: hash="+str(hash(maze)))


func GenerateTWMaze_GrowingTree_interactive(step : bool = false, pmethod : int = PickMethod.Newest) -> bool:
	var completed : bool = false

	if interactiveMazeData["started"] == false:
		debug("imaze: init")
		if debugNoRandom == false:
			origin = Vector2i(randGen.randi_range(0, width-1), randGen.randi_range(0, height-1))
		else:
			origin = Vector2i(1, 1)

		interactiveMazeData["cells"].append(origin)
		interactiveMazeData["started"] = true
	
	if step == true:
		debug("imaze: begin")
		#while (interactiveMazeData["cells"].size() > 0):
		if interactiveMazeData["cells"].size() > 0:
			debug("imaze: cells not empty ="+str(interactiveMazeData["cells"]))
			interactiveMazeData["index"] = chooseIndex(interactiveMazeData["cells"].size(), pmethod)
			interactiveMazeData["cellPicked"] = interactiveMazeData["cells"][interactiveMazeData["index"]]
			interactiveMazeData["direction"] = RandomizeDirection() ##not used
			debug("imaze: idx="+str(interactiveMazeData["index"])+" dir="+str(interactiveMazeData["direction"]))
			debug("imaze: cell picked="+str(interactiveMazeData["cellPicked"]))
			interactiveMazeData["previousCell"] = interactiveMazeData["cellPicked"]
			#after each for loop completed, update for loop var with this call

			# for loop to modify
			# dir todo, dir done, maybe move from one array to another till it's empty then cycle
			debug("imaze: fidx="+str(interactiveMazeData["for-idx"]))
			if interactiveMazeData["for-idx"] >= Direction.size():
				debug("imaze: reset dir")
				interactiveMazeData["for-directions"] = RandomizeDirection()
				interactiveMazeData["for-idx"] = 0
			
			#for dir : int in interactiveMazeData["direction"]:
			if interactiveMazeData["for-idx"] < Direction.size():
				var dir = interactiveMazeData["for-directions"][interactiveMazeData["for-idx"]]
				debug("imaze: fidx="+str(interactiveMazeData["for-idx"])+"  dir="+str(dir))
				interactiveMazeData["move"] = DoAStep(dir)
				debug("imaze: move="+str(interactiveMazeData["move"]))
				interactiveMazeData["position"] = interactiveMazeData["cellPicked"] + interactiveMazeData["move"]
				debug("imaze: pos="+str(interactiveMazeData["position"]))
				interactiveMazeData["for-idx"] += 1
			
				if interactiveMazeData["position"].x >= 0 and interactiveMazeData["position"].y >= 0 and interactiveMazeData["position"].x < width and interactiveMazeData["position"].y < height:
					debug("imaze: pos is inside the maze")
					if maze[interactiveMazeData["position"].x][interactiveMazeData["position"].y] == 0:
						debug("imaze: found an unvisited cell")
						interactiveMazeData["currentCell"] = interactiveMazeData["position"]
						maze[interactiveMazeData["cellPicked"].x][interactiveMazeData["cellPicked"].y] |= dir
						maze[interactiveMazeData["position"].x][interactiveMazeData["position"].y] |= OppositeDirection(dir)
						# unvisited cell/new cell
						interactiveMazeData["cells"].append(interactiveMazeData["position"])
						debug("imaze: set index to -1")
						interactiveMazeData["index"] = -1
						
						## break dir for loop
						interactiveMazeData["for-idx"] = 8
						debug("imaze:reset for loop idx")
				
				 #here only do that if loop has been broke OR f-idx > 3 !!!
			if interactiveMazeData["for-idx"] >= Direction.size():
				debug("imaze: end for loop, check cell index >= 0")
				if interactiveMazeData["index"] >= 0:
					debug("imaze: del cell at idx="+str(interactiveMazeData["index"]))
					interactiveMazeData["cells"].remove_at(interactiveMazeData["index"])
		
		else:
			debug("imaze: cells is empty")
			completed = true

		debug("imaze: end")

	return completed


func chooseIndex(maxIdx : int, pickmethod : int) -> int:
	var index : int = 0
	
	match(pickmethod):
		PickMethod.Newest:
			if maxIdx >= 1:
				index = maxIdx - 1
			else:
				index = 0
		PickMethod.Oldest:
			index = 0
		PickMethod.Random:
			index = randGen.randi_range(0, maxIdx - 1)
		PickMethod.Cyclic:
			cyclePick = (cyclePick + 1) % maxIdx
			index = cyclePick
		PickMethod.Kitt:
			if cyclePick < maxIdx - 1 and kittCycle == true:
				cyclePick += 1
			if cyclePick > 0 and kittCycle == false:
				cyclePick -=1
			
			index = cyclePick

			if cyclePick >= maxIdx - 1:
				kittCycle = false
			if cyclePick <= 0:
				kittCycle = true

		PickMethod.Collapse:
			index = 0 #TODO

	debug("ci: index ret="+str(index))
	return index


func RandomizeDirection() -> Array:
	var tmp : Array = Direction.values()
	
	if debugNoRandom == false:
		tmp.shuffle()
	
	debug("rd: temp dir array="+str(tmp))
	return tmp


func DoAStep(dir : int) -> Vector2i:
	var move : Vector2i = Vector2i.ZERO
	
	debug("dos in="+str(dir))
	match(dir):
		Direction.North:
			move.x = 0
			move.y = -1
		Direction.South:
			move.x = 0
			move.y = 1
		Direction.East:
			move.x = 1
			move.y = 0
		Direction.West:
			move.x = -1
			move.y = 0

	debug("dos: move="+str(move))
	return move


func OppositeDirection(dir : int) -> int:
	var oppDir : int
	
	match(dir):
		Direction.North:
			oppDir = Direction.South
		Direction.South:
			oppDir = Direction.North
		Direction.East:
			oppDir = Direction.West
		Direction.West:
			oppDir = Direction.East

	debug("od: oppdir="+str(oppDir))
	return oppDir


func dumpMaze() -> void:
	var mazeLine : String = ""

	for y in range(0, height):
		printraw("M["+str(y)+"]=")
		for x in range(0, width):
			#print(" "+ str(maze[x][y]) +" ")
			mazeLine += " "+str(maze[x][y])
			
		print(mazeLine)
		mazeLine = ""


func mhash() -> int:
	return hash(maze)

 # could use bitmap class instead
# ~block maze class on its own with blocksize as param
# "binary" simple maze could be made with bitmap class
# https://docs.godotengine.org/en/stable/classes/class_bitmap.html
func lineToBlock() -> Array:
	var blockMaze : Array = []
	
	if maze == null or width <= 1 or height <= 1:
		print("Error: Invalid maze data !")

	blockMaze.resize(2 * width + 1)
	
	for widx in range (0, 2 * width + 1):
		blockMaze[widx] = []
		blockMaze[widx].resize(2 * height + 1)
		blockMaze[widx][0] = 1

	blockMaze[0].fill(1)

	for widx in range (0, width):
		for hidx in range (0, height):
			blockMaze[2 * widx + 1][2 * hidx + 1] = 0

			#process holes here !
			if maze[widx][hidx] == 32:
				blockMaze[2 * widx + 1][2 * hidx + 1] = 2
				blockMaze[2 * widx + 2][2 * hidx + 1] = 2
				blockMaze[2 * widx + 1][2 * hidx + 2] = 2
			else:
				if maze[widx][hidx] & Direction.East != 0:
					blockMaze[2 * widx + 2][2 * hidx + 1] = 0
				else:
					blockMaze[2 * widx + 2][2 * hidx + 1] = 1

				if maze[widx][hidx] & Direction.South != 0:
					blockMaze[2 * widx + 1][2 * hidx + 2] = 0
				else:
					blockMaze[2 * widx + 1][2 * hidx + 2] = 1

			blockMaze[2 * widx + 2][2 * hidx + 2] = 1
			
			# could be on demand
			#if Vector2i(widx, hidx) == firstCell:
				#blockMaze[2 * widx + 1][2 * hidx + 1] = 2
			#elif Vector2i(widx, hidx) == lastCell:
				#blockMaze[2 * widx + 1][2 * hidx + 1] = 3


	print("BlockMaze=")
	var mazeLine : String = ""
	for x in range(0, 2 * width + 1):
		printraw("BM["+str(x)+"]=")
		for y in range(0, 2 * height + 1):
			mazeLine += " "+str(blockMaze[x][y])
			
		print(mazeLine)
		mazeLine = ""
		
	return blockMaze


func scaleBlockMaze(blockMaze : Array, _scale : int = 1) -> Array:
	var scaledMaze : Array = []
	
	if maze == null or blockMaze == null or blockMaze.size() <= 1 or blockMaze[0].size() <= 1:
		print("Error: Invalid maze data !")
	else:
		scaledMaze = []
		#Byte[,] biggerMaze = new Byte[blockmaze.GetLength(0) * Scale, blockmaze.GetLength(1) * Scale];
		scaledMaze.resize(blockMaze.size() * _scale)
		for idx in range (0, scaledMaze.size()):
			scaledMaze[idx] = []
			scaledMaze[idx].resize(blockMaze[0].size() * _scale)
		
		for x in range (0, blockMaze.size()):
			for y in range (0, blockMaze[0].size()):
				for sx in range(0, _scale):
					for sy in range(0, _scale):
						scaledMaze[x * _scale + sx][y * _scale + sy] = blockMaze[x][y]
			
			
	debug("Scaled Maze=")
	var mazeLine : String = ""
	for x in range(0, scaledMaze.size()):
		debug("BM["+str(x)+"]=", false)
		for y in range(0, scaledMaze[x].size()):
			mazeLine += " "+str(scaledMaze[x][y])
			
		debug(mazeLine)
		mazeLine = ""

	return scaledMaze


func debug(msg : String = "", newline : bool = true) -> void:
	if debugEnabled == true:
		if newline == true:
			print(msg)
		else:
			printraw(msg)
