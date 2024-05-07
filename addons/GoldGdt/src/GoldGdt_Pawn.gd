@tool
class_name GoldGdt_Pawn extends Node3D

@export_group("Components")
@export var View : GoldGdt_View
@export var Camera : GoldGdt_Camera

@export_group("On Ready")
@export_range(-89, 89) var start_view_pitch : float = 0 ## How the vertical view of the pawn should be rotated on ready. The default value is 0.
@export var start_view_yaw : float = 0 ## How the horizontal view of the pawn should be rotated on ready. The default values is 0.

var initial_transform: Transform3D
var is_master: bool

@onready var anim_player = $AnimationPlayer
@onready var raycast = $"Interpolated Camera/Arm/Arm Anchor/Camera/Head/RayCast3D"
signal health_changed(health_value)
signal ammo_changed(ammo_value)
var health = 3
var max_ammo = 11
var current_ammo = max_ammo

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _unhandled_input(_event):
	if not is_multiplayer_authority(): return
		
	if Input.is_action_just_pressed("shoot") \
			and (anim_player.current_animation != "shoot" \
			and anim_player.current_animation != "reload"):
		raycast.force_raycast_update()
		if current_ammo > 0:
			play_shoot_effects.rpc()
			if (raycast.is_colliding()) and (raycast.get_collider() is CharacterBody3D ):
				var hit_player = raycast.get_collider()
				hit_player.get_parent().receive_damage.rpc_id(hit_player.get_multiplayer_authority())
		else:
			play_reload_effects.rpc()
	
	if Input.is_action_just_pressed("reload") \
		and current_ammo < max_ammo \
		and (anim_player.current_animation != "shoot" \
		and anim_player.current_animation != "reload"):
			play_reload_effects.rpc()
			
func _process(delta):
	if not is_multiplayer_authority(): return
	# Purely for visuals, to show you the camera rotation.
	if Engine.is_editor_hint():
		if View and Camera:
			_override_view_rotation(Vector2(deg_to_rad(start_view_yaw), deg_to_rad(start_view_pitch)))

func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		Camera.camera.current = true
	else:
		set_process(false)
		set_process_input(false)
	if is_master:
		global_transform = initial_transform
	_override_view_rotation(Vector2(deg_to_rad(start_view_yaw), deg_to_rad(start_view_pitch)))


## Forces camera rotation based on a Vector2 containing yaw and pitch, in degrees.
func _override_view_rotation(rotation : Vector2) -> void:
	if not is_multiplayer_authority(): return
	#if not is_multiplayer_authority(): return
	View.horizontal_view.rotation.y = rotation.x
	View.horizontal_view.orthonormalize()
	
	View.vertical_view.rotation.x = rotation.y
	View.vertical_view.orthonormalize()
	
	View.vertical_view.rotation.x = clamp(View.vertical_view.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	View.vertical_view.orthonormalize()
	
	Camera.global_rotation = View.camera_mount.global_rotation
	Camera.orthonormalize()

@rpc("call_local")
func play_shoot_effects():
	#var bullet_trail = _bullet_trail_prefab.instantiate();
	#var look_at_point = raycast.global_position + \
	#	(-raycast.global_transform.basis.z * 100);

	#if raycast.is_colliding():
	#	bullet_trail.max_distance = raycast.global_position.distance_to( \
	#								raycast.get_collision_point());
	#	look_at_point = raycast.get_collision_point();
	#	var collider = raycast.get_collider()
	#	if !collider is Player:
	#		var bullet_hole = _bullet_hole_prefab.instantiate()
	#		collider.add_child(bullet_hole)
	#		var pos = raycast.get_collision_point();
	#		var norm = raycast.get_collision_normal();
	#		bullet_hole.spawn(pos, norm);


	#head.add_child(bullet_trail);
	#bullet_trail.look_at(look_at_point, Vector3.UP);
	current_ammo -= 1
	anim_player.stop()
	anim_player.play("shoot")
	ammo_changed.emit(current_ammo)

@rpc("call_local")
func play_reload_effects():
	current_ammo = max_ammo
	anim_player.stop()
	anim_player.play("reload")
	ammo_changed.emit(current_ammo)

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
