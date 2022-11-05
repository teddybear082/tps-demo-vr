class_name VRPlayer
extends Spatial

# Signal used to play audio when a hand menu button is  pressed 
signal player_menu_button_pressed

# Export variables to choose buttons used for key player actions, in theory this could be expanded to all player actions to allow for extensive controller re-mapping
export (XRTools.Buttons) var shoot_button : int = XRTools.Buttons.VR_TRIGGER
export (XRTools.Buttons) var menu_button : int = XRTools.Buttons.VR_BUTTON_BY
export (XRTools.Buttons) var arm_rotate_button : int = XRTools.Buttons.VR_BUTTON_BY


onready var initial_position = $FPController.transform.origin
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

onready var xr_origin = $FPController
onready var player_model = xr_origin.get_node(@"avatar")
onready var playerbody_node = xr_origin.get_node(@"PlayerBody")
onready var shoot_from = player_model.get_node(@"Armature/Skeleton/GunBone/ShootFrom")
onready var robot_body_model = player_model.get_node(@"Armature/Skeleton/Robot_Body")
onready var fire_cooldown = $FireCooldown
onready var right_controller = xr_origin.get_node(@"RightHandController")
onready var left_controller = xr_origin.get_node(@"LeftHandController")
onready var wrist_menu_holder = $WristMenuHolder
onready var wrist_menu_scene = wrist_menu_holder.get_node(@"HandMenuViewport2Dto3D").get_scene_instance()
onready var poke = player_model.get_node("Armature/Skeleton/IndexBoneAttachment/Poke")
onready var function_pointer = right_controller.get_node("FunctionPointer")
onready var blackout_mesh = xr_origin.get_node(@"BlackoutMesh")

onready var sound_effects = $SoundEffects
onready var sound_effect_jump = sound_effects.get_node(@"Jump")
onready var sound_effect_land = sound_effects.get_node(@"Land")
onready var sound_effect_shoot = sound_effects.get_node(@"Shoot")
onready var sound_effect_step = sound_effects.get_node(@"Step")
onready var sound_effect_activate = sound_effects.get_node(@"Activate")
onready var sound_effect_menu = sound_effects.get_node(@"MenuSelect")


var player_jumping : bool = false
var arm_in_fire_position : bool = false
var tween : SceneTreeTween

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _ready():

	# Connect necessary signals
	playerbody_node.connect("player_jumped", self, "_on_player_jumped")
	right_controller.connect("button_pressed", self, "_on_right_controller_button_pressed")
	left_controller.connect("button_pressed", self, "_on_left_controller_button_pressed")
	wrist_menu_scene.connect("smooth_turn_button_pressed", self, "_on_smooth_turn_button_pressed")
	wrist_menu_scene.connect("robot_body_button_pressed", self, "_on_robot_body_button_pressed")
	wrist_menu_scene.connect("teleport_button_pressed", self, "_on_teleport_button_pressed")
	wrist_menu_scene.connect("seated_button_pressed", self, "_on_seated_button_pressed")
	wrist_menu_scene.connect("hand_menu_button_pressed", self, "_on_hand_menu_button_pressed")
	
	
	# Shrink head bone to make robot avatar's head invisible to player
	var head_bone_pose = player_model.get_node("Armature/Skeleton").get_bone_pose(7)
	var new_head_basis = head_bone_pose.basis.scaled(Vector3(0,0,0))
	player_model.get_node("Armature/Skeleton").set_bone_pose(7, Transform(new_head_basis, head_bone_pose.origin))
	player_model.get_node("Armature/Skeleton").set_bone_rest(7, Transform(new_head_basis, head_bone_pose.origin))
	
	# Change player height offset a bit to avoid compacted player avatar body
	playerbody_node.player_height_offset = 0.10
	
	
func _process(delta):
	# Fade out to black if falling out of the map. -17 is lower than
	# the lowest valid position on the map (which is a bit under -16).
	
	if xr_origin.transform.origin.y < -17:
		blackout_mesh.visible = true
		# If we're below -40, respawn (teleport to the initial position).
		if xr_origin.transform.origin.y < -40:
			xr_origin.transform.origin = initial_position
	else:
		blackout_mesh.visible = false
		pass

