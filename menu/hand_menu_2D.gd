extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal smooth_turn_button_pressed(state)
signal robot_body_button_pressed(state)
signal teleport_button_pressed(state)
signal seated_button_pressed(state)
signal hand_menu_button_pressed

onready var menu_cooldown = $MenuCooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $MenuCooldown.time_left == 0:
		for child in $Controls.get_children():
			if child is Button:
				child.disabled = false
	
	else:
		for child in $Controls.get_children():
			if child is Button:
				child.disabled = true

func _on_Controls_pressed():
	$Main.visible = false
	$Controls.visible = true
	emit_signal("hand_menu_button_pressed")

func _on_Exit_pressed():
	get_tree().quit()



func _on_RobotBodyCheckButton_toggled(button_pressed):
	emit_signal("robot_body_button_pressed", button_pressed)
	$MenuCooldown.start()

func _on_TeleportCheckButton_toggled(button_pressed):
	emit_signal("teleport_button_pressed", button_pressed)
	$MenuCooldown.start()

func _on_SeatedModeCheckButton_toggled(button_pressed):
	emit_signal("seated_button_pressed", button_pressed)
	$MenuCooldown.start()

func _on_SmoothTurnCheckButton_toggled(button_pressed):
	emit_signal("smooth_turn_button_pressed", button_pressed)
	$MenuCooldown.start()

func _on_BackButton_pressed():
	$Controls.visible = false
	$Main.visible = true
