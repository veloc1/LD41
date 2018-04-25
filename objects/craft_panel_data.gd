extends Object

var M3 = load("res://objects/m_item.tscn")
var Match = load("res://objects/match.gd")

enum STATE { SELECT, HOLD, MOVE, REMOVE, FALL, FILL}

var size
var items
var selected_position
var state
var display

var mp

signal m3_new_match
signal mp_empty
signal player_reduce_mp

signal m3_move
signal m3_hold

func _init(parent_display):
	display = parent_display
	size = 6
	
	var generator = Generator.new()
	items = generator.generate(size)
	
	add_childs_to_display()
	
	selected_position = Vector2(0, 0)
	set_state_to_selection()
	
	mp = 1

func set_state_to_selection():
	state = STATE.SELECT
	items[selected_position.x][selected_position.y].set_selected(true)

func add_childs_to_display():
	for x in range(size):
		for y in range(size):
			display.add_item(items[x][y], x, y)

func move(x, y):
	if state == STATE.HOLD:
		translate_element(selected_position, Vector2(x, y))
		move_selection(x, y)
		# disable selection, will enable it on selection state
		items[selected_position.x][selected_position.y].set_selected(false)
		emit_signal("player_reduce_mp", 1)
	if state == STATE.SELECT:
		move_selection(x, y)
		emit_signal("m3_move")

func translate_element(current, offset):
	if not check_translate(current, offset):
		return
	var item1 = items[current.x][current.y]
	item1.set_holded(false)
	item1.set_selected(false)
	
	var item2 = items[current.x + offset.x][current.y + offset.y]
	
	var tmp = item2
	items[current.x + offset.x][current.y + offset.y] = items[current.x][current.y]
	items[current.x][current.y] = tmp
	
	state = STATE.MOVE
	
	display.animate_translation(item1, item2, current, current + offset)

func check_translate(current, offset):
	if current.x + offset.x < 0:
		return false
	if current.x + offset.x >= size:
		return false
	if current.y + offset.y < 0:
		return false
	if current.y + offset.y >= size:
		return false
	return true

func move_selection(x, y):
	items[selected_position.x][selected_position.y].set_selected(false)
	selected_position.x += x
	selected_position.y += y
	
	limit_selected_position()
	items[selected_position.x][selected_position.y].set_selected(true)

func limit_selected_position():
	if selected_position.x < 0:
		selected_position.x = 0
	if selected_position.x > 5:
		selected_position.x = 5
	if selected_position.y < 0:
		selected_position.y = 0
	if selected_position.y > 5:
		selected_position.y = 5

func input_move(x, y):
	move(x, y)

func input_select():
	var item = items[selected_position.x][selected_position.y]
	if state == STATE.SELECT:
		if mp == 0:
			emit_signal("mp_empty")
			return
		item.set_holded(true)
		item.set_selected(false)
		state = STATE.HOLD
		emit_signal("m3_hold")
	elif state == STATE.HOLD:
		item.set_holded(false)
		item.set_selected(true)
		set_state_to_selection()
		emit_signal("m3_hold")

func update():
	pass

func animation_done():
	if state == STATE.FILL:
		state = STATE.MOVE
		#set_state_to_selection()
	if state == STATE.FALL:
		fill_items()
	if state == STATE.REMOVE:
		fall_items()
	if state == STATE.SELECT or state == STATE.HOLD or state == STATE.MOVE:
		var matched_points = check_matches()
		if matched_points.size() == 0:
			set_state_to_selection()
		else:
			remove_points(matched_points)

func check_matches():
	var to_remove = PoolVector2Array()
	for x in range(size):
		for y in range(size):
			var m = Match.is_matched(items, x, y)
			var is_match_new = false
			if m != null:
				print("Match at x: %d, y: %d" % [x, y])
				if m.row != null:
					print("Matched row: from %d to %d, total %d" % [m.row.start, m.row.end, m.row.size])
					var a = get_not_included_points(m.row, x, y, to_remove)
					if a.size() > 0:
						is_match_new = true
					to_remove.append_array(a)
				if m.column != null:
					print("Matched column: from %d to %d, total %d" % [m.column.start, m.column.end, m.column.size])
					var a = get_not_included_points(m.column, x, y, to_remove)
					if a.size() > 0:
						is_match_new = true
					to_remove.append_array(a)
			if is_match_new:
				emit_signal("m3_new_match", m, items[x][y])
	return to_remove

func get_not_included_points(m, x, y, array):
	var diff = PoolVector2Array()
	var r = range(m.start, m.end)
	if m.is_horizontal:
		for x1 in r:
			if not is_added(x1, y, array):
				diff.append(Vector2(x1, y))
	else:
		for y1 in r:
			if not is_added(x, y1, array):
				diff.append(Vector2(x, y1))
	return diff

func is_added(x, y, array):
	for a in array:
		if x == a.x and y == a.y:
			return true
	return false

func remove_points(points):
	var to_remove = Array()
	for p in points:
		var i = items[p.x][p.y]
		items[p.x][p.y] = null
		to_remove.append(i)
	
	display.animate_remove(to_remove)
	
	state = STATE.REMOVE

func fall_items():
	var moved_items = Array()
	for x in range(size):
		var falled_in_column = fall_column(x)
		for d in falled_in_column:
			moved_items.append(d)
	
	display.animate_fall(moved_items)
	state = STATE.FALL

func fall_column(x):
	var falled = Array()
	var has_falled_items = true
	while has_falled_items:
		has_falled_items = false
		var lowest_null = -1
		for y in range(size - 1, -1, -1):
			var i = items[x][y]
			if i != null and lowest_null > 0:
				var d = FallData.new()
				d.item = i
				d.old_pos = Vector2(x, y)
				d.new_pos = Vector2(x, lowest_null)
				
				items[x][lowest_null] = i
				items[x][y] = null
				
				items_to_file("tmp.txt")
				
				falled.append(d)
				has_falled_items = true
				break
			if i == null:
				if y > lowest_null:
					lowest_null = y
	return falled

func fill_items():
	var added = PoolVector2Array()
	for x in range(size):
		for y in range(size):
			if items[x][y] == null:
				var item = M3.instance()
				items[x][y] = item
				added.append(Vector2(x, y))
	
	display.animate_add(items, added)
	
	state = STATE.FILL

func items_to_file(filename):
	var file = File.new()
	file.open(filename, File.WRITE)
	var content = ""
	
	for x in range(size):
		content = ""
		for y in range(size):
			var i = items[y][x]
			if i == null:
				content += " null"
			else:
				content += " " + str(i.value)
		file.store_line(content)
	
	file.close()

func subscribe(spell_manager, player, game):
	connect("m3_new_match", spell_manager, "new_match")
	player.connect("player_mp_changed", self, "player_mp_changed")
	connect("mp_empty", game, "mp_empty")
	connect("player_reduce_mp", player, "reduce_mp")

func player_mp_changed(new_mp):
	mp = new_mp

class Generator:
	var Match = load("res://objects/match.gd")
	var M3 = load("res://objects/m_item.tscn")
	
	var items
	
	func generate(size):
		items = []
		for x in range(size):
			items.append([])
			for y in range(size):
				var item = M3.instance()
				items[x].append(item)
		
		change_matched_sequences(size)
		return items
	
	func change_matched_sequences(size):
		for x in range(size):
			for y in range(size):
				while Match.is_matched(items, x, y) != null:
					items[x][y].rand_value()

class FallData:
	var item
	var old_pos
	var new_pos
