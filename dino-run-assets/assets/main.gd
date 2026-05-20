extends Node

var stump_scene = preload("res://dino-run-assets/assets/stump.tscn")
var rock_scene = preload("res://dino-run-assets/assets/rock.tscn")
var barrel_scene = preload("res://dino-run-assets/assets/barrel.tscn")
var bird_scene = preload("res://dino-run-assets/assets/bird.tscn")
var bat_scene = preload("res://dino-run-assets/assets/bat.tscn")
var obstacules_type := [stump_scene, barrel_scene]
var obstacules : Array

# Referencias a nodos en el nuevo layout de Viewports
@onready var world = $ViewportLayout/ViewportContainer1/SubViewport1/World
@onready var avion = $ViewportLayout/ViewportContainer1/SubViewport1/World/avion
@onready var camera = $ViewportLayout/ViewportContainer1/SubViewport1/World/Camera2D
@onready var ground = $ViewportLayout/ViewportContainer1/SubViewport1/World/Ground
@onready var bg = $ViewportLayout/ViewportContainer1/SubViewport1/World/Bg

@onready var viewport_container_2 = $ViewportLayout/ViewportContainer2
@onready var sub_viewport_2 = $ViewportLayout/ViewportContainer2/SubViewport2
@onready var camera2 = $ViewportLayout/ViewportContainer2/SubViewport2/Camera2D_P2

var collision_shape: CollisionShape2D

# Estados de los jugadores
var is_coop: bool = false
var avion2: CharacterBody2D = null
var bg2: Node = null
var vidas_p1 = 3
var vidas_p2 = 3
var p1_alive: bool = true
var p2_alive: bool = true

# Variables del juego
var x
var y
const avion_START_POS_P1 := Vector2i(200, 162) # Mitad superior
const avion_START_POS_P2 := Vector2i(200, 486) # Mitad inferior
const CAM_START_POS_P1 := Vector2i(576, 162)
const CAM_START_POS_P2 := Vector2i(576, 486)
const SCORE_MODIFIER : int = 10
var score: float
var speed : float
const START_SPEED : float = 3.0
const MAX_SPEED : float = 18.0
const SPEED_MODIFIER: int = 5000
var screen_size : Vector2i
var ground_hight: int 
var game_running : bool  
var last_obs
var score_obstaculos_p1 : int = 0
var score_obstaculos_p2 : int = 0

# Dificultad
var difficulty
const MAX_DIFFICULTY : int = 2

func _ready():
	add_to_group("main")
	screen_size = get_viewport().get_visible_rect().size
	ground_hight = ground.get_node("Sprite2D").texture.get_height()
	collision_shape = avion.get_node("CollisionShape2D")
	$retry.get_node("Button").pressed.connect(new_game)
	
	# Verificar modo de juego
	is_coop = (RankingManager.num_players == 2)
	setup_inputs(is_coop)
	
	if is_coop:
		viewport_container_2.show()
		sub_viewport_2.world_2d = $ViewportLayout/ViewportContainer1/SubViewport1.world_2d
		
		# Crear un fondo parallax para el viewport 2
		var bg_scene = load("res://dino-run-assets/assets/bg.tscn")
		bg2 = bg_scene.instantiate()
		sub_viewport_2.add_child(bg2)
		
		# Instanciar el avión del jugador 2
		var avion_scene = load("res://dino-run-assets/assets/avion.tscn")
		avion2 = avion_scene.instantiate()
		avion2.name = "avion2"
		avion2.input_up = "p2_up"
		avion2.input_down = "p2_down"
		world.add_child(avion2)
		
		# Modificar el color del avión 2 a un color azul celeste
		avion2.get_node("AnimatedSprite2D").self_modulate = Color(3, 0.2, 0.5)
	else:
		viewport_container_2.hide()
		
	new_game()

