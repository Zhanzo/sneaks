extends Bullet
class_name PlayerBullet


func _on_PlayerBullet_body_entered(body: PhysicsBody2D) -> void:
	body.hurt(_damage)
	queue_free()
