extends "res://scripts/GUI/GUILayoutBase.gd"

onready var _my_ship_list : MyItemList = get_node("HBoxContainer/MyShip/MyItemList")
onready var _other_ship_list : MyItemList = get_node("HBoxContainer/OtherShip/MyItemList")
var _obj : Attributes = null

var _buy_btn : ButtonBase = null
var _sale_btn : ButtonBase = null
var _desc_btn : ButtonBase = null

var _transfered_cargo : Dictionary = {}
var _transfered_ship : Attributes = null
var _transfered_to : Attributes = null

var _callback_obj : Node = null
var _callback_method : String = ""

var _lobj : Attributes = null
var _robj : Attributes = null

func _ready():
	_buy_btn = get_node("HBoxContainer/Control/VBoxContainer/base/Info/Control/Buy")
	_sale_btn = get_node("HBoxContainer/Control/VBoxContainer/base/Info/Control/Sell")
	_desc_btn = get_node("HBoxContainer/Control/VBoxContainer/IconContainer/Desc")
	
	_sale_btn.connect("pressed", self, "Sale_Callback")
	_buy_btn.connect("pressed", self, "Buy_Callback")
	_desc_btn.connect("pressed", self, "Desc_Callback")
	
	get_node("HBoxContainer/Control/Control/Cancel").connect("pressed", self, "Cancel_Callback")
	get_node("HBoxContainer/Control/Control/Close").connect("pressed", self, "Ok_Callback")
	
	_my_ship_list.connect("OnSelectionChanged", self, "OnSelectionChanged_Callback")
	_my_ship_list.connect("OnDragDropCompleted", self, "OnDragDropCompleted_Callback")
	_other_ship_list.connect("OnSelectionChanged", self, "OnSelectionChanged_Callback")
	_other_ship_list.connect("OnDragDropCompleted", self, "OnDragDropCompleted_Callback")

func HowManyDiag_Callback(num):
	_transfered_cargo.count = num
	BehaviorEvents.emit_signal("OnRemoveItem", _transfered_ship, _transfered_cargo.src, _transfered_cargo.count)
	for i in range(_transfered_cargo.count):
		BehaviorEvents.emit_signal("OnAddItem", _transfered_to, _transfered_cargo.src)
	
	BehaviorEvents.emit_signal("OnMoveCargo", _transfered_ship, _transfered_to)
	# Update inventory lists
	ReInit()


func Cancel_Callback():
	ReInit()
	
func Ok_Callback():
	BehaviorEvents.emit_signal("OnPopGUI")
	get_node("HBoxContainer/Control/Normal/Close").Disabled = true
	
	# reset content or we might end up with dangling references
	_my_ship_list.Content = []
	_other_ship_list.Content = []
	
	
func Desc_Callback():
	var selected_item = null
	var selected_ship = null
	var to_ship = null
	var from_list = null
	var to_list = null
	
	var left = _my_ship_list.Content
	
	var scanner_level := 0
	var scanner_data = Globals.LevelLoaderRef.LoadJSONArray(_lobj.get_attrib("mounts.scanner"))
	if scanner_data != null and scanner_data.size() > 0:
		scanner_level = Globals.get_data(scanner_data[0], "scanning.level")
	
	var right = _other_ship_list.Content
	
	for item in left:
		if item.selected == true:
			selected_item = item
			selected_ship = _lobj
			to_ship = _robj
			from_list = _my_ship_list
			to_list = _other_ship_list
			get_node("HBoxContainer/OtherShip").title = "Transfer Where ?"
			#get_node("HBoxContainer/MyShip").title = _lobj.get_attrib("name_id")
			break
	
	#TODO: That looks weird in this method?
	if selected_item == null:
		for item in right:
			if item.selected == true and "src" in item and item.src != "":
				selected_item = item
				selected_ship = _robj
				to_ship = _lobj
				from_list = _other_ship_list
				to_list = _my_ship_list
				get_node("HBoxContainer/MyShip").title = "Transfer Where ?"
				break
	
	if selected_item == null:
		return
	
	var data = null
	if "src" in selected_item and selected_item.src != null and selected_item.src != "":
		data = Globals.LevelLoaderRef.LoadJSON(selected_item.src)
	
	BehaviorEvents.emit_signal("OnPushGUI", "Description", {"json":data, "scanner_level":scanner_level})
	

