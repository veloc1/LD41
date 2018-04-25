extends Node

signal spell_added
signal spell_queue_full
signal spell_queue_empty
signal spell_queue_size_changed
signal spell_cast

var Spell = load("res://objects/spell.tscn")

var is_m3_opened
var spells

func _ready():
	spells = []

func subscribe(game, craft_panel, player, spell_queue):
	craft_panel.subscribe(self, player, game)
	
	connect("spell_added", spell_queue, "spell_added")
	connect("spell_queue_full", spell_queue, "spell_queue_full")
	connect("spell_queue_empty", spell_queue, "spell_queue_empty")
	connect("spell_cast", spell_queue, "spell_cast")
	
	player.connect("cast_spell", self, "spell_cast")
	
	connect("spell_cast", game, "apply_spell")

func new_match(m, item):
	if spells.size() >= 5:
		emit_signal("spell_queue_full")
	else:
		var spell = Spell.instance()
		spell.set_value(item.value)
		emit_signal("spell_added", spell)
		
		spells.append(spell)

func spell_cast():
	if is_m3_opened:
		pass
	else:
		if spells.size() == 0:
			emit_signal("spell_queue_empty")
		else:
			var s = spells.pop_front()
			emit_signal("spell_cast", s)

func craft_panel_visible(is_visible):
	is_m3_opened = is_visible