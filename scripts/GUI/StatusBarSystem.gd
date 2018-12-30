extends Control

export(int) var warning_energy_level = 5000
export(int) var danger_energy_level = 1000
export(int) var hull_size = 20

var _window

func _ready():
	_window = get_node("StatusWindow")
	BehaviorEvents.connect("OnDamageTaken", self, "OnDamageTaken_Callback")
	if Globals.LevelLoaderRef == null:
		BehaviorEvents.connect("OnLevelLoaded", self, "OnLevelLoaded_Callback")
	else:
		OnLevelLoaded_Callback()

func OnDamageTaken_Callback(target, shooter):
	var is_player = target.get_attrib("type") == "player"
	if not is_player:
		return
		
func OnLevelLoaded_Callback():
	UpdateStatusBar(Globals.LevelLoaderRef.objByType["player"][0])
		
#The Maveric Hull : [color=lime]==========[/color] Energy : [color=yellow]25000[/color] Shield : Up	
func UpdateStatusBar(player_obj):
	var ship_name = "The Maveric" #TODO: make dynamic when we have a title menu
	var cur_hull = player_obj.get_attrib("destroyable.hull")
	var max_hull = player_obj.base_attributes.destroyable.hull
	var hull_color = "lime"
	if cur_hull < max_hull / 2.0:
		hull_color = "yellow"
	if cur_hull < max_hull / 4.0:
		hull_color="red"
	var cur_energy = player_obj.get_attrib("converter.stored_energy")
	var energy_color = "lime"
	if cur_energy < warning_energy_level:
		energy_color = "yellow"
	if cur_energy < danger_energy_level:
		energy_color = "red"
		
	var status_str = ship_name + " Hull : [color=" + hull_color + "]"
	#"gray"
	var health_per = cur_hull / max_hull
	var changed_color = false
	for i in range(hull_size):
		if i / hull_size >= health_per and not changed_color:
			status_str += "[/color][color=gray]"
			changed_color = true
		status_str += "="
	status_str += "[/color] Energy : [color=" + energy_color + "]" + str(cur_energy) + "[/color] Shield : [color=red]Missing[/color]"
	
	_window.content = status_str
	
