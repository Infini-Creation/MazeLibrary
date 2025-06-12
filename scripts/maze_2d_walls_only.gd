extends SubViewportContainer
class_name MazeWallsLayer

@onready var tml = $SubViewport/TileMapLayer
@onready var camera = $SubViewport/Camera2D
@export var offset : Vector2i = Vector2i.ZERO
@export var maze : Maze

enum WALLS { North = 1, South = 2, East = 4, West = 8 }
const ALLWALLS = WALLS.North |  WALLS.South |  WALLS.East |  WALLS.West
const wallColors : Array[Color] = [Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
const wallColorsDebug : Array[Color] = [Color.WHITE, Color.RED, Color.BLUE, Color.GREEN]


var drawareaUpdated : bool = false

var walls : Array
var wallsToDisplay : int = 0
var screenCoord : Vector2i
var tileSize : Vector2i = Vector2i(-1, -1)

var velocity : Vector2 = Vector2.ZERO
var acceleration : float = 1000.0
var max_speed : float = 400.0
var release_falloff : float = 5.0
var velzoom : Vector2 = Vector2.ZERO


func _ready() -> void:
	walls = []
	walls.resize(4)
	
	maze.debug("get tileset size")
	var tileset : TileSet = tml.tile_set
	tileSize = tileset.tile_size
	maze.debug("TS="+str(tileSize))


func _draw() -> void:
	for x in range(0, maze.width):
		for y in range(0, maze.height):
			maze.debug("cell["+str(x)+"]["+str(y)+"]="+str(maze.maze[x][y]))
			#here add walls to an array
			for widx in range(0, 4):
				walls[widx] = [Vector2i.ZERO, Vector2i.ZERO]

				screenCoord = offset + Vector2i(tml.map_to_local(Vector2i(x,y)))
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
	#add circle for 1st & last cell


func draw_maze(_maze : Maze) -> void:
	queue_redraw()


func _process(delta: float) -> void:
	if drawareaUpdated == true:
		camera.zoom = get_zoom_to_drawarea()
		#apply_camera_limits()
		drawareaUpdated = false

	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = calculate_velocity(input_vector, delta)
	update_global_position(delta)
	var input_zoomv = Input.get_vector("ui_page_up", "ui_page_down", "ui_text_caret_line_start", "ui_text_caret_line_end")
	velzoom = calculate_velocity(input_zoomv, delta)
	#camera.zoom *= 
	#print("potzoom="+str(lerp(velzoom, Vector2.ZERO, pow(2, -64 * delta))))
	if velzoom.x != 0:
		if velzoom.x > 0:
			camera.zoom *= 1.02
		else:
			camera.zoom *= 0.98



func calculate_velocity(direction : Vector2, delta : float) -> Vector2:
	var _velocity = direction * acceleration * delta
	if direction.x == 0:
		_velocity.x = lerpf(0.0, _velocity.x, pow(2.0, - release_falloff * delta))
		#velocity.x = lerpf(velocity.x, 0.0, release_falloff * delta)
	if direction.y == 0:
		_velocity.y = lerpf(0.0, _velocity.y, pow(2.0, - release_falloff * delta))

	_velocity.x = clampf(_velocity.x, -max_speed, max_speed)
	_velocity.y = clampf(_velocity.y, -max_speed, max_speed)

	return _velocity


func get_zoom_to_drawarea() -> Vector2:
	var new_zoom : Vector2 = Vector2.ONE

	var viewport_size : Vector2i = get_viewport().size
	var area_info : Dictionary = {} #get_tilemaplayer_info()
	print("tml_info="+str(area_info) + "  vps="+str(viewport_size))
	
	var map_size = Vector2i(area_info.size * area_info.tile_size)
	print("mapsize="+str(map_size))
	
	camera.position = map_size / 2
	print("new campos="+str(camera.position))
	#pos here ok, but zoom not, to much into tml
	
	var viewport_aspect : float = float(viewport_size.x) / viewport_size.y
	var map_aspect : float = float(map_size.x) / map_size.y
	
	print("vasp="+str(viewport_aspect)+" masp="+str(map_aspect))
	
	if map_aspect > viewport_aspect:
		new_zoom.x = float(viewport_size.y) / map_size.y
	else:
		new_zoom.x = float(viewport_size.x) / map_size.x

	new_zoom.y = new_zoom.x
	print("NZ="+str(new_zoom))

	new_zoom *= 0.30
	# limit zoom to avoid map become too small !
	#new_zoom.x = clamp(new_zoom.x, 0.75, 1.5)
	#new_zoom.y = clamp(new_zoom.y, 0.75, 1.5)
	print("NZc="+str(new_zoom))
	return new_zoom


func apply_camera_limits() -> void:
	var area_info : Dictionary = {} ##get_tilemaplayer_info()
	var map_size = Vector2i(area_info.size * area_info.tile_size)
	
	camera.limit_left = -100
	camera.limit_top = -100
	camera.limit_right = map_size.x
	camera.limit_bottom = map_size.y


func get_viewport_to_zoom_scale() -> Vector2i:
	var zoomed_viewport_size = Vector2i(get_viewport().size.x / camera.zoom.x, get_viewport().size.y / camera.zoom.y)
	return zoomed_viewport_size


func update_global_position(delta : float) -> void:
	camera.global_position += lerp(velocity, Vector2.ZERO, pow(2, -64 * delta))
	
	var zoomed_viewport_size = get_viewport_to_zoom_scale()
	var left_limit = camera.limit_left
	var right_limit = camera.limit_right - zoomed_viewport_size.x
	var top_limit = camera.limit_top
	var bottom_limit = camera.limit_bottom - zoomed_viewport_size.y
	
	camera.global_position.x = clamp (camera.global_position.x, left_limit, right_limit)
	camera.global_position.y = clamp (camera.global_position.y, top_limit, bottom_limit)
	#print("new camera gp="+str(camera.global_position))
