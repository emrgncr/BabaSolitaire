extends KinematicBody2D
const window_size = OS.window_size;
var sz = Vector2(1080,2280)
var dragging = false
var rat = 0

var oldLocation;
var id = 0;
var faceUp = false;

var location = [-1,-1]
var bigboss;
var disp = Vector2(0,0)

func drop():
#	print(id)
	emit_signal("dropsignal",id,self.get_parent(),self)

func set_faceup(bl):
	print('gELDI , ',id)
	if bl:
		self.get_child(1).frame = id + 1
		faceUp = true
	else:
		self.get_child(1).frame = 0
		faceUp = false

func set_location(a,b):
	self.location = [a,b]

signal hodlsignal
signal dragsignal
signal dropsignal

func _ready():
	rat = window_size.x / sz.x
	oldLocation = self.get_parent().position;
	bigboss = self.get_parent().get_parent();
	connect('dragsignal',self,'_set_drag_pc')
	connect("hodlsignal",self.get_parent().get_parent(),'_change_hodl')
	connect("dropsignal",self.get_parent().get_parent(),'_check_drop')

func _process(delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.get_parent().position = Vector2(mousepos.x/rat,mousepos.y/rat) + disp

func _set_drag_pc():
	dragging = !dragging

func _on_KinematicBody2D_input_event(viewport,event,shape_idx):
	if bigboss.hodl and bigboss.activeID != id:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and !bigboss.hodl:
			#print(bigboss.get_movable(id))
#			print(self.get_child(0).process_priority)
			if self.faceUp == true:
				disp = self.get_parent().position - (event.position/rat)
				dragging = true
				emit_signal('hodlsignal',id,disp)
		elif event.button_index == BUTTON_LEFT and !event.pressed and dragging:
			dragging = false
			emit_signal('hodlsignal',id,disp)
			drop()
	elif event is InputEventScreenTouch:
		if event.pressed and event.get_index()==0:
			if dragging:
				self.get_parent().position = (event.get_position()/rat) + disp
			else:
				if self.faceUp == true and !bigboss.hodl:
					dragging = true
					disp = self.get_parent().position - (event.position/rat)
					emit_signal('hodlsignal',id,disp)
					self.get_parent().position = (event.get_position()/rat) + disp
		if !event.pressed and event.get_index() == 0 and dragging:
			dragging = false
			emit_signal('hodlsignal',id,disp)
			drop()




func _input(event):
	if bigboss.activeID != id:
		return
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var elocal = make_input_local(event)
		if Rect2(Vector2(0,0),Vector2(640*.2,929*.2)).has_point(elocal.position):
			return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and !event.pressed and dragging:
			dragging = false
			if bigboss.hodl:
				drop()
				emit_signal('hodlsignal',id,disp)
	elif event is InputEventScreenTouch:
		if !event.pressed and event.get_index() == 0 and dragging:
			dragging = false
			if bigboss.hodl:
				drop()
				emit_signal('hodlsignal',id,disp)
