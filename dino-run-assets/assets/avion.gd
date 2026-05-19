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
	if Input.is_action_just_pressed("ui_accept"):
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

	if Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_SPEED * multiplicador
	elif Input.is_action_pressed("ui_down"):
		velocity.y = JUMP_INVERTED * multiplicador
	else:
		velocity.y = 0 

	# 5. CONTROL ESTRICTO DE ANIMACIONES
	# (Limpiamos esto: ya no manipulamos las colisiones aquí)
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
	
	collision_polygon_2d.set_deferred("disabled", true)
	await get_tree().create_timer(2.0).timeout
	en_choque = false
	# Vuelve a encender la detección de obstáculos
	#set_collision_mask_value(2, true)
	collision_polygon_2d.set_deferred("disabled", false)
