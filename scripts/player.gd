extends Area2D

signal hit
signal shot_enemy(mob)
signal ammo_changed
@export var speed = 400
@export var ammo: int = 5
@export var shoot_range: float = 300.0
@export var bullet_scene: PackedScene
var screen_size
var facing_direction = Vector2.RIGHT

func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		facing_direction = velocity.normalized()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

	if Input.is_action_just_pressed("shoot"):
		shoot()
		
func shoot():
	if ammo <= 0:
		return
	ammo -= 1
	ammo_changed.emit(ammo)
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = facing_direction
	bullet.rotation = facing_direction.angle() + PI/2
	get_parent().add_child(bullet)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + facing_direction * shoot_range
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result and result.collider.is_in_group("mobs"):
		shot_enemy.emit(result.collider)

func _on_body_entered(body: Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	ammo = 5
