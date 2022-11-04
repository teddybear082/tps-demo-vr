extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# If the vector that is coming out of the side of the player hand forms a close angle with the upward direction, display the wrist menu
func _physics_process(delta):
	var hand_vector = -transform.basis.x
	var angle = hand_vector.dot(Vector3.UP)
	if angle > .90:
		visible = true
	else:
		visible = false
