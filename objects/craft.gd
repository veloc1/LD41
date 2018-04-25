extends Node2D

var CraftPanelAnimationState = load("res://objects/craft_panel_animation_state.gd")
var CraftPanelData = load("res://objects/craft_panel_data.gd")

var SwapAnimation = load("res://objects/animations/swap.gd")
var RemoveAnimation = load("res://objects/animations/remove.gd")
var FallAnimation = load("res://objects/animations/fall.gd")
var AddAnimation = load("res://objects/animations/add.gd")

signal m3_translate
signal m3_remove
signal m3_fall
signal m3_add

var animation_state

var data

var frame_offset = 8
var item_size = 24

var animation

func _ready():
	animation_state = CraftPanelAnimationState.new()
	data = CraftPanelData.new(self)

	animation = null

	set_process(true)

func _process(delta):
	animation_state.update(delta)

	handle_input()
	data.update()
	
	if animation != null:
		animation.update(delta)

func toggle():
	animation_state.toggle()

func handle_input():
	if Input.is_action_just_pressed("m3_up"):
		data.input_move(0, -1)
	if Input.is_action_just_pressed("m3_down"):
		data.input_move(0, 1)
	if Input.is_action_just_pressed("m3_left"):
		data.input_move(-1, 0)
	if Input.is_action_just_pressed("m3_right"):
		data.input_move(1, 0)

	if Input.is_action_just_pressed("m3_select"):
		if animation_state.is_showed:
			data.input_select()

func add_item(item, x, y):
	add_child(item)
	reposition_item(item, x, y)

func reposition_item(item, x, y):
	item.position = Vector2(frame_offset + x * item_size + item_size / 2, frame_offset + y * item_size + item_size / 2)

func animate_translation(item1, item2, from, to):
	animation = SwapAnimation.new(item1, item2, from, to, self)
	animation.start()
	emit_signal("m3_translate")

func animate_remove(points):
	animation = RemoveAnimation.new(points, self)
	animation.start()
	emit_signal("m3_remove")

func animate_fall(items):
	animation = FallAnimation.new(items, self)
	animation.start()
	emit_signal("m3_fall")

func animate_add(items, added_pos):
	for i in added_pos:
		var item = items[i.x][i.y]
		item.scale.x = 0
		item.scale.y = 0
		add_item(item, i.x, i.y)
	animation = AddAnimation.new(items, added_pos, self)
	animation.start()
	emit_signal("m3_add")

func on_timer_done():
	animation.done()
	animation = null
	data.animation_done()

func subscribe(spell_manager, player, game):
	data.subscribe(spell_manager, player, game)
	animation_state.subscribe(spell_manager)
