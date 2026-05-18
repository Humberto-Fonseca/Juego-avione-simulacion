extends CharacterBody2D

const JUMP_INVERTED : int = 300  
const JUMP_SPEED: int = -300

# Variables para medir el doble click
var tiempo_arriba : float = 1.0
var tiempo_abajo : float = 1.0
const LIMITE_DOBLE_CLICK : float = 0.3 # Segundos máximos para considerarlo "doble click"

# Variables para el estado Turbo
var en_turbo : bool = false
var temporizador_turbo : float = 0.0
const DURACION_TURBO : float = 0.6 # Cuánto tiempo dura el efecto
const BOOST_VELOCIDAD : float = 1.5 # Multiplicador: 1.5 = 50% más rápido

func _physics_process(delta):
	# Si el juego no está corriendo, no procesamos entradas
	if not get_parent().game_running:
		return 

	# 1. Sumamos el tiempo transcurrido (delta) a nuestros cronómetros
	tiempo_arriba += delta
	tiempo_abajo += delta

	# 2. Controlar la duración del turbo
	if en_turbo:
		temporizador_turbo -= delta
		if temporizador_turbo <= 0:
			en_turbo = false # Se apaga el turbo cuando se acaba el tiempo

	# 3. Detectar el instante de pulsación (Just Pressed) para el Doble Click
	if Input.is_action_just_pressed("ui_accept"):
		$JumpSound.play()
		if tiempo_arriba <= LIMITE_DOBLE_CLICK:
			activar_turbo()
		tiempo_arriba = 0.0 # Reiniciamos el cronómetro

	elif Input.is_action_just_pressed("ui_down"):
		$JumpSound.play()
		if tiempo_abajo <= LIMITE_DOBLE_CLICK:
			activar_turbo()
		tiempo_abajo = 0.0 # Reiniciamos el cronómetro

	# 4. Movimiento continuo mientras se mantiene presionado
	var multiplicador = BOOST_VELOCIDAD if en_turbo else 1.0

	if Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_SPEED * multiplicador
	elif Input.is_action_pressed("ui_down"):
		velocity.y = JUMP_INVERTED * multiplicador
	else:
		velocity.y = 0 # Frena verticalmente si no presionas nada

	# 5. Control de animaciones
	if en_turbo:
		$AnimatedSprite2D.play("turbo")
	else:
		$AnimatedSprite2D.play("volando")

	# 6. Aplicar las físicas
	move_and_slide()

# Función auxiliar para encender el turbo
func activar_turbo():
	en_turbo = true
	temporizador_turbo = DURACION_TURBO
	 
	# Opcional: Si quieres que el turbo también haga que el avión avance 
	# más rápido hacia adelante (eje X), descomenta la siguiente línea:
	# get_parent().speed += 5.0
