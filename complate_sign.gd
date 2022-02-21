extends Node2D
const window_size = OS.window_size;
var sz = Vector2(1080,2280)
var rat;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rat = window_size.x / sz.x
var spd = 400

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y < (window_size.y/rat)/2:
		position.y += spd*delta
