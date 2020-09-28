extends "res://bullets/Bullet.gd"


func _on_PlayerBullet_body_entered(body):
	body.health -= damage
	body.get_node("HitAnimationPlayer").play("hurt")
	if body.health <= 0:
		body.queue_free()
	queue_free()
