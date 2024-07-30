extends Node2D

var value: int = 10

func _ready():
	%Label.text = str(value)
