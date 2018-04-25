extends Object

var row
var column

class Data:
	var start
	var end
	var size
	var is_horizontal

static func is_matched(items, x, y):
	var v = items[x][y].value
	var Match = load("res://objects/match.gd")
	var m = Match.new()
	
	find_longest_match_in_row(items, x, y, v, m)
	find_longest_match_in_column(items, x, y, v, m)
	
	if m.row == null and m.column == null:
		return null
	return m

static func find_longest_match_in_row(items, x, y, v, m):
	m.row = null
	var max_row = null
	var matched = 0
	for x1 in range(x - 4, x + 4):
		if x1 < 0: # row not started
			matched = 0
			continue
		if x1 >= len(items): # end of row
			matched = 0
			continue
	
		if items[x1][y].value == v:
			matched += 1
		else:
			matched = 0
		var new_match = create_match_or_null(matched, x1, true)
		if max_row == null and new_match != null:
			max_row = new_match
		if new_match != null and new_match.size > max_row.size:
			max_row = new_match
	m.row = max_row

static func find_longest_match_in_column(items, x, y, v, m):
	m.column = null
	var max_column = null
	var matched = 0
	for y1 in range(y - 4, y + 4):
		if y1 < 0: # column not started
			matched = 0
			continue
		if y1 >= len(items[x]): # end of column
			matched = 0
			continue
	
		if items[x][y1].value == v:
			matched += 1
		else:
			matched = 0
		var new_match = create_match_or_null(matched, y1, false)
		if max_column == null and new_match != null:
			max_column = new_match
		if new_match != null and new_match.size > max_column.size:
			max_column = new_match
	m.column = max_column

static func create_match_or_null(matched, current, is_horizontal):
	var m = null
	
	if matched >= 3:
		var Match = load("res://objects/match.gd")
		m = Match.Data.new()
		m.start = current - matched + 1
		m.end = current + 1
		m.size = matched
		m.is_horizontal = is_horizontal
	
	return m