class_name VRPlayer
extends Spatial

signal player_menu_button_pressed
export (XRTools.Buttons) var shoot_button : int = XRTools.Buttons.VR_TRIGGER
export (XRTools.Buttons) var menu_button : int = XRTools.Buttons.VR_BUTTON_BY
export (XRTools.Buttons) var arm_rotate_button : int = XRTools.Buttons.VR_BUTTON_BY
#const DIRECTION_INTERPOLATE_SPEED = 1
#const MOTION_INTERPOLATE_SPEED = 10
#const ROTATION_INTERPOLATE_SPEED = 10

#const MIN_AIRBORNE_TIME = 0.1
#const JUMP_SPEED = 5

#var airborne_time = 100

#var orientation = Transform()
#var root_motion = Transform()
#var motion = Vector2()
#var velocity = Vector3()
var player_jumping : bool = false
var arm_in_fire_position : bool = false
var tween : SceneTreeTween

onready var initial_position = transform.origin
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

#onready var animation_tree = $AnimationTree
onready var player_model = $FPController/avatar
onready var shoot_from = player_model.get_node(@"Armature/Skeleton/GunBone/ShootFrom")
onready var robot_body_model = player_model.get_node(@"Armature/Skeleton/Robot_Body")
onready var fire_cooldown = $FireCooldown
onready var right_controller = $FPController/RightHandController
onready var left_controller = $FPController/LeftHandController
onready var wrist_menu_scene = $WristMenuHolder/HandMenuViewport2Dto3D.get_scene_instance()
onready var poke = player_model.get_node("Armature/Skeleton/IndexBoneAttachment/Poke")
onready var function_pointer = right_controller.get_node("FunctionPointer")

onready var sound_effects = $SoundEffects
onready var sound_effect_jump = sound_effects.get_node(@"Jump")
onready var sound_effect_land = sound_effects.get_node(@"Land")
onready var sound_effect_shoot = sound_effects.get_node(@"Shoot")
onready var sound_effect_step = sound_effects.get_node(@"Step")
onready var sound_effect_activate = sound_effects.get_node(@"Activate")
onready var sound_effect_menu = sound_effects.get_node(@"MenuSelect")


func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _ready():
	# Pre-initialize orientation transform.
	#orientation = player_model.global_transform
	#orientation.origin = Vector3()
	
	# Connect necessary signals
	$FPController/PlayerBody.connect("player_jumped", self, "_on_player_jumped")
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
		
	$FPController/PlayerBody.player_height_offset = 0.10
	
	
func _process(delta):
	# Fade out to black if falling out of the map. -17 is lower than
	# the lowest valid position on the map (which is a bit under -16).
	# At 15 units below -17 (so -32), the screen turns fully black.
	if $FPController.transform.origin.y < -17:
		#color_rect.modulate.a = min((-17 - transform.origin.y) / 15, 1)
		# If we're below -40, respawn (teleport to the initial position).
		if $FPController.transform.origin.y < -40:
			$FPController.transform.origin = initial_position
	else:
		# Fade out the black ColorRect progressively after being teleported back.
		#color_rect.modulate.a *= 1.0 - delta * 4
		pass

func _physics_process(delta):
	
	
	# If wrist menu activated, then activate poke function
	if $WristMenuHolder.visible == true:
		#function_pointer.enabled = true
		poke.set_enabled(true)
		
	else:
		#function_pointer.enabled = false
		poke.set_enabled(false)

func shoot():
	#var shoot_origin = shoot_from.global_transform.origin
	#var shoot_dir = -right_controller.transform.basis.z
	var bullet = preload("res://player/bullet/bullet.tscn").instance()
	get_parent().add_child(bullet)
	#bullet.global_transform.origin = shoot_origin
	# If we don't rotate the bullets there is no useful way to control the particles ..
	#bullet.look_at(shoot_origin + shoot_dir, Vector3.UP)
	#shoot_particle.restart()
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

func rotate_right_arm():
	if !arm_in_fire_position:
		
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($FPController/avatar.right_hand_target, "rotation_degrees", Vector3(0, -90, 90), 1.0)
		arm_in_fire_position = true
	
	else:
		
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($FPController/avatar.right_hand_target, "rotation_degrees", $FPController/avatar.right_hand_rotation_degs, 1.0)
		arm_in_fire_position = false
		
		
func _on_right_controller_button_pressed(button):
	if button == shoot_button and fire_cooldown.time_left == 0 and arm_in_fire_position == true and $WristMenuHolder.visible == false:
		shoot()
	
	if button == arm_rotate_button:
		sound_effect_activate.play()
		rotate_right_arm()
		
		
func _on_left_controller_button_pressed(button):
	if button == menu_button:
		emit_signal("player_menu_button_pressed")			


func _on_player_jumped():
	player_jumping = true
	sound_effect_jump.play()
	
	
func _on_avatar_avatar_procedural_step_taken():
	sound_effect_step.play() 


func _on_smooth_turn_button_pressed(button_state):
	sound_effect_menu.play()
	if button_state == true:
		right_controller.get_node("MovementTurn").turn_mode = right_controller.get_node("MovementTurn").TurnMode.SMOOTH
	else:
		right_controller.get_node("MovementTurn").turn_mode = right_controller.get_node("MovementTurn").TurnMode.DEFAULT


func _on_robot_body_button_pressed(button_state):
	sound_effect_menu.play()
	robot_body_model.visible = button_state
	
	
func _on_teleport_button_pressed(button_state):
	sound_effect_menu.play()
	left_controller.get_node("FunctionTeleport").enabled = button_state
	left_controller.get_node("MovementDirect").enabled = !button_state
	
	
func _on_seated_button_pressed(button_state):
	sound_effect_menu.play()
	if button_state == true:
		$FPController/PlayerBody.player_height_offset = 0.60
	
	else:
		$FPController/PlayerBody.player_height_offset = 0.10

func _on_hand_menu_button_pressed():
	sound_effect_menu.play()
