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

onready var initial_position = transform.origin
onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

#onready var animation_tree = $AnimationTree
onready var player_model = $FPController/avatar
onready var shoot_from = player_model.get_node(@"Armature/Skeleton/GunBone/ShootFrom")
onready var fire_cooldown = $FireCooldown
onready var right_controller = $FPController/RightHandController
onready var left_controller = $FPController/LeftHandController

onready var sound_effects = $SoundEffects
onready var sound_effect_jump = sound_effects.get_node(@"Jump")
onready var sound_effect_land = sound_effects.get_node(@"Land")
onready var sound_effect_shoot = sound_effects.get_node(@"Shoot")
onready var sound_effect_step = sound_effects.get_node(@"Step")
onready var sound_effect_activate = sound_effects.get_node(@"Activate")


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
	if !player_jumping:
		return
		
	if player_jumping == true:
		if $FPController/PlayerBody.on_ground == true:
			if sound_effect_land.playing == false:
				sound_effect_land.play()
			player_jumping = false
	# position our robot body based on our players head position
#	var camera_transform : Transform = $ARVRCamera.transform
#	var player_transform : Transform
#
#	# We just copy the origin
#	player_transform.origin = camera_transform.origin
#
#	# now calculate a lookat value
#	var lookat : Vector3 = camera_transform.basis.z
#	lookat.y = 0.0
#	$PlayerAnchor.transform = player_transform.looking_at(player_transform.origin + lookat.normalized(), Vector3.UP)

	# Jump/in-air logic.
	#airborne_time += delta
	#if $FPController/PlayerBody.on_ground == false:
	#	if airborne_time > 0.5:
	#		sound_effect_land.play()
	#		player_jumping = false
	#	airborne_time = 0

	#var on_air = airborne_time > MIN_AIRBORNE_TIME

	#if not on_air and player_jumping:
		#velocity.y = JUMP_SPEED
	#	on_air = true
		# Increase airborne time so next frame on_air is still true
	#	airborne_time = MIN_AIRBORNE_TIME
	#	animation_tree["parameters/state/current"] = 2
	#	sound_effect_jump.play()

	#if on_air:
	#	if (velocity.y > 0):
	#		animation_tree["parameters/state/current"] = 2
	#	else:
	#		animation_tree["parameters/state/current"] = 3
#	elif aiming:
#		# Change state to strafe.
#		animation_tree["parameters/state/current"] = 0
#
#		# Change aim according to camera rotation.
#		if camera_x_rot >= 0: # Aim up.
#			animation_tree["parameters/aim/add_amount"] = -camera_x_rot / deg2rad(CAMERA_X_ROT_MAX)
#		else: # Aim down.
#			animation_tree["parameters/aim/add_amount"] = camera_x_rot / deg2rad(CAMERA_X_ROT_MIN)
#
#		# Convert orientation to quaternions for interpolating rotation.
#		var q_from = orientation.basis.get_rotation_quat()
#		var q_to = camera_base.global_transform.basis.get_rotation_quat()
#		# Interpolate current rotation with desired one.
#		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
#
#		# The animation's forward/backward axis is reversed.
#		animation_tree["parameters/strafe/blend_position"] = Vector2(motion.x, -motion.y)
#
#		root_motion = animation_tree.get_root_motion_transform()


	#else: # Not in air or aiming, idle.
		# Convert orientation to quaternions for interpolating rotation.
#		var target = camera_x * motion.x + camera_z * motion.y
#		if target.length() > 0.001:
#			var q_from = orientation.basis.get_rotation_quat()
#			var q_to = Transform().looking_at(target, Vector3.UP).basis.get_rotation_quat()
#			# Interpolate current rotation with desired one.
#			orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))

		# Aim to zero (no aiming while walking).
		#animation_tree["parameters/aim/add_amount"] = 0
		# Change state to walk.
		#animation_tree["parameters/state/current"] = 1
		# Blend position for walk speed based on motion.
		#animation_tree["parameters/walk/blend_position"] = Vector2($FPController/PlayerBody.velocity.length(), 0)

		#root_motion = animation_tree.get_root_motion_transform()

#	# Apply root motion to orientation.
#	orientation *= root_motion
#
#	var h_velocity = orientation.origin / delta
#	velocity.x = h_velocity.x
#	velocity.z = h_velocity.z
#	velocity += gravity * delta
#	$FPController/PlayerBody.velocity = $FPController/PlayerBody.move_body(velocity)
#
#	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
#	orientation = orientation.orthonormalized() # Orthonormalize orientation.
#
#	player_model.global_transform.basis = orientation.basis


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
		$FPController/avatar.right_hand_target.rotation_degrees = Vector3(0, -90, 90)
		arm_in_fire_position = true
	else:
		$FPController/avatar.right_hand_target.rotation_degrees = $FPController/avatar.right_hand_rotation_degs
		arm_in_fire_position = false
		
		
func _on_right_controller_button_pressed(button):
	if button == shoot_button and fire_cooldown.time_left == 0 and arm_in_fire_position == true:
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
	#if sound_effect_step.playing == false:
	sound_effect_step.play() 
