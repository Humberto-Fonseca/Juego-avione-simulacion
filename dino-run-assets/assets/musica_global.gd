extends Node

var audio_player : AudioStreamPlayer

func _ready():
	# Creamos el reproductor de audio dinámicamente por código
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Configuración inicial de la música
	var stream = load("res://dino-run-assets/assets/sound/musiquita_fondo.mp3") # <--- Pon la ruta real de tu canción
	if stream:
		stream.loop = true
	audio_player.stream = stream
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS # Para que no se pause en el Game Over
	
	# Empezamos con un volumen bajo (en decibelios) para el menú o estado de espera
	audio_player.volume_db = -12.0 
	audio_player.play()

# Función para ajustar el volumen fluidamente usando interpolación lineal (Lerp)
func cambiar_volumen(volumen_objetivo_db: float, duracion: float = 1.0):
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", volumen_objetivo_db, duracion)
