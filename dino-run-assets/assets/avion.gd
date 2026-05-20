extends CharacterBody2D

const JUMP_INVERTED : int = 400  
const JUMP_SPEED: int = -400

var tiempo_arriba : float   = 1.0
var tiempo_abajo : float = 1.0
const LIMITE_DOBLE_CLICK : float = 0.3 

var en_turbo : bool = false
var temporizador_turbo : float = 0.0
const DURACION_TURBO : float = 0.6 
const BOOST_VELOCIDAD : float = 1.5 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var aku_aku_sound: AudioStreamPlayer2D = $AkuAkuSound
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

# Candado visual para el impacto
var en_choque : bool = false

@export var input_up: String = "p1_up"
@export var input_down: String = "p1_down"

@onready var main = get_tree().get_first_node_in_group("main")

func _physics_process(delta):
	# Obtener la referencia si no se obtuvo al inicio (por el orden del árbol)
	if main == null:
		main = get_tree().get_first_node_in_group("main")
		if main == null:
			return
		
	if not main.game_running:
		animated_sprite_2d.play("turbo")
		return 

	# 1. Contadores de tiempo para el doble click
	tiempo_arriba += delta
	tiempo_abajo += delta

	# 2. Control del tiempo del turbo
	if en_turbo:
		temporizador_turbo -= delta
		if temporizador_turbo <= 0:
			en_turbo = false 

	# 3. Detectar doble click para activar turbo
	if Input.is_action_just_pressed(input_up):
		jump_sound.play() 
		if tiempo_arriba <= LIMITE_DOBLE_CLICK:
			en_turbo = true
			temporizador_turbo = DURACION_TURBO
		tiempo_arriba = 0.0 
		
	elif Input.is_action_just_pressed(input_down):
		jump_sound.play()
		if tiempo_abajo <= LIMITE_DOBLE_CLICK:
			en_turbo = true
			temporizador_turbo = DURACION_TURBO
		tiempo_abajo = 0.0 

	# 4. Movimiento físico (Sigue funcionando aunque estés chocado)
	var multiplicador = BOOST_VELOCIDAD if en_turbo else 1.0

	var is_up = Input.is_action_pressed(input_up)
	var is_down = Input.is_action_pressed(input_down)
	
	var final_jump_speed = JUMP_SPEED
	var final_jump_inverted = JUMP_INVERTED
	
	# En modo solitario la pantalla es el doble de alta, aumentamos la velocidad
	# vertical para que la agilidad se sienta igual de responsiva que en cooperativo.
	if scale.y >= 0.9:
		final_jump_speed *= 1.5
		final_jump_inverted *= 1.5

	if is_up:
		velocity.y = final_jump_speed * multiplicador
	elif is_down:
		velocity.y = final_jump_inverted * multiplicador
	else:
		velocity.y = 0 

	# 5. CONTROL ESTRICTO DE ANIMACIONES
	if not en_choque:
		if en_turbo:
			animated_sprite_2d.play("turbo")
		else:
			animated_sprite_2d.play("volando")

	move_and_slide()

# Función que llamas desde el main.gd cuando colisiona
func recibir_dano():
	if en_choque: return
	en_choque = true
	animated_sprite_2d.play("crash")
	aku_aku_sound.play()
	
	# --- MODO INMUNIDAD ---
	# 1. Apagamos la detección de la capa 2 (Obstáculos). 
	# (El avión ya no choca físicamente contra ellos).
	set_collision_mask_value(2, false)
	
	# 2. Apagamos la presencia del avión en la capa 1 (Jugador).
	# (Los nodos de los obstáculos ya no detectarán señales al tocarte).
	set_collision_layer_value(1, false)
	
	# Nota: La máscara 1 (Suelo) sigue encendida, por lo que nunca caerás al vacío.
	
	await get_tree().create_timer(2.0).timeout
	
	# --- FIN DE INMUNIDAD ---
	en_choque = false
	
	# Restauramos las capas físicas a la normalidad
	set_collision_mask_value(2, true)
	set_collision_layer_value(1, true)
