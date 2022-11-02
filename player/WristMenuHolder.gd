extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var hand_vector = -transform.basis.x
	var angle = hand_vector.dot(Vector3.UP)
	if angle > .90:
		visible = true
	else:
		visible = false