func Init(init_param):
	var obj1 = init_param["object1"]
	var obj2 = init_param["object2"]
	
	_callback_obj = init_param["callback_object"]
	_callback_method = init_param["callback_method"]
	
	_lobj = obj1
	_robj = obj2
	
	ReInit()
	
func ReInit():
	get_node("HBoxContainer/Control/Control/Close").Disabled = false
	_lobj.init_cargo()
	_lobj.init_mounts()
	_robj.init_cargo()
	_robj.init_mounts()
	
	get_node("HBoxContainer/OtherShip").title = Globals.mytr(_robj.get_attrib("name_id"))
	get_node("HBoxContainer/MyShip").title = Globals.mytr(_lobj.get_attrib("player_name", _lobj.get_attrib("name_id")))
	
	var cargo1 = _lobj.get_attrib("cargo.content")
	var mounts1 = _lobj.get_attrib("mounts")
	var cargo2 = _robj.get_attrib("cargo.content")
	var mounts2 = _robj.get_attrib("mounts")
	
	#_normal_btns.visible = true
	#_question_btns.visible = false
	
	GenerateContent(_my_ship_list, mounts1, cargo1)
	GenerateContent(_other_ship_list, mounts2, cargo2)
	
	var current_load = _lobj.get_attrib("cargo.volume_used")
	var cargo_space = _lobj.get_attrib("cargo.capacity")
	
	var cargo_color = "lime"
	var cargo_str = ""
	if current_load > cargo_space:
		cargo_color="red"
	elif current_load > cargo_space * 0.9:
		cargo_color="yellow"
		
	get_node("HBoxContainer/MyShip/CargoLabel").bbcode_text = "[right]([color=%s]%.f / %.f[/color])[/right]" % [cargo_color, current_load, cargo_space]
	
	#current_load = _robj.get_attrib("cargo.volume_used")
	#cargo_space = _robj.get_attrib("cargo.capacity")
	
	#cargo_color = "lime"
	#cargo_str = ""
	#if current_load > cargo_space:
	#	cargo_color="red"
	#elif current_load > cargo_space * 0.9:
	#	cargo_color="yellow"
		
	#get_node("HBoxContainer/OtherShip/CargoLabel").bbcode_text = "[right]([color=%s]%.f / %.f[/color])[/right]" % [cargo_color, current_load, cargo_space]
	
	# Init all the buttons to Enable/Disabled state
	OnSelectionChanged_Callback()
	
func sort_categories(var a, var b):
	return a > b
	
func GenerateContent(list_node, mounts, cargo):
	var mount_content := []
	var keys = mounts.keys()
	keys.sort_custom(self, "sort_categories")
	for key in keys:
		mount_content.push_back({"key":key, "name_id":key, "equipped":false, "header":true})
		var items : Array = mounts[key]
		var index = 0
		for src in items:
			if src != null and src != "":
				var item = Globals.LevelLoaderRef.LoadJSON(src)
				mount_content.push_back({"src":mounts[key][index], "key":key, "idx":index, "name_id":item.name_id, "equipped":false, "header":false, "icon":item.icon})
			else:
				mount_content.push_back({"src":"", "key":key, "idx":index, "name_id":"Empty", "equipped":false, "header":false})
			index += 1
		
	mount_content.push_back({"src":"", "name_id":"Cargo Contents", "equipped":false, "header":true})	
	for row in cargo:
		var data = Globals.LevelLoaderRef.LoadJSON(row.src)
		var counting = ""
		if row.count > 1:
			counting = str(row.count) + "x "
		if typeof(data.icon) == TYPE_ARRAY:
			data.icon = data.icon[0]
		mount_content.push_back({"src":row.src, "count":row.count, "display_name_id": counting + Globals.mytr(data.name_id), "name_id": counting + Globals.mytr(data.name_id), "equipped":false, "header":false, "icon":data.icon})

	list_node.Content = mount_content

func OnSelectionChanged_Callback():
	pass
	#if _normal_btns.visible == true:
	#	UpdateNormalVisibility()
	#else:
	#	DoMounting()