func setup_inputs(coop_active: bool):
	if InputMap.has_action("p1_up"): InputMap.erase_action("p1_up")
	if InputMap.has_action("p1_down"): InputMap.erase_action("p1_down")
	if InputMap.has_action("p2_up"): InputMap.erase_action("p2_up")
	if InputMap.has_action("p2_down"): InputMap.erase_action("p2_down")

	InputMap.add_action("p1_up")
	InputMap.add_action("p1_down")
	
	var ev_w = InputEventKey.new()
	ev_w.physical_keycode = KEY_W
	InputMap.action_add_event("p1_up", ev_w)
	var ev_w2 = InputEventKey.new()
	ev_w2.keycode = KEY_W
	InputMap.action_add_event("p1_up", ev_w2)
	
	var ev_s = InputEventKey.new()
	ev_s.physical_keycode = KEY_S
	InputMap.action_add_event("p1_down", ev_s)
	var ev_s2 = InputEventKey.new()
	ev_s2.keycode = KEY_S
	InputMap.action_add_event("p1_down", ev_s2)

	if coop_active:
		InputMap.add_action("p2_up")
		var ev_up = InputEventKey.new()
		ev_up.physical_keycode = KEY_O
		InputMap.action_add_event("p2_up", ev_up)
		var ev_up2 = InputEventKey.new()
		ev_up2.keycode = KEY_O
		InputMap.action_add_event("p2_up", ev_up2)
		
		InputMap.add_action("p2_down")
		var ev_down = InputEventKey.new()
		ev_down.physical_keycode = KEY_L
		InputMap.action_add_event("p2_down", ev_down)
		var ev_down2 = InputEventKey.new()
		ev_down2.keycode = KEY_L
		InputMap.action_add_event("p2_down", ev_down2)
	else:
		var ev_up = InputEventKey.new()
		ev_up.physical_keycode = KEY_UP
		InputMap.action_add_event("p1_up", ev_up)
		var ev_up2 = InputEventKey.new()
		ev_up2.keycode = KEY_UP
		InputMap.action_add_event("p1_up", ev_up2)
		
		var ev_down = InputEventKey.new()
		ev_down.physical_keycode = KEY_DOWN
		InputMap.action_add_event("p1_down", ev_down)
		var ev_down2 = InputEventKey.new()
		ev_down2.keycode = KEY_DOWN
		InputMap.action_add_event("p1_down", ev_down2)

func new_game():
	score = 0
	vidas_p1 = 3
	vidas_p2 = 3
	p1_alive = true
	p2_alive = true
	difficulty = 0
	get_tree().paused = false
	score_obstaculos_p1 = 0 
	score_obstaculos_p2 = 0 

	for obs in obstacules:
		obs.queue_free()
	obstacules.clear()

	# Configurar HUD visual
	if is_coop:
		$HUD.get_node("ScoreLabelP2").show()
		$HUD.get_node("VidasLevelP2").show()
		$HUD.get_node("DividingLine").show()
	else:
		$HUD.get_node("ScoreLabelP2").hide()
		$HUD.get_node("VidasLevelP2").hide()
		$HUD.get_node("DividingLine").hide()

	# En modo solitario la cámara se centra, en coop P1 va arriba y se reducen tamaños
	if is_coop:
		camera.position = CAM_START_POS_P1
		avion.position = avion_START_POS_P1
		camera2.position = CAM_START_POS_P2
		avion.scale = Vector2(0.6, 0.6)
	else:
		camera.position = Vector2(576, 324)
		avion.position = Vector2(200, 324)
		avion.scale = Vector2(1.0, 1.0)
		
	avion.velocity = Vector2i(0,0)
	avion.show()
	avion.set_physics_process(true)
	avion.get_node("CollisionPolygon2D").disabled = false
	avion.set_collision_mask_value(2, true)
	avion.set_collision_layer_value(1, true)
	# Ignorar el suelo físicamente en cooperativo para que P2 tenga todo el espacio
	avion.set_collision_mask_value(3, not is_coop) 
	avion.en_choque = false

	if is_coop and avion2:
		avion2.position = avion_START_POS_P2
		avion2.velocity = Vector2i(0,0)
		avion2.scale = Vector2(0.6, 0.6)
		avion2.show()
		avion2.set_physics_process(true)
		avion2.get_node("CollisionPolygon2D").disabled = false
		avion2.set_collision_mask_value(2, true)
		avion2.set_collision_layer_value(1, true)
		avion2.set_collision_mask_value(3, false) # P2 ignora el suelo para poder volar libre
		avion2.en_choque = false
		
		# Asegurarnos de que las acciones estén bien asignadas
		avion2.input_up = "p2_up"
		avion2.input_down = "p2_down"

	ground.position = Vector2i(0,0)
	$HUD.get_node("StartLevel").show()
	$retry.hide()
	show_score()

