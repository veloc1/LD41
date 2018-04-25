extends Sprite

var selection
var hold
var value

func _init():
	generate_value()

func _ready():
	selection = get_node("selected")
	set_selected(false)

	hold = get_node("holded")
	set_holded(false)
	
	show_value_image()

	set_process(true)

func _process(delta):
	pass

func rand_value():
	generate_value()
	show_value_image()

func generate_value():
	value = int(rand_range(0, 4))

func show_value_image():
	for i in range(4):
		get_node(str(i)).hide()
	get_node(str(value)).show()

func set_selected(selected):
	if selected:
		selection.show()
	else:
		selection.hide()

func set_holded(holded):
	if holded:
		hold.show()
	else:
		hold.hide()