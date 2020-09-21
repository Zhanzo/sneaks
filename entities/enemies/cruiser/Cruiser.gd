extends "res://entities/Entity.gd"

const BULLET = preload("res://bullets/cruiser_bullet/CruiserBullet.tscn")

export (NodePath) var player_path = null
var player = null
var is_shooting = false

func _ready():
	player = get_node(player_path)
	$AnimationPlayer.play("idle")

func _physics_process(delta):
	_move()
	if not is_shooting:
		_fire()

func _move():
	velocity = Vector2.ZERO
	if player:
		var direction = position.direction_to(player.position)
		velocity = direction * speed
		rotation = direction.angle()
	velocity = move_and_slide(velocity)

func _fire():
	var bullet = BULLET.instance()
	bullet.global_position = $BulletSpawn.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	is_shooting = true
	$BulletDelay.start()

func _on_CollisionArea_area_entered(area):
	health -= area.damage
	$HitAnimationPlayer.play("hurt")
	area.queue_free()
	if (health <= 0):
		queue_free()

func _on_BulletDelay_timeout():
	is_shooting = false