func _process(delta):
	if game_running:
		# Calcular nivel actual (cada 15 obstáculos)
		var max_obs = score_obstaculos_p1
		if is_coop:
			max_obs = maxi(score_obstaculos_p1, score_obstaculos_p2)
			
		var current_level = int(1 + (max_obs / 15))
		
		# Actualizar ciclo de día y noche del fondo
		update_background_time(current_level, delta)
		
		difficulty = current_level - 1
		if difficulty > MAX_DIFFICULTY:
			difficulty = MAX_DIFFICULTY

		# Aumentar velocidad progresivamente según el nivel
		speed = START_SPEED + (current_level - 1) * 1.5
		if speed > MAX_SPEED:
			speed = MAX_SPEED
			
		var half_height = 40.0 if is_coop else 68.0
		
		if is_coop:
			# P1 limitado a la mitad superior (0 a 324)
			if p1_alive:
				avion.position.y = clampf(avion.position.y, half_height, 324.0 - half_height)
			# P2 limitado a la mitad inferior (324 a 648)
			if p2_alive and avion2:
				avion2.position.y = clampf(avion2.position.y, 324.0 + half_height, 648.0 - half_height)
		else:
			# En solitario, usa toda la pantalla
			if p1_alive:
				avion.position.y = clampf(avion.position.y, half_height, 648.0 - half_height)
			
		score += speed
		show_score()          
		generate_obs()
		
		if p1_alive:
			avion.position.x += speed
		if is_coop and p2_alive and avion2:
			avion2.position.x += speed
			
		camera.position.x += speed
		if is_coop:
			camera2.position.x += speed
			
		if camera.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x
			
		for obs in obstacules:
			if obs.position.x - 500 < (camera.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLevel").hide()

func generate_obs():
	# La distancia entre obstáculos se reduce conforme aumenta la dificultad
	var min_dist = 450 - (difficulty * 50)
	var max_dist = 650 - (difficulty * 50)
	
	if obstacules.is_empty() or last_obs.position.x < score + randi_range(min_dist, max_dist):
		var obs_type = obstacules_type[randi() % obstacules_type.size()]
		var obs 
		var max_obs = 1
				
		for i in range(randi()  % max_obs + 1):
			obs = obs_type.instantiate()
			if is_coop:
				obs.scale = Vector2(0.6, 0.6)
				
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale * obs.scale
	#------------------------distribucion uniforme para la posic  ion en el eje y ----------------------------------
			# Si es cooperativo, calculamos usando la mitad de la altura de la pantalla
			var active_height = (screen_size.y / 2.0) if is_coop else screen_size.y
			var limite_inferior_y = (obs_height * obs_scale.y / 2 ) + 5
			var limite_superior = active_height - (obs_height * obs_scale.y / 2 ) + 5
			
			# En modo solitario, respetamos el suelo para que no se entierren
			if not is_coop:
				limite_superior -= ground_hight
				
			var random_0_to_1 = randf()
			var random2_0_to_1 = randf()

			# Aplicamos la fórmula: x = a + (b - a) * U
			x = limite_inferior_y + (limite_superior - limite_inferior_y) * random_0_to_1
			y = limite_inferior_y + (limite_superior - limite_inferior_y) * random2_0_to_1
	#------------------------------------------------------------------------------
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = x 
			last_obs = obs
			add_obs(obs, obs_x, obs_y, 1) 
			
			# Clonar el obstáculo para el jugador 2 en modo cooperativo
			if is_coop:
				var obs2 = obs_type.instantiate()
				obs2.scale = Vector2(0.6, 0.6)
				add_obs(obs2, obs_x, obs_y + (screen_size.y / 2.0), 2)
			
		# En el nivel 2 (difficulty >= 1) aparecen los murciélagos
		if difficulty >= 1:
			if (randi() % 2) == 0:
				obs = bat_scene.instantiate()
				if is_coop: obs.scale = Vector2(0.6, 0.6)
				var obs_x : int = screen_size.x + score + 200
				var obs_y : int = y
				add_obs(obs, obs_x, obs_y, 1)
				
				if is_coop:
					var obs2 = bat_scene.instantiate()
					obs2.scale = Vector2(0.6, 0.6)
					add_obs(obs2, obs_x, obs_y + (screen_size.y / 2.0), 2)
		
		# En el nivel 3 (difficulty >= 2) aparecen los pájaros
		if difficulty >= 2:
			if (randi() % 2) == 0:
				obs = bird_scene.instantiate()
				if is_coop: obs.scale = Vector2(0.6, 0.6)
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = x
				add_obs(obs, obs_x, obs_y, 1)
				
				if is_coop:
					var obs2 = bird_scene.instantiate()
					obs2.scale = Vector2(0.6, 0.6)
					add_obs(obs2, obs_x, obs_y + (screen_size.y / 2.0), 2)

func add_obs(obs, x, y, owner_id=1):
	obs.position = Vector2i(x, y)
	obs.set_meta("owner", owner_id)
	obs.body_entered.connect(hit_obs)
	world.add_child(obs)
	obstacules.append(obs)	
	
func remove_obs(obs):
	var owner = obs.get_meta("owner", 1)
	obs.queue_free()
	obstacules.erase(obs)
	
	if owner == 1 and p1_alive:
		score_obstaculos_p1 += 1
	elif owner == 2 and p2_alive:
		score_obstaculos_p2 += 1
		
func hit_obs(body):
	if body.name == "avion" and p1_alive:
		vidas_p1 -= 1
		score -= 1
		score_obstaculos_p1 = maxi(0, score_obstaculos_p1 - 1)
		body.recibir_dano()
		if vidas_p1 <= 0:
			p1_alive = false
			kill_player(avion)
			
	elif body.name == "avion2" and p2_alive:
		vidas_p2 -= 1
		score -= 1
		score_obstaculos_p2 = maxi(0, score_obstaculos_p2 - 1)
		body.recibir_dano()
		if vidas_p2 <= 0:
			p2_alive = false
			kill_player(avion2)

	show_score()
	
	if not p1_alive and (not is_coop or not p2_alive):
		game_over()

func kill_player(player_node):
	player_node.hide()
	player_node.set_physics_process(false)
	player_node.get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if player_node.has_node("CollisionShape2D"):
		player_node.get_node("CollisionShape2D").set_deferred("disabled", true)

func game_over():
	get_tree().paused = false
	game_running = false	
	
	if is_coop:
		RankingManager.save_score(RankingManager.player1_name, score_obstaculos_p1)
		RankingManager.save_score(RankingManager.player2_name, score_obstaculos_p2)
	else:
		var name_to_save = RankingManager.player1_name
		if name_to_save == "":
			name_to_save = "Jugador 1"
		RankingManager.save_score(name_to_save, score_obstaculos_p1)
	
	get_tree().change_scene_to_file("res://dino-run-assets/assets/ranking.tscn")
	
func show_score():
	if is_coop:
		var p1_t = RankingManager.player1_name.left(10)
		var p2_t = RankingManager.player2_name.left(10)
		
		if p1_t == "": p1_t = "P1"
		if p2_t == "": p2_t = "P2"
		
		$HUD.get_node("ScoreLabel").text = p1_t + ": " + str(score_obstaculos_p1)
		$HUD.get_node("VidasLevel").text = "LIVES: " + str(vidas_p1) + " ❣️"
		
		$HUD.get_node("ScoreLabelP2").text = p2_t + ": " + str(score_obstaculos_p2)
		$HUD.get_node("VidasLevelP2").text = "LIVES: " + str(vidas_p2) + " ❣️"
	else:
		$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score_obstaculos_p1)
		$HUD.get_node("VidasLevel").text = "LIVES: " + str(vidas_p1) + " ❣️"
		
	# Actualizar el indicador de nivel
	var max_obs = score_obstaculos_p1
	if is_coop:
		max_obs = maxi(score_obstaculos_p1, score_obstaculos_p2)
	var current_level = 1 + (max_obs / 15)
	$HUD.get_node("LevelLabel").text = "LEVEL: " + str(current_level)
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY: 
		difficulty = MAX_DIFFICULTY

func update_background_time(level: int, delta: float):
	# Alternar día y noche: Nivel impar = Día, Nivel par = Noche
	var is_night = (level % 2 == 0) 
	# Color para la noche (azul oscuro/morado) y color original para el día
	var target_color = Color(0.3, 0.3, 0.65) if is_night else Color(1.0, 1.0, 1.0)
	
	_set_bg_color(bg, target_color, delta)
	if is_coop and bg2:
		_set_bg_color(bg2, target_color, delta)

func _set_bg_color(bg_node: Node, target_color: Color, delta: float):
	if bg_node == null: return
	for child in bg_node.get_children():
		if child is CanvasItem:
			# Lerp para una transición de color suave y elegante como un atardecer
			child.modulate = child.modulate.lerp(target_color, delta * 2.0)
