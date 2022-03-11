extends Node2D

var card_template = preload('res://objects/kart.tscn');
#var won_sign = preload('res://wonsign.tscn')
var won_sign = preload('res://autocomplate_button.tscn')
var deck_position = Vector2(960,200)
var ace_pos = []
var ace_vals = [-1,-1,-1,-1]
var ace_classes = [0,1,2,3]
var board_pos = []
var deck = []
var open = []
var boards = [[],[],[],[],[],[],[]]
var hodl = false
var activeID = -1
var deck_clicker : Node2D
var text_font:Font
var states = []
var appended = true
var is_autocomplating = false
var autocomplate_info = [-1,-1,-1,false,0,[]]



func make_state():
	var openfaceup = []
	for i in self.open:
		if self.get_node(str(i)) != null:
			openfaceup.append(i)
	var board_faceup = [[],[],[],[],[],[],[]]
	for i in len(self.boards):
		for j in len(self.boards[i]):
			var n = self.get_node(str(self.boards[i][j]))
			board_faceup[i].append(n.get_child(0).faceUp)
	return {
		'ace_vals':self.ace_vals.duplicate(),
		'deck':self.deck.duplicate(),
		'open':self.open.duplicate(),
		'boards':self.boards.duplicate(true),
		'openfaceup':openfaceup,
		'boardfaceup':board_faceup,
	}
func apply_state(state):
#	print("stateeee  ",state)
	var childs = self.get_children();
	for i in childs:
		if i.name.substr(0,1).is_valid_integer():
			self.remove_child(i)
	self.ace_vals = state['ace_vals']
	self.deck = state['deck']
	self.open = state['open']
	self.boards = state['boards']
	
	for i in range(4):
		if ace_vals[i] > -1:
			var id = generate_card_id(ace_vals[i],i)
			spawn_card(ace_pos[i],id,true)
	var count = 0
#	state['openfaceup'].invert()
	var l = len(state['openfaceup'])
	for k in len(state['openfaceup']):
		var i = state['openfaceup'][k]
		var nn = spawn_card(deck_position + Vector2(-140,0) + Vector2(-70*(l-count-1),0),i,true)
		if k != len(state['openfaceup']) -1:
			nn.get_child(0).input_pickable = false
		count += 1
	for i in len(boards):
		for j in len(boards[i]):
			var ti = boards[i]
			var tj = ti[j]
			spawn_card(board_pos[i] + Vector2(0,50*j),tj,state['boardfaceup'][i][j])
	update_prio_all()
	update_draw_order()
func push_state():
	var st = make_state()
	if st.hash() == states.back().duplicate(true).hash(): 
		print('abc')
		print(states)
		return
	if len(states) > 10:
		states.pop_front()
	states.append(st)
	print(states)



#var cards = {}
enum{
	SINEK,
	KUPA,
	KARO,
	MACA
}
enum {
	KIRMIZI,
	SIYAH
}




func get_card_from_id(id):
	id = id + 1
	var num = int((id-1)/4)
	var cls = (id - 1) % 4
	var renk
	if cls == 0 or cls == 3:
		renk = SIYAH
	else:
		renk = KIRMIZI
	return [num,cls,renk]
func generate_card_id(val,cls):
	var id = 0;
	id += 4*(val)
	id += cls
	return id
func spawn_card(position,idd,face_up):
	var new_card = card_template.instance()
	new_card.position = position
	new_card.name = str(idd)
	new_card.get_child(0).id = idd
	if face_up:
		new_card.get_child(0).get_child(1).frame = idd + 1
	else:
		new_card.get_child(0).get_child(1).frame = 0
	new_card.get_child(0).faceUp = face_up
	self.add_child(new_card)
	return new_card



func _on_deck_clicked(viewport,event,shape_idx):#( (event is InputEventScreenTouch and event.get_index() == 0) or
	if  (event is InputEventMouseButton and event.button_index == BUTTON_LEFT)  and !event.pressed:
		if len(deck) > 1:
			_open_top_card()
		elif len(deck) == 1:
			_open_top_card()
			deck_clicker.get_child(0).get_child(0).visible = false
		else:
			_remake_deck()
			deck_clicker.get_child(0).get_child(0).visible = true
	self.update()


func _open_top_card():
	if is_autocomplating: return
	push_state()
	if len(open) > 2:
		var count = 0
		for i in len(open):
			var n = self.get_node(str(open[i]))
			if n == null:
				continue
			else:
				count += 1
		if count >= 3:
			for i in len(open):
				var n = self.get_node(str(open[i]))
				if n == null:
					continue
				else:
					self.remove_child(n)
					break
	for i in len(open):
#		print(open)
		var n = self.get_node(str(open[i]))
		if n == null:
			continue
