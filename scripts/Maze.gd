extends Node
class_name  Maze

# More information about GrowingTree algorithm used there :
# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm

# ISSUE: size> 22x22 (25x25 for instance) closed cells appears
# start at 23x23, just a few cells
# not happen with base ruby algorithm
# => to help = do animated rendering, maybe just use visited cells array


enum PickMethod { Newest, Oldest, Random, Cyclic, Kitt, Collapse }
enum Direction  { North = 0x1, West = 0x2, South = 0x4, East = 0x8 }
#enum OppositeDirection  { South = 0x1, East = 0x2, North = 0x4, West = 0x8 }

var maze : Array
var generated : bool = false
var origin : Vector2i = Vector2i(-1, -1)
var cyclePick : int = -1
var kittCycle : bool = true # true = increase, false = decrease
var visited_cells : Array[Vector2i] = []


@export var width : int
@export var height : int
@export var pickMethod : int
@export var debugEnabled : bool = false


func buildBazeMaze(_width : int, _height : int, _pickmethod : int = PickMethod.Newest) -> void:
	
	width = _width
	height = _height
	pickMethod = _pickmethod

	maze.resize(_width)
	for idx in range(0, _width):
		maze[idx] = []
		maze[idx].resize(_height)
		maze[idx].fill(0)

	debug("maze="+str(maze))


func GenerateTWMaze_GrowingTree(pmethod : int = PickMethod.Newest) -> void:
	var cells : Array[Vector2i] = []

	var cellPicked : Vector2i
	var index : int
	var direction : Array
	var move : Vector2i
	var position : Vector2i

	origin = Vector2i(randi_range(0, width-1), randi_range(0, height-1))
	cells.append(origin)
	visited_cells.append(origin)

	#~store cells picked, path taken
	
	debug("cells="+str(cells))
	
	var loop_count : int = 0
	
	while (cells.size() > 0 and loop_count < 1000):
		loop_count += 1
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
	print("visisted cells="+str(visited_cells))
	debug("loopcount="+str(loop_count))
	print("maze="+str(maze))


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
			index = randi_range(0, maxIdx - 1)
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

	for x in range(0, width):
		printraw("M["+str(x)+"]=")
		for y in range(0, height):
			#print(" "+ str(maze[x][y]) +" ")
			mazeLine += " "+str(maze[x][y])
			
		print(mazeLine)
		mazeLine = ""


func lineToBlock() -> Array:
	var blockMaze : Array = []
	
	if maze == null or width <= 1 or height <= 1:
		print("Invalid maze data !")

	blockMaze.resize(2 * width + 1)
	
	for widx in range (0, 2 * width + 1):
		blockMaze[widx] = []
		blockMaze[widx].resize(2 * height + 1)
		blockMaze[widx][0] = 1

	blockMaze[0].fill(1)

	for widx in range (0, width):
		for hidx in range (0, height):
			blockMaze[2 * widx + 1][2 * hidx + 1] = 0

			if maze[widx][hidx] & Direction.East != 0:
				blockMaze[2 * widx + 2][2 * hidx + 1] = 0
			else:
				blockMaze[2 * widx + 2][2 * hidx + 1] = 1

			if maze[widx][hidx] & Direction.South != 0:
				blockMaze[2 * widx + 1][2 * hidx + 2] = 0
			else:
				blockMaze[2 * widx + 1][2 * hidx + 2] = 1

			blockMaze[2 * widx + 2][2 * hidx + 2] = 1

	#print("BM="+str(blockMaze))
	var mazeLine : String = ""
	for x in range(0, 2 * width + 1):
		printraw("BM["+str(x)+"]=")
		for y in range(0, 2 * height + 1):
			mazeLine += " "+str(blockMaze[x][y])
			
		print(mazeLine)
		mazeLine = ""
		
	return blockMaze


func debug(msg : String = "") -> void:
	if debugEnabled == true:
		print(msg)
