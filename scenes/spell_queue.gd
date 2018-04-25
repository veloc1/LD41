extends VBoxContainer

var Warning = load("res://objects/warning.tscn")
var warning

func spell_added(spell):
	add_child(spell)
	if warning != null:
			warning.queue_free()
			warning = null

func spell_queue_full():
	if warning == null:
		warning = Warning.instance()
		warning.get_node("text").text = "Full"
		add_child(warning)

func spell_queue_empty():
	if warning == null:
		warning = Warning.instance()
		warning.get_node("text").text = "Empty"
		add_child(warning)

func spell_cast(spell):
	if warning != null:
			warning.queue_free()
			warning = null
	var c = get_child(0)
	remove_child(c)