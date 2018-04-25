extends Object

var duration = 0.2
var item_duration = 0.1

var items

var timer

var parent
var ap

var type

func _init(_items, _parent):
	items = _items
	parent = _parent
	
	type = int(rand_range(0, 2))
	
	timer = Timer.new()
	if type == 0:
		timer.wait_time = duration
	else:
		timer.wait_time = item_duration * len(items)
	timer.connect("timeout", parent, "on_timer_done")
	parent.add_child(timer)
	
	ap = AnimationPlayer.new()
	parent.add_child(ap)
	
	setup_animation()

func start():
	timer.start()
	ap.play("remove")

func update(delta):
	pass

func done():
	timer.queue_free()
	ap.queue_free()
	
	for i in items:
		i.queue_free()

func setup_animation():
	var anim = Animation.new()
	
	for i in range(len(items)):
		create_animation(anim, items[i], i)
	
	ap.add_animation("remove", anim)

func create_animation(anim, item, index):
	var start_time = 0
	var end_time = duration
	if type == 1:
		start_time = item_duration * index
		end_time = item_duration * (index + 1)
	
	var t1idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t1idx, "%s:scale:x" % item.get_path())
	anim.track_insert_key(t1idx, start_time, item.get_scale().x)
	anim.track_insert_key(t1idx, end_time, 0)
	anim.track_set_interpolation_type(t1idx, Animation.INTERPOLATION_CUBIC)
	
	var t2idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t2idx, "%s:scale:y" % item.get_path())
	anim.track_insert_key(t2idx, start_time, item.get_scale().y)
	anim.track_insert_key(t2idx, end_time, 0)
	anim.track_set_interpolation_type(t2idx, Animation.INTERPOLATION_CUBIC)