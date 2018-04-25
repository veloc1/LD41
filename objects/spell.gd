extends Control

var value

func set_value(_value):
	value = _value

func _ready():
	for i in range(4):
		get_node(str(i)).hide()
	get_node(str(value)).show()
