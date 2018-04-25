extends Node

func enemy_hurt():
	get_node("enemy_hurt").play()

func player_heal():
	get_node("heal").play()

func player_hurt():
	get_node("player_hurt").play()

func game_over():
	get_node("game_over").play()

func jump():
	get_node("jump").play()

func cast_projectile():
	get_node("cast_projectile").play()

func craft_panel_open():
	get_node("craft_panel_open").play()

func craft_panel_close():
	get_node("craft_panel_close").play()

func m3_translate():
	get_node("m3_translate").play()

func m3_add():
	get_node("m3_add").play()

func m3_remove():
	var node = get_node("m3_remove1")
	var i = int(rand_range(0, 3))
	print (i)
	if i == 0:
		node = get_node("m3_remove1")
	elif i == 1:
		node = get_node("m3_remove2")
	elif i == 2:
		node = get_node("m3_remove3")
	node.play()

func m3_fall():
	get_node("m3_fall").play()

func m3_move():
	get_node("m3_move").play()

func m3_hold():
	get_node("m3_hold").play()

func warning():
	get_node("warning").play()