#		print(n.position)
		n.position = n.position + Vector2(-70,0)
		n.get_child(0).input_pickable = false # only top card can be used
	var ida = deck.pop_front()
	var new_card = card_template.instance()
	new_card.position = deck_position + Vector2(-140,0)
	new_card.name = str(ida)
	new_card.get_child(0).id = ida
	new_card.get_child(0).get_child(1).frame = ida + 1
	new_card.get_child(0).faceUp = true
	self.add_child(new_card)
	open.append(ida)
#	push_state()

func _remake_deck():
	push_state()
	for i in open:
		var n = self.get_node(str(i))
		if n != null:
			self.remove_child(n)
	deck = open.duplicate()
#	deck.invert()
	open = []
#	push_state()



func _false_drop(id,_active,_body):
	var flag:bool = false
	for p in len(boards):
		var i = boards[p]
		if id in i:
			flag = true
#			print(id,i)
			var j = i.find(id,0)
			for t in range(j,len(i)):
				var n = self.get_node(str(i[t]))
				n.position = board_pos[p] + Vector2(0,50*t)
			break
	if not flag:
		if id in open:
			_active.position = deck_position + Vector2(-(140 + (70*(len(open) - 1 -open.find(id,0)))),0)
		else:
			var ccar = get_card_from_id(id)
			if ccar[0] == ace_vals[ccar[1]]:
				_active.position = ace_pos[ccar[1]]
	update_draw_order()


func _ace_drop(id,active,body,acepos):
	print('ACE DROPP')
	if ace_vals[acepos] >= 0:
		active.position = ace_pos[acepos]
		print('to remove  ',generate_card_id(ace_vals[acepos],ace_classes[acepos]))
		var nn = self.get_node(str(generate_card_id(ace_vals[acepos],ace_classes[acepos])))
		print('NNN   ',nn)
		self.remove_child(nn)
		ace_vals[acepos] += 1
	else:
		active.position = ace_pos[acepos]
		ace_vals[acepos] += 1
#	push_state()


func _true_drop(id,active,body,board):
	push_state()
	if board < 0:
		print('BOARD < 0   ',board)
		for p in len(boards):
			var i = boards[p]
			if id in i:
				if len(i) > 0 and i[-1] == id:
					boards[p].pop_back()
					_ace_drop(id,active,body,-board - 1)
					print('BP ',boards[p])
					if len(boards[p])> 0:
						var dond = boards[p][len(boards[p])-1]
						print('DONDD  ',dond)
						var n = self.get_node(str(dond))
						n.get_child(0).set_faceup(true)
					update_prio_all()
#					push_state()
					return
				else:
					_false_drop(id,active,body)
					return
				break
		if id in open:
			var lc = open.find(id,0)
			open.remove(lc)
			if lc != 0:
				var a = 0
				for mc in open.slice(0,lc-1):
					a +=1
					var n = self.get_node(str(mc))
					if n == null:
						continue
					if a == lc:
						n.get_child(0).input_pickable=true
					n.position += Vector2(70,0)
			_ace_drop(id,active,body,-board - 1)
#			push_state()
			return
	else:
		var nl = len(boards[board])
		var flag:bool = false
		for p in len(boards):
			var i = boards[p]
			if id in i:
				flag = true
#				print(id,i)
				if p == board:
					_false_drop(id,active,body)
					return
				var j = i.find(id,0)
				for t in range(j,len(i)):
					var n = self.get_node(str(i[t]))
					n.position = board_pos[board] + Vector2(0,50*nl) + Vector2(0,50*(t-j))
#				print('frst  ',boards)
				var add = boards[p].slice(j,len(boards[p])-1,1,true)
				if j > 0:
					boards[p] = boards[p].slice(0,j-1,1,true)
					var O = self.get_node(str(boards[p][-1]))
					O.get_child(0).set_faceup(true)
				else:
					boards[p] = []
				boards[board] += add
#				print('end  ',boards)
				break
		if !flag:
			if id in open:
				var lc = open.find(id,0)
				open.remove(lc)
				if lc != 0:
					var a = 0
					for mc in open.slice(0,lc-1):
						a +=1
						var n = self.get_node(str(mc))
						if n == null:
							continue
						if a == lc:
							n.get_child(0).input_pickable=true
						n.position += Vector2(70,0)
				active.position = board_pos[board] + Vector2(0,50*nl)
#				print('frst  ',boards)
				var add = [id]
				boards[board] += add
#				push_state()
#				print('end  ',boards)
			else:
				var ccar = get_card_from_id(id)
				if ccar[0] == ace_vals[ccar[1]]:
					ace_vals[ccar[1]] -= 1
					if ace_vals[ccar[1]] >= 0:
						var ida = generate_card_id(ace_vals[ccar[1]],ccar[1])
						var new_card = card_template.instance()
						new_card.position = ace_pos[ccar[1]]
						new_card.name = str(ida)
						new_card.get_child(0).id = ida
						new_card.get_child(0).get_child(1).frame = ida + 1
						new_card.get_child(0).faceUp = true
						self.add_child(new_card)
					active.position = board_pos[board] + Vector2(0,50*nl)
					var add = [id]
					boards[board] += add
