extends Control

@onready var names_container = $CenterContainer/VBoxContainer/NamesContainer
@onready var lbl_p2 = $CenterContainer/VBoxContainer/NamesContainer/LblP2
@onready var line_p2 = $CenterContainer/VBoxContainer/NamesContainer/LineP2
@onready var line_p1 = $CenterContainer/VBoxContainer/NamesContainer/LineP1

var selected_mode: int = 1

func _ready():
	$CenterContainer/VBoxContainer/HBoxMode/Btn1Player.pressed.connect(_on_1_player_pressed)
	$CenterContainer/VBoxContainer/HBoxMode/Btn2Players.pressed.connect(_on_2_players_pressed)
	$CenterContainer/VBoxContainer/NamesContainer/MarginContainer/BtnStart.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/MarginContainerBack/BtnBack.pressed.connect(_on_back_pressed)
	names_container.hide()

func _on_1_player_pressed():
	selected_mode = 1
	lbl_p2.hide()
	line_p2.hide()
	names_container.show()
	line_p1.grab_focus()

func _on_2_players_pressed():
	selected_mode = 2
	lbl_p2.show()
	line_p2.show()
	names_container.show()
	line_p1.grab_focus()

func _on_start_pressed():
	RankingManager.num_players = selected_mode
	RankingManager.player1_name = line_p1.text if line_p1.text != "" else "Jugador 1"
	if selected_mode == 2:
		RankingManager.player2_name = line_p2.text if line_p2.text != "" else "Jugador 2"
	
	get_tree().change_scene_to_file("res://dino-run-assets/assets/main.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://dino-run-assets/assets/menu.tscn")
