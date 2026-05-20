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

func _physics_process(delta):
	# Si el juego está en Game Over, no hacemos nada
	if not get_parent().game_running:
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
	if Input.is_action_just_pressed("ui_up"):
		jump_sound.play() 
		if tiempo_arriba <= LIMITE_DOBLE_CLICK:
			en_turbo = true
			temporizador_turbo = DURACION_TURBO
		tiempo_arriba = 0.0 
		
	elif Input.is_action_just_pressed("ui_down"):
		jump_sound.play()
		if tiempo_abajo <= LIMITE_DOBLE_CLICK:
			en_turbo = true
			temporizador_turbo = DURACION_TURBO
		tiempo_abajo = 0.0 

	# 4. Movimiento físico (Sigue funcionando aunque estés chocado)
	var multiplicador = BOOST_VELOCIDAD if en_turbo else 1.0

	if Input.is_action_pressed("ui_up"):
		velocity.y = JUMP_SPEED * multiplicador
	elif Input.is_action_pressed("ui_down"):
		velocity.y = JUMP_INVERTED * multiplicador
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