func _physics_process(delta):
	
	# If wrist menu activated, then activate poke function to be able to operate the hand menu with finger presses
	if wrist_menu_holder.visible == true:
		poke.set_enabled(true)
		
	else:
		poke.set_enabled(false)

func shoot():
	var bullet = preload("res://player/bullet/bullet.tscn").instance()
	get_parent().add_child(bullet)
	var shoot_transform = shoot_from.global_transform
	bullet.global_transform.origin = shoot_transform.origin
	# If we don't rotate the bullets there is no useful way to control the particles ..
	bullet.look_at(shoot_transform.origin + shoot_transform.basis.y, Vector3.UP)
	bullet.add_collision_exception_with(self)
	var shoot_particle = shoot_from.get_node("ShootParticle")
	shoot_particle.restart()
	shoot_particle.emitting = true
	var muzzle_particle = shoot_from.get_node("MuzzleFlash")
	muzzle_particle.restart()
	muzzle_particle.emitting = true
	fire_cooldown.start()
	sound_effect_shoot.play()

# Function to rotate the firing arm into position and back to hand, this tweens the rotation degrees property on a node created by the automatedavatar.gd code for Skeleton IK targets
func rotate_right_arm():
	if !arm_in_fire_position:
		
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(player_model.right_hand_target, "rotation_degrees", Vector3(0, -90, 90), 1.0)
		arm_in_fire_position = true
	
	else:
		
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(player_model.right_hand_target, "rotation_degrees", player_model.right_hand_rotation_degs, 1.0)
		arm_in_fire_position = false
		

# Implement right controller functions to shoot and change arm to shooting mode		
func _on_right_controller_button_pressed(button):
	if button == shoot_button and fire_cooldown.time_left == 0 and arm_in_fire_position == true and $WristMenuHolder.visible == false:
		shoot()
	
	if button == arm_rotate_button:
		sound_effect_activate.play()
		rotate_right_arm()
		
# Implement left controller button to have key that immediately returns to the main menu
func _on_left_controller_button_pressed(button):
	if button == menu_button:
		emit_signal("player_menu_button_pressed")			

# Play sound effect if XR Tools player body node emits the player jumped signal
func _on_player_jumped():
	player_jumping = true
	sound_effect_jump.play()
	
# Connect to the automatedavatar.gd signal that fires when a procedural step is taken to play the steps sound effect	
func _on_avatar_avatar_procedural_step_taken():
	sound_effect_step.play() 

# Connect to the hand menu signal to switch between turning modes when switched in hand menu
func _on_smooth_turn_button_pressed(button_state):
	sound_effect_menu.play()
	if button_state == true:
		right_controller.get_node("MovementTurn").turn_mode = right_controller.get_node("MovementTurn").TurnMode.SMOOTH
	else:
		right_controller.get_node("MovementTurn").turn_mode = right_controller.get_node("MovementTurn").TurnMode.DEFAULT

# Connect to the hand menu signal to toggle the robot body mesh on and off when switched in the hand menu
func _on_robot_body_button_pressed(button_state):
	sound_effect_menu.play()
	robot_body_model.visible = button_state
	
# Connect to the hand menu signal to toggle teleport / direct movement when the option is selected in the hand menu	
func _on_teleport_button_pressed(button_state):
	sound_effect_menu.play()
	left_controller.get_node("FunctionTeleport").enabled = button_state
	left_controller.get_node("MovementDirect").enabled = !button_state
	
# Connect to the hand menu signal to toggle seated vs. standing mode when the option is selected in the hand menu	
func _on_seated_button_pressed(button_state):
	sound_effect_menu.play()
	if button_state == true:
		# Move the player camera up .50 units, e.g., about a foot and a half or half a meter when seated mode on to approximate the distance a seated player is typically from standing
		playerbody_node.player_height_offset = 0.60
		# Otherwise revert to default player height offset
	else:
		playerbody_node.player_height_offset = 0.10

# Connect to hand menu signals to play the menu sound effect when a button is pressed
func _on_hand_menu_button_pressed():
	sound_effect_menu.play()
