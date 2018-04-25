extends KinematicBody2D

export(PoolVector2Array) var patrol

signal enemy_hurt
signal enemy_dead

var velocity
var current_patrol_index

var damage = 1
var offset = 30

var hp

func _ready():
	velocity = Vector2()
	
	current_patrol_index = 0
	hp = 2
	
	set_physics_process(true)

func _physics_process(delta):
	if velocity.y < 160:
		velocity.y += 10
	else:
		velocity.y = 160
	if is_on_floor():
		velocity.y = 0
	
	var dest = patrol[current_patrol_index]
	if position.x < dest.x - offset:
		velocity.x = 30
		get_node("Sprite").flip_h = true
	elif position.x > dest.x + offset:
		velocity.x = -30
		get_node("Sprite").flip_h = false
	else:
		current_patrol_index += 1
		if current_patrol_index == len(patrol):
			current_patrol_index = 0
	move_and_slide(velocity, Vector2(0, 1))
	var collisions_count = get_slide_count()
	for c in range(collisions_count):
		var collision = get_slide_collision(c)
		
		if collision.collider.get_collision_layer_bit(1):
			# it's player, it will resolve collisions
			collision.collider.handle_collision(self, collision)
		elif collision.collider.get_collision_layer_bit(3):
			# it's player projectile, apply damage to self
			handle_damage(self, collision)

func handle_damage(object, collision):
	var enemy = null
	var projectile = null
	var normal = null
	
	if object == self:
		enemy = object
		projectile = collision.collider
		normal = collision.normal
	else:
		enemy = collision.collider
		projectile = object
		normal = collision.normal * -1
	
	enemy.hp -= projectile.damage
	enemy.move_and_collide(normal * 8)
	projectile.queue_free()
	emit_signal("enemy_hurt")
	if enemy.hp <= 0:
		emit_signal("enemy_dead")
		enemy.queue_free()
	