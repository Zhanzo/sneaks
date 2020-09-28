extends RigidBody2D

export (int) var health = 0
export (int) var damage = 0
export (int) var engine_thrust = 0
export (int) var spin_thrust = 0

var thrust = Vector2.ZERO
var rotation_direction = 0
var is_shooting = false

var screen_size

enum {IDLE, FORWARD, LEFT, RIGHT};

var state_strings = {
	IDLE: "idle",
	FORWARD: "forward",
	LEFT: "left",
	RIGHT: "right",
}

func _ready():
	screen_size = get_viewport().get_visible_rect().size


func handle_out_of_bounds(state):
	var xform = state.get_transform()
	if xform.origin.x > screen_size.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screen_size.x
	if xform.origin.y > screen_size.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screen_size.y
	state.set_transform(xform)


func _on_BulletDelay_timeout():
	is_shooting = false
