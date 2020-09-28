extends "res://bullets/Bullet.gd"


func _ready():
	$AnimationPlayer.play("idle")


func _on_CruiserBullet_body_entered(body):
	body.health -= damage
	body.get_node("HitAnimationPlayer").play("hurt")
	queue_free()
