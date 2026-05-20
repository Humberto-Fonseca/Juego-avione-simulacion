extends Control

func _ready():
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/RankingButton.pressed.connect(_on_ranking_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://dino-run-assets/assets/player_setup.tscn")

func _on_ranking_pressed():
	get_tree().change_scene_to_file("res://dino-run-assets/assets/ranking.tscn")

func _on_quit_pressed():
	get_tree().quit()
