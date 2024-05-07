extends MultiplayerSpawner

@onready var pawn: PackedScene = preload("res://addons/GoldGdt/Pawn.tscn")

func _init() -> void:
  spawn_function = _spawn_custom

func _spawn_custom(data) -> Node:
  var scene = pawn.instantiate()
  scene.name = str(data.peer_id)
  #scene.initial_transform = data.initial_transform
  # Lots of other helpful init things you can do here: e.g.
  scene.is_master = (multiplayer.get_unique_id() == data.peer_id)
  scene.get_node('MultiplayerSynchronizer').set_multiplayer_authority(data.peer_id)

  return scene
