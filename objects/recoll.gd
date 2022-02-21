extends CollisionShape2D
var mult = .2
var height = 929 * mult
func rescale_bounds(target_height):
	if target_height == -1:
		self.scale = Vector2(40,1)
		self.position = Vector2(0,0)
	else:
		var ratio = target_height / height
		var displace = (height / 2) - (target_height/2)
		self.scale = Vector2(40,ratio)
		self.position = Vector2(0,-displace/mult)
#		print('a ',ratio,'  ',displace)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

