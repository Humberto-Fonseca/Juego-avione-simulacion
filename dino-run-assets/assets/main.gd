extends Node

var stump_scene = preload("res://dino-run-assets/assets/stump.tscn")
var rock_scene = preload("res://dino-run-assets/assets/rock.tscn")
var barrel_scene = preload("res://dino-run-assets/assets/barrel.tscn")
var bird_scene = preload("res://dino-run-assets/assets/bird.tscn")
var bat_scene = preload("res://dino-run-assets/assets/bat.tscn")
var obstacules_type := [stump_scene, barrel_scene]
var obstacules : Array
	 #jugador
@onready var avion = $avion
@onready var collision_shape = $avion/Col_fly
var vidas = 3
#varibles del juego
var x
var y
const avion_START_POS := Vector2i(200    ,485)
const CAM_START_POS:= Vector2i(576,324)
const SCORE_MODIFIER : int = 10
var score: int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER: int = 5000
var screen_size : Vector2i
var ground_hight: int 
var game_running : bool  
var last_obs
var score_obstaculos : int 
#dificultad
var difficulty
const MAX_DIFFICULTY : int = 2

func _ready():
	screen_size = get_window().size
	ground_hight = $Ground.get_node("Sprite2D").texture.get_height()
	$retry.get_node("Button").pressed.connect(new_game)
	new_game()
	
func new_game():
	score = 0
	vidas = 3
	show_score()
	difficulty = 0
	get_tree().paused = false
	score_obstaculos = 0 

	#eliminar todos los obstaculos
	for obs in obstacules:
		obs.queue_free()
	obstacules.clear()
		
	 

	$avion.position = avion_START_POS
	$avion.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,0)
	$HUD.get_node("StartLevel").show()
	$retry.hide()

	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		#aumento de velocidad y ajuste de esta
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		#que el avion no se salga de pantalla
		# Dimensiones del mapa o pantalla (ejemplo: 720p de alto)
		var limite_pantalla_baja: float = 720.0 
		
		# Cálculo de la mitad de la altura real en píxeles
		var mitad_alto: float = (collision_shape.shape.size.y * avion.scale.y) / 2.0
		
		# Definimos los topes matemáticos exactos
		var y_minimo: float = mitad_alto
		var y_maximo: float = limite_pantalla_baja - mitad_alto
		
		# Restringimos la posición del personaje usando la fórmula de rango seguro:
		avion.position.y = clampf(avion.position.y, y_minimo, y_maximo)
		#actualizar score
		score += speed
		show_score()          
		generate_obs()
		#mover la camara y el avionsaurio
		$avion.position.x += speed
		$Camera2D.position.x += speed
		#actualizar la posicion de la tierra
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		#remover obstaculos fuera de escena
		for obs in obstacules:
			if obs.position.x - 500 < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
				
		
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLevel").hide()
			

func generate_obs():
	if obstacules.is_empty() or last_obs.position.x < score + randi_range(300,500):
		var obs_type = obstacules_type[randi() % obstacules_type.size()]
		var obs 
		var max_obs = 1
				
		for i in range(randi()  % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
	#------------------------distribucion uniforme para la posic  ion en el eje y ----------------------------------
			var limite_inferior_y = (obs_height * obs_scale.y / 2 ) + 5
			var limite_superior = screen_size.y - ground_hight - (obs_height * obs_scale.y / 2 ) + 5
			var random_0_to_1 = randf()
			var random2_0_to_1 = randf()

			# Aplicamos la fórmula: x = a + (b - a) * U
			x = limite_inferior_y + (limite_superior - limite_inferior_y) * random_0_to_1
			y = limite_inferior_y + (limite_superior - limite_inferior_y) * random2_0_to_1
	#------------------------------------------------------------------------------
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = x 
			print(x)
			last_obs = obs
			add_obs(obs, obs_x, obs_y) 
	#generacion del murcielago
		if difficulty > -2:
			if (randi() % 2) == 0:
			#genera el murcielago
				obs = bat_scene.instantiate()
				var obs_x : int = screen_size.x + score + 200
				var obs_y : int = y
				add_obs(obs, obs_x, obs_y)
		
	#probabilidad aleatoria extra para el pajaro
		if difficulty > -1:
			if (randi() % 2) == 0:
			#genera el pajaro
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = x
				add_obs(obs, obs_x, obs_y)
				
		
func add_obs(obs, x, y):
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacules.append(obs)	
	
func remove_obs(obs):
	obs.queue_free()
	obstacules.erase(obs)
	score_obstaculos += 1
		
func hit_obs(body):
	if body.name == "avion":
		vidas -= 1
		score -= 1   
	if vidas == 0:
		game_over()
func game_over():
	get_tree().paused = true
	game_running = false	
	$retry.show()
	
	
func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score_obstaculos)
	$HUD.get_node("VidasLevel").text = "LIFES: " + str(vidas," ❣️" )
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY: 
		difficulty = MAX_DIFFICULTY
	
	
	
