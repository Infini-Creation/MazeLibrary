extends SubViewportContainer
class_name MazeLayer


@onready var tml = $SubViewport/TileMapLayer
@onready var camera = $SubViewport/Camera2D

var tilemapUpdated : bool = false
var tmptestzoom : float = 1.0

var velocity : Vector2 = Vector2.ZERO
var acceleration : float = 1000.0
var max_speed : float = 400.0
var release_falloff : float = 5.0
var velzoom : Vector2 = Vector2.ZERO


# TODO: get the center of the TM
	#get_used_rect return size IN TILE, not PX !!
#		get size of TM
#		center camera on TM
#		adjust zoom to cover all TM

func _ready() -> void:
	camera.zoom = get_zoom_to_tilemaplayer()
	#apply_camera_limits()


func _process(delta: float) -> void:
	if tilemapUpdated == true:
		camera.zoom = get_zoom_to_tilemaplayer()
		#apply_camera_limits()
		tilemapUpdated = false

	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = calculate_velocity(input_vector, delta)
	update_global_position(delta)
	var input_zoomv = Input.get_vector("ui_page_up", "ui_page_down", "ui_text_caret_line_start", "ui_text_caret_line_end")
	velzoom = calculate_velocity(input_zoomv, delta)
	#camera.zoom *= 
	#print("potzoom="+str(lerp(velzoom, Vector2.ZERO, pow(2, -64 * delta))))
	if velzoom.x != 0:
		if velzoom.x > 0:
			camera.zoom *= 1.05
		else:
			camera.zoom *= 0.95
	#tmptestzoom -= 0.001
	#camera.zoom = Vector2(tmptestzoom, tmptestzoom)

func _input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("ui_page_up"):
	#	camera.zoom *= 1.05
	#if event.is_action_pressed("ui_page_down"):
	#	camera.zoom *= 0.95
		

func init_tml(width : int, height : int) -> void:
	tml.clear()
	
	for x in range (0, width):
		for y in range (0, height):
			tml.set_cell(Vector2i(x,y), 0, Vector2i(0,0))


func tml_updated() -> void:
	tilemapUpdated = true


func set_cell(coordinates : Vector2i, source : int, atlas : Vector2i) -> void:
	tml.set_cell(coordinates, source, atlas)


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


func get_zoom_to_tilemaplayer() -> Vector2:
	var new_zoom : Vector2 = Vector2.ONE

	var viewport_size : Vector2i = get_viewport().size
	var tilemap_info : Dictionary = get_tilemaplayer_info()
	print("tml_info="+str(tilemap_info) + "  vps="+str(viewport_size))
	
	var map_size = Vector2i(tilemap_info.size * tilemap_info.tile_size)
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


func get_tilemaplayer_info() -> Dictionary:
	var tile_size : Vector2i = tml.tile_set.tile_size
	var tml_rect : Rect2i = tml.get_used_rect()
	
	print("tmlrect="+str(tml_rect)+"  RP="+str(tml_rect.position))
	print("tml gp="+str(tml.global_position))
	var tml_size = Vector2i(
		tml_rect.end.x - tml_rect.position.x, tml_rect.end.y - tml_rect.position.y
	)
	
	return {"size": tml_size, "tile_size": tile_size}

#useless here
func apply_camera_limits() -> void:
	var tilemap_info : Dictionary = get_tilemaplayer_info()
	var map_size = Vector2i(tilemap_info.size * tilemap_info.tile_size)
	
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
