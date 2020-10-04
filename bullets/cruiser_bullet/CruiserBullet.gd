extends Bullet
class_name CruiserBullet


func _on_CruiserBullet_body_entered(body: PhysicsBody2D) -> void:
	body.hurt(_damage)
	queue_free()
