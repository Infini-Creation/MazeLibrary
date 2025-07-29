extends Node
class_name GNode

#signal free_orphan_nodes

var cell : Vector2i
var length : int = 0

func _init() -> void:
	#var connect_res = 
	GblSignal.free_orphan_nodes.connect(_free_orphan_nodes_received)
	#connect("free_orphan_nodes", _free_orphan_nodes_received)
	#print("connect="+str(connect_res))


func _free_orphan_nodes_received() -> void:
	#print("free node: "+str(self)+" - N="+name)
	queue_free()
