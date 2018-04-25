extends KinematicBody2D

var damage
var velocity

func _ready():
	damage = 2
	if velocity == null:
		velocity = Vector2(0, 0)
	set_process(true)

func _process(delta):
	var collision = move_and_collide(velocity)
	if collision != null:
		if collision.collider.get_collision_layer_bit(2):
			# it's enemy, it will resolve collisions
			collision.collider.handle_damage(self, collision)
		elif collision.collider.get_collision_layer_bit(0):
			queue_free()

func should_move_right(right):
	if right:
		velocity = Vector2(8, 0)
		get_node("Sprite").flip_h = false
	else:
		velocity = Vector2(-8, 0)
		get_node("Sprite").flip_h = true