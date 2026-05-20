extends Control

@onready var list_container = $CenterContainer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	$CenterContainer/VBoxContainer/BtnBack.pressed.connect(_on_back_pressed)
	populate_ranking()

func populate_ranking():
	# Limpiar cualquier nodo previo
	for child in list_container.get_children():
		child.queue_free()
		
	var ranking = RankingManager.load_ranking()
	
	if ranking.is_empty():
		var no_scores_lbl = Label.new()
		no_scores_lbl.text = "SIN REGISTROS"
		no_scores_lbl.add_theme_font_override("font", preload("res://dino-run-assets/assets/fonts/retro.ttf"))
		no_scores_lbl.add_theme_font_size_override("font_size", 32)
		no_scores_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list_container.columns = 1
		list_container.add_child(no_scores_lbl)
		return
		
	list_container.columns = 3
	
	# Encabezados de tabla
	_add_header("POS")
	_add_header("JUGADOR")
	_add_header("PUNTOS")
	
	var pos = 1
	for entry in ranking:
		_add_row_label(str(pos) + ".")
		_add_row_label(entry["name"])
		_add_row_label(str(entry["score"]))
		pos += 1

func _add_header(text: String):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", preload("res://dino-run-assets/assets/fonts/retro.ttf"))
	lbl.add_theme_font_size_override("font_size", 36)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list_container.add_child(lbl)

func _add_row_label(text: String):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", preload("res://dino-run-assets/assets/fonts/retro.ttf"))
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_child(lbl)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://dino-run-assets/assets/menu.tscn")
