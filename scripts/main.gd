extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/MarginContainer/Health/HealthBar
@onready var current_ammo = $CanvasLayer/HUD/MarginContainer/Ammo/CurrentAmmo
@onready var multiplayer_spawner = $MultiplayerSpawner

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

var levels = [preload("res://scenes/level_01.tscn")]
var spawnpoints
var rng = RandomNumberGenerator.new()

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	_choose_level()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_add_player)#.bind(_choose_spawnpoint(spawnpoints)))
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player(multiplayer.get_unique_id())#, _choose_spawnpoint(spawnpoints))

	upnp_setup()


func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	_choose_level()
	
	#enet_peer.create_client(address_entry.text, PORT)
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	
func _choose_level():
	#var level_number = rng.randi_range(0, 1)
	
	var level = levels[0].instantiate()
	level.name = "Level"
	spawnpoints = level.get_node("SpawnPoints")
	add_child(level)

func _choose_spawnpoint(points):
	var point_index = rng.randi_range(0, points.get_child_count() - 1)
	var spawnpoint
	var i = 0
	for point in points.get_children():
		if i == point_index:
			spawnpoint = point.transform
			points.remove_child(point)
			break
		i+=1
	return spawnpoint
		
func _add_player(peer_id):#, initial_transform):
	var player = multiplayer_spawner.spawn({
		'peer_id': peer_id, 
		#'initial_transform': initial_transform
		})
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		player.ammo_changed.connect(update_ammo_counter)

func _remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value

func update_ammo_counter(ammo_value):
	current_ammo.text = str(ammo_value)

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