#					push_state()
				else:
					_false_drop(id,active,body)
		else:
#			push_state()
			pass
		update_prio_all()
		update_draw_order()


func _recursive_check_won(arr):
	if len(arr) == 1:
		if arr[0].name.is_valid_integer():
			return arr[0].get_child(0).faceUp
		return true
	if arr[0].name.is_valid_integer():
		return arr[0].get_child(0).faceUp and _recursive_check_won(arr.slice(1,len(arr)-1))
	return _recursive_check_won(arr.slice(1,len(arr)-1))

func _check_won():
	var children = self.get_children()
	if _recursive_check_won(children):
		#IF WON
		var new_card = won_sign.instance()
		new_card.position = Vector2(540,-120)
		self.add_child(new_card)




func _check_drop(id,active,kbody):
	var pos:Vector2 = active.position
	for i in range(4):
#		print('disst   ',pos.distance_to(ace_pos[i]))
		if pos.distance_to(ace_pos[i]) < 60:
			var ccard = get_card_from_id(id)
#			print('ccard, ace vals, ace classes ',ccard,' , ',ace_vals[i], ' , ' , ace_classes[i])
			if ccard[0] == ace_vals[i] + 1 and ccard[1] == ace_classes[i]:
				_true_drop(id,active,kbody,-i-1)
				_check_won()
			else:
				_false_drop(id,active,kbody)
			return
	var poss_board = get_board_from_x(pos.x)
	if poss_board > 6 or poss_board < 0:
		_false_drop(id,active,kbody)
		return
#	print('board: ',poss_board)
	var my = 420 + (50*len(boards[poss_board]))
#	print('diff: ',abs(pos.y-my))
	if abs(pos.y-my) > 180:
		_false_drop(id,active,kbody)
		return
	var ccard = get_card_from_id(id)
	if len(boards[poss_board]) == 0 and ccard[0] == 12:
		_true_drop(id,active,kbody,poss_board)
		_check_won()
		return
	elif len(boards[poss_board]) == 0:
		_false_drop(id,active,kbody)
		return
	var possible_id = boards[poss_board][-1]
	var pcard = get_card_from_id(possible_id)
	
	if pcard[2] == ccard[2]:
		print('renk ',pcard,'  ',ccard)
		_false_drop(id,active,kbody)
		return
	if pcard[0] - ccard[0] != 1:
		print('zumzum ',pcard,'  ',ccard)
		_false_drop(id,active,kbody)
		return
	_true_drop(id,active,kbody,poss_board)
	_check_won()
	return


func _change_hodl(id,disp):
	hodl = !hodl
	if hodl:
		activeID = id
		for i in boards:
			if id in i:
#				print(id,i)
				var j = i.find(id,0)
				var s = self.get_node(str(id))
				self.move_child(s,self.get_child_count())
				for t in range(j+1,len(i)):
					var n = self.get_node(str(i[t]))
					self.move_child(n,self.get_child_count()-t + j)
					if n.get_child(0).faceUp:
						n.get_child(0).dragging = true
						n.get_child(0).disp = Vector2(0,50*(t-j)) + disp
	else:
		for i in boards:
			if id in i:
#				print(id,i)
				var j = i.find(id,0)
				for t in range(j+1,len(i)):
					var n = self.get_node(str(i[t]))
					if n.get_child(0).faceUp:
						n.get_child(0).dragging = false
#						print(n.get_child(0).dragging)
						n.get_child(0).disp = Vector2(0,0)


func get_board(i):
	return boards[i]

func get_movable(id):
	for i in range(len(boards)):
		for j in range(len(boards[i])):
			if boards[i][j] == id:
				if j == len(boards[i]) - 1:
					return true
	return false

func update_prio(board):
	var l = len(board)
	for i in range(l):
		var n = self.get_node(str(board[i]))
		var t = -1
		if i != l - 1:
			t = 50
		n.get_child(0).get_child(0).rescale_bounds(t)
		#print(n.get_child(0).process_priority)
func update_prio_all():
	for i in boards:
		update_prio(i)
# Called when the node enters the scene tree for the first time.
func update_draw_order():
	for j in range(len(boards)):
		for i in range(len(boards[j])-1,-1,-1):
			var n = self.get_node(str(boards[j][i]))
			self.move_child(n,i+1)
			



func get_board_from_x(x):
	return int((x-60)/140)
