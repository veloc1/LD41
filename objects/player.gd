extends KinematicBody2D

signal game_over

signal cast_spell
signal player_heal
signal player_hurt
signal player_hp_changed
signal player_mp_changed
signal player_jump

var velocity
var sprite
var is_jumping
var hp
var mp

var can_cast
var spell_timer

func _ready():
	velocity = Vector2()
	sprite = get_node("Sprite")
	
	hp = 10
	mp = 5
	
	can_cast = true
	spell_timer = get_node("spell_timer")
	
	set_physics_process(true)
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("game_left"):
		velocity.x = -60
		sprite.flip_h = true
	elif Input.is_action_pressed("game_right"):
		velocity.x = 60
		sprite.flip_h = false
	else:
		velocity.x = 0

	if is_on_floor():
		is_jumping = false
		velocity.y = 0
	else:
		is_jumping = true
	if Input.is_action_pressed("game_up") and not is_jumping:
		velocity.y = -98 * 2.5
		is_jumping = true
		emit_signal("player_jump")
	
	if Input.is_action_pressed("game_cast_spell"):
		if can_cast:
			emit_signal("cast_spell")
			can_cast = false
			spell_timer.start()
	
	if velocity.y < 160:
		velocity.y += 10
	else:
		velocity.y = 160

func _physics_process(delta):
	move_and_slide(velocity, Vector2(0, -1))
	var collisions_count = get_slide_count()
	for c in range(collisions_count):
		var collision = get_slide_collision(c)
		handle_collision(self, collision)

func handle_collision(object, collision):
	var player = null
	var enemy = null
	var normal = null
	
	if object == self:
		player = object
		enemy = collision.collider
		normal = collision.normal
	else:
		player = collision.collider
		enemy = object
		normal = collision.normal * -1
		
	if enemy.get_collision_layer_bit(2):
		player.reduce_hp(enemy.damage)
		var bounce = normal * 15
		bounce.y = -15
		player.velocity = bounce
		player.move_and_collide(bounce)

func _on_spell_timer_timeout():
	can_cast = true

func is_facing_right():
	return not sprite.flip_h

func add_hp(a):
	hp += a
	if hp > 10:
		hp = 10
	emit_signal("player_hp_changed", hp)
	emit_signal("player_heal")

func reduce_hp(a):
	hp -= a
	if hp > 0:
		emit_signal("player_hurt")
	else:
		emit_signal("game_over")
	emit_signal("player_hp_changed", hp)

func add_mp(a):
	mp += a
	emit_signal("player_mp_changed", mp)

func reduce_mp(a):
	mp -= a
	emit_signal("player_mp_changed", mp)

func enemy_dead():
	add_mp(1)