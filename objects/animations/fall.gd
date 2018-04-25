extends Object

var duration = 0.3
var empty_duration = 0.1

var items

var timer

var parent
var ap

func _init(_items, _parent):
	items = _items
	parent = _parent
	
	timer = Timer.new()
	if len(items) == 0:
		timer.wait_time = empty_duration
	else:
		timer.wait_time = duration
	timer.connect("timeout", parent, "on_timer_done")
	parent.add_child(timer)
	
	if len(items) != 0:
		ap = AnimationPlayer.new()
		parent.add_child(ap)
		
		setup_animation()

func start():
	timer.start()
	if len(items) != 0:
		ap.play("fall")

func update(delta):
	pass

func done():
	timer.queue_free()
	if len(items) != 0:
		ap.queue_free()

func setup_animation():
	var fo = parent.frame_offset
	var i_s = parent.item_size
	
	var anim = Animation.new()
	
	for i in range(len(items)):
		var data = items[i]
		
		var old_pos = Vector2(fo + data.old_pos.x * i_s + i_s / 2, fo + data.old_pos.y * i_s + i_s / 2)
		var new_pos = Vector2(fo + data.new_pos.x * i_s + i_s / 2, fo + data.new_pos.y * i_s + i_s / 2)
		
		create_animation(anim, data.item, old_pos, new_pos, i, items.size())
		
	ap.add_animation("fall", anim)

func create_animation(anim, item, from, to, index, total):
#	var start_time = 1.0 / total * index
#	var end_time = 1.0 / total * (index + 1)
	var start_time = 0 # duration * index
	var end_time = duration #duration * (index + 1)
	
	var t1idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t1idx, "%s:position:x" % item.get_path())
	anim.track_insert_key(t1idx, start_time, from.x)
	anim.track_insert_key(t1idx, end_time, to.x)
	anim.track_set_interpolation_type(t1idx, Animation.INTERPOLATION_CUBIC)
	
	var t2idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t2idx, "%s:position:y" % item.get_path())
	anim.track_insert_key(t2idx, start_time, from.y)
	anim.track_insert_key(t2idx, end_time, to.y)
	anim.track_set_interpolation_type(t2idx, Animation.INTERPOLATION_CUBIC)