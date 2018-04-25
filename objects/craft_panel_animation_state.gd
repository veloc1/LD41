extends Object

signal craft_panel_visible
signal craft_panel_open
signal craft_panel_close

var is_showed
var is_translating
var will_close
var a_delta

func _init():
	is_showed = false
	is_translating = false
	will_close = false
	a_delta = 0

func update(delta):
	a_delta += delta * 2
	if a_delta > 1 and is_translating:
		a_delta = 1
		is_translating = false
		is_showed = not will_close
		emit_signal("craft_panel_visible", is_showed)

func toggle():
	if is_showed and not is_translating:
		is_translating = true
		will_close = true
		a_delta = 0
		emit_signal("craft_panel_close")
	elif not is_showed and not is_translating:
		is_translating = true
		will_close = false
		a_delta = 0
		emit_signal("craft_panel_open")

func subscribe(spell_manager):
	connect("craft_panel_visible", spell_manager, "craft_panel_visible")