extends SubViewportContainer
class_name MazeLayer


@onready var tml = $SubViewport/TileMapLayer
@onready var camera = $SubViewport/Camera2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass
	

func init_tml(width : int, height : int) -> void:
	tml.clear()
	
	for x in range (0, width):
		for y in range (0, height):
			tml.set_cell(Vector2i(x,y), 0, Vector2i(0,0))


func set_cell(coordinates : Vector2i, source : int, atlas : Vector2i) -> void:
	tml.set_cell(coordinates, source, atlas)
