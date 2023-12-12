extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = load("res://Authentication/Authentication.tscn")

	if ServerManager.is_server():
		scene = load("res://RootScenes/MultiplayerExample.tscn")

	get_tree().get_root().call_deferred("add_child", scene.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
