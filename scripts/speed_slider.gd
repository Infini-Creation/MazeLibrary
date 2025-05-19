extends Control

@onready var SpeedValue = $"HBoxContainer/Value"

var speed : int

signal settings_updated(int)


func _ready():
	$HBoxContainer/HSlider.value = speed
	SpeedValue.text = str($HBoxContainer/HSlider.value)


func _on_h_slider_value_changed(value: float) -> void:
	SpeedValue.text = str(value)
	settings_updated.emit(value)