func _ready():
	text_font = DynamicFont.new()
	text_font.font_data = load('res://fonts/linux-libertine/LinuxLibertine.tres')
	deck_clicker = self.get_node('deck_clicker')
	randomize()
	for i in range(4):
		ace_pos.append(Vector2(120 + (140*i),200))
	for i in range(7):
		board_pos.append(Vector2(120 + (140*i),420))
	for i in range(52):
		deck.append(i)
	deck.shuffle()
	print(deck)
#	var count = 0
	for i in range(7):
		for j in range(i+1):
			var idd = deck.pop_back()
			boards[i].append(idd)
			var new_card = card_template.instance()
			new_card.position = board_pos[i] + Vector2(0,50*j)
			new_card.name = str(idd)
			new_card.get_child(0).id = idd
			if j == i:
				new_card.get_child(0).get_child(1).frame = idd + 1
			else:
				new_card.get_child(0).get_child(1).frame = 0
			new_card.get_child(0).set_location(i,j)
			new_card.get_child(0).faceUp = j == i
			self.add_child(new_card)
		update_prio(boards[i])
	print(boards)
	states.append(make_state());
	print(states)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_autocomplating:
		if autocomplate_info[3]:
			#move the card
			autocomplate_info[4] += 4.0*delta
#			print(autocomplate_info)
			autocomplate_info[4] = min(autocomplate_info[4],1)
			var newloc = lerp(autocomplate_info[1],autocomplate_info[2],autocomplate_info[4])
			autocomplate_info[0].position = newloc
			var cardinfo = autocomplate_info[5]
			if autocomplate_info[4] == 1:
				var idd = cardinfo[2]
				var cls = cardinfo[3]
				_ace_drop(idd,autocomplate_info[0],null,cls)
				autocomplate_info = [-1,-1,-1,false,0,[]]
				if cardinfo[0] == pos.DECK:
					deck.remove(cardinfo[1])
				elif cardinfo[0] == pos.BOARDS:
					boards[cardinfo[1]].remove(len(boards[cardinfo[1]])-1)
					#no need to open new card anyway since all will be open
				_autocomplate_next()
							
func _draw():
	var asd = str(len(deck))
	draw_string(text_font,deck_position,asd,Color.white)

func _remake_move(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if len(states) <= 0:
			return
		print('len states = ', len(states))
		#states.pop_back()
		var st;
		if len(states) == 1:
			st = states.back().duplicate(true)
		else:
			st = states.pop_back()
			print('POPPED')
			print(st)
		if st.hash() == make_state().hash():
			if len(states) == 0:
				print('RETURNOING')
				return;
			elif len(states) == 1:
				st = states[0].duplicate(true)
				print('LEN!ST')
				print(st)
			else:
				st = states.pop_back()
		else:
#			print('STATE: ',st,'\n\n')
#			print('NEW:  ',make_state())
			pass
		print('APPLYING')
		apply_state(st)
		print(states)


func autocomplate():
	if !is_autocomplating:
		is_autocomplating = true
		#first reset open
		var openfaceup = []
		for i in self.open:
			if self.get_node(str(i)) != null:
				self.remove_child(self.get_node(str(i)))
		deck.append_array(open)
		open = []
		_autocomplate_next()


func _autocomplate_next():
	var cardinfo = _autocomplate_search_next() #pos,index,id,cls,nval
	print(cardinfo)
	if cardinfo[0] == -1:
		printerr("CARD DOES NOT EXIST\n",cardinfo)
		is_autocomplating = false
		return
	var end_loc = ace_pos[cardinfo[3]]
	#check if the card exists
	if self.get_node(str(cardinfo[2])) == null:
		#create card if does not exist
		spawn_card(deck_position + Vector2(-140,0),cardinfo[2],true)
	var tomove_card:Node2D = self.get_node(str(cardinfo[2]))
	var start_loc = tomove_card.position
	autocomplate_info = [tomove_card,start_loc,end_loc,true,0,cardinfo]
	


enum pos{
	OPEN,
	DECK,
	BOARDS,
}


func _autocomplate_search_next():
	for i in range(4):
		var cls = ace_classes[i]
		var nval = ace_vals[i] + 1
		var card_id = generate_card_id(nval,cls)
		#first search on open cards #NOT NEEDED AS IT RESETS
#		for j in range(len(open)):
#			if open[j] == card_id:
#				return [pos.OPEN, j,card_id,cls,nval]
		#search in deck
		for j in range(len(deck)):
			if deck[j] == card_id:
				return [pos.DECK,j,card_id,cls,nval]
		#search on boards
		for j in range(len(boards)):
			var boar:Array = boards[j]
			if boar.back() == card_id:
				return[pos.BOARDS,j,card_id,cls,nval]
	return [-1,-1,-1]

#func _on_Sahne_draw():
#	var asd = str(len(deck))
#	print(asd)
#	draw_string(text_font,deck_position,asd,Color.white)
