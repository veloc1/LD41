extends Object

var duration = 0.2

var items
var added_pos

var timer

var parent
var ap

func _init(_items, _added, _parent):
	items = _items
	added_pos = _added
	parent = _parent
	
	timer = Timer.new()
	timer.wait_time = duration
	timer.connect("timeout", parent, "on_timer_done")
	parent.add_child(timer)
	
	ap = AnimationPlayer.new()
	parent.add_child(ap)
	
	setup_animation()

func start():
	timer.start()
	ap.play("add")

func update(delta):
	pass

func done():
	timer.queue_free()
	ap.queue_free()

func setup_animation():
	var anim = Animation.new()
	
	for i in range(len(added_pos)):
		var p = added_pos[i]
		var item = items[p.x][p.y]
		create_animation(anim, item, i)
	
	ap.add_animation("add", anim)

func create_animation(anim, item, index):
	var start_time = 0 # duration * index
	var end_time = duration # duration * (index + 1)
	
	var t1idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t1idx, "%s:scale:x" % item.get_path())
	anim.track_insert_key(t1idx, start_time, 0.0)
	anim.track_insert_key(t1idx, end_time, 1.0)
	anim.track_set_interpolation_type(t1idx, Animation.INTERPOLATION_CUBIC)
	
	var t2idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t2idx, "%s:scale:y" % item.get_path())
	anim.track_insert_key(t2idx, start_time, 0.0)
	anim.track_insert_key(t2idx, end_time, 1.0)
	anim.track_set_interpolation_type(t2idx, Animation.INTERPOLATION_CUBIC)