extends Area2D

@onready var main = get_tree().get_first_node_in_group("main")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if main == null:
		main = get_tree().get_first_node_in_group("main")
		if main == null:
			return
	position.x -= main.speed / 2
