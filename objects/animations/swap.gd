extends Object

var duration = 0.2

var item1
var item2
var from
var to

var timer

var parent
var ap

func _init(_item1, _item2, _from, _to, _parent):
	item1 = _item1
	item2 = _item2
	from = _from
	to = _to
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
	ap.play("swap")

func update(delta):
	pass

func done():
	timer.queue_free()
	ap.queue_free()

func setup_animation():
	var fo = parent.frame_offset
	var i_s = parent.item_size
	
	var old_pos = Vector2(fo + from.x * i_s + i_s / 2, fo + from.y * i_s + i_s / 2)
	var new_pos = Vector2(fo + to.x * i_s + i_s / 2, fo + to.y * i_s + i_s / 2)
	
	var anim = Animation.new()
	create_animation(anim, item1, old_pos, new_pos)
	create_animation(anim, item2, new_pos, old_pos)
	ap.add_animation("swap", anim)

func create_animation(anim, item, from, to):
	var t1idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t1idx, "%s:position:x" % item.get_path())
	anim.track_insert_key(t1idx, 0, from.x)
	anim.track_insert_key(t1idx, duration, to.x)
	anim.track_set_interpolation_type(t1idx, Animation.INTERPOLATION_CUBIC)
	
	var t2idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(t2idx, "%s:position:y" % item.get_path())
	anim.track_insert_key(t2idx, 0, from.y)
	anim.track_insert_key(t2idx, duration, to.y)
	anim.track_set_interpolation_type(t2idx, Animation.INTERPOLATION_CUBIC)