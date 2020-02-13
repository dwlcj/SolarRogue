extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	OS.set_window_fullscreen(PermSave.get_attrib("settings.full_screen", false))
	OS.set_use_vsync(PermSave.get_attrib("settings.vsync", true))
	var lang = PermSave.get_attrib("settings.lang")
	if lang != null:
		TranslationServer.set_locale(lang)
		BehaviorEvents.emit_signal("OnLocaleChanged")
	#BehaviorEvents.connect("OnPushGUI", self, "OnPushGUI_Callback")
	#BehaviorEvents.connect("OnPopGUI", self, "OnPopGUI_Callback")
	
	get_node("MenuRoot/MenuBtn/Continue").Disabled = not File.new().file_exists("user://savegame.save")
	BehaviorEvents.emit_signal("OnPushGUI", "MenuRoot", {})
	
	if Globals.is_ios():
		get_node("MenuRoot/MenuBtn/Quit").visible = false

#func OnPopGUI_Callback():
#	var name_diag = get_node("PlayerName")
#	name_diag.visible = false

func _on_newgame_pressed():
	var name_diag = get_node("PlayerName")
	BehaviorEvents.emit_signal("OnPushGUI", "PlayerName", {"callback_object":self, "callback_method":"_on_choose_name_callback"})
	

func _on_choose_name_callback(name):
	var save_game = Directory.new()
	save_game.remove("user://savegame.save")
	
	PermSave.set_attrib("settings.default_name", name)
	get_tree().change_scene("res://scenes/main.tscn")
	

func _on_Continue_pressed():
	get_tree().change_scene("res://scenes/main.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	BehaviorEvents.emit_signal("OnPushGUI", "Credits", {})


func _on_Setting_pressed():
	BehaviorEvents.emit_signal("OnPushGUI", "Settings", {})
