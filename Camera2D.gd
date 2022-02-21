extends Camera2D
const window_size = OS.window_size;
var sz = Vector2(1080,2280)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	first find width ratio
	var rat = window_size.x / sz.x
	print("RAT: ",rat)
	self.set_zoom(Vector2(1/rat,1/rat))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
