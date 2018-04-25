extends Node2D

var SpellManager = load("res://objects/spell_manager.gd")
var Fireball = load("res://objects/fireball.tscn")
var Lightning = load("res://objects/lightning.tscn")

signal cast_projectile
signal warning

var craft_panel
var craft_panel_state
var camera
var player

var spell_queue
var spell_manager

var sound_manager

var hp_bar
var hp_text
var mp_text
var mp_warning

func _ready():
	craft_panel = get_node("ui/craft")
	craft_panel_state = craft_panel.animation_state
	
	camera = get_node("player/Camera2D")
	player = get_node("player")
	
	spell_queue = get_node("ui/spell_queue")
	
	spell_manager = SpellManager.new()
	add_child(spell_manager)
	spell_manager.subscribe(self, craft_panel, player, spell_queue)
	
	sound_manager = get_node("sounds")
	
	hp_bar = get_node("ui/hp")
	hp_text = get_node("ui/hp_text")
	mp_text = get_node("ui/mp_text")
	mp_warning = get_node("ui/mp_warning")
	mp_warning.get_node("text").set_text("Empty!")
	mp_warning.hide()
	
	player.connect("player_hp_changed", self, "player_hp_changed")
	player.connect("player_mp_changed", self, "player_mp_changed")
	
	setup_sounds()
	set_process(true)

func _process(delta):
	var panel_size = 160

	if Input.is_action_pressed("m3_toggle"):
		craft_panel.toggle()

	var start_position = 320 - panel_size - 10
	var end_position = 320
	var diff = end_position - start_position

	var panel_y = (240 - panel_size) / 2

	if craft_panel_state.is_showed and not craft_panel_state.is_translating:
		craft_panel.position.x = start_position
		craft_panel.position.y = panel_y
	elif craft_panel_state.is_translating:
		var a_delta = craft_panel_state.a_delta
		var offset = diff * a_delta
		if craft_panel_state.will_close:
			craft_panel.position.x = start_position + offset
		else:
			craft_panel.position.x = end_position - offset
		craft_panel.position.y = panel_y
	else:
		craft_panel.position.x = end_position
		craft_panel.position.y = panel_y
	
	# camera work:
	# 0 - 40 = no offset
	# 40 - 260 = offset moves from 0 to 180
	# > 260 = offset = 180
	# 180 pixels - size of available zone when craft panel opened
	
	var camera_offset = (end_position - craft_panel.position.x) / 2
	if player.position.x < 40:
		camera_offset = 0
	elif player.position.x < 260:
		var x = player.position.x - 40
		var percent = x / 220.0
		camera_offset = camera_offset * percent
	
	camera.offset.x = camera_offset

func apply_spell(spell):
	var is_player_facing_right = player.is_facing_right()
	if spell.value == 0:
		var fireball = Fireball.instance()
		fireball.should_move_right(is_player_facing_right)
		if is_player_facing_right:
			fireball.position.x = player.position.x + 8
		else:
			fireball.position.x = player.position.x - 8
		fireball.position.y = player.position.y
		add_child(fireball)
		emit_signal("cast_projectile")
	elif spell.value == 1:
		var lightning = Lightning.instance()
		lightning.should_move_right(is_player_facing_right)
		if is_player_facing_right:
			lightning.position.x = player.position.x + 8
		else:
			lightning.position.x = player.position.x - 8
		lightning.position.y = player.position.y
		add_child(lightning)
		emit_signal("cast_projectile")
	elif spell.value == 2:
		player.add_hp(3)
	elif spell.value == 3:
		player.reduce_hp(1)

func player_hp_changed(new_hp):
	hp_bar.set_value(new_hp * 10)
	hp_text.set_text(str(new_hp))

func player_mp_changed(new_mp):
	mp_text.set_text(str(new_mp))
	if new_mp <= 3:
		mp_text.add_color_override("font_color", Color(1, 0, 0, 1))
	else:
		mp_text.add_color_override("font_color", Color(1, 1, 1, 1))

func mp_empty():
	mp_warning.show()
	emit_signal("warning")

func setup_sounds():
	var spider = get_node("spider")
	
	spider.connect("enemy_dead", player, "enemy_dead")
	spider.connect("enemy_hurt", sound_manager, "enemy_hurt")
	
	player.connect("player_heal", sound_manager, "player_heal")
	player.connect("player_hurt", sound_manager, "player_hurt")
	player.connect("game_over", sound_manager, "game_over")
	player.connect("player_jump", sound_manager, "jump")
	connect("cast_projectile", sound_manager, "cast_projectile")
	
	craft_panel_state.connect("craft_panel_open", sound_manager, "craft_panel_open")
	craft_panel_state.connect("craft_panel_close", sound_manager, "craft_panel_close")
	
	craft_panel.connect("m3_translate", sound_manager, "m3_translate")
	craft_panel.connect("m3_add", sound_manager, "m3_add")
	craft_panel.connect("m3_remove", sound_manager, "m3_remove")
	craft_panel.connect("m3_fall", sound_manager, "m3_fall")
	craft_panel.data.connect("m3_move", sound_manager, "m3_move")
	craft_panel.data.connect("m3_hold", sound_manager, "m3_hold")
	
	connect("warning", sound_manager, "warning")
	spell_manager.connect("spell_queue_empty", sound_manager, "warning")
	spell_manager.connect("spell_queue_full", sound_manager, "warning")
