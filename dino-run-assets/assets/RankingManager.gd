extends Node

var num_players: int = 1
var player1_name: String = ""
var player2_name: String = ""

const SAVE_FILE_PATH = "user://ranking.json"

# Cargar el ranking desde el archivo JSON
func load_ranking() -> Array:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return []
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		return []
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		if json.data is Array:
			return json.data
	return []

# Guardar una nueva puntuación en el ranking
func save_score(p_name: String, p_score: int):
	var ranking = load_ranking()
	
	# Añadir la nueva entrada
	ranking.append({"name": p_name, "score": p_score})
	
	# Ordenar de mayor a menor puntuación
	ranking.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	
	# Mantener solo los 10 mejores
	if ranking.size() > 10:
		ranking.resize(10)
		
	# Escribir de vuelta al archivo JSON
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(ranking))
		file.close()
