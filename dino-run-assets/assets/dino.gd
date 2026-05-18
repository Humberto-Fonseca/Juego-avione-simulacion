extends CharacterBody2D

const JUMP_INVERTED : int = 300  
const JUMP_SPEED: int = -300
var click_abajo = 0
var click_arriba = 0
func _physics_process(delta):
	if not get_parent().game_running:
		$AnimatedSprite2D.play("idle")
	else:
		$RunCol.disabled = false
		if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				if click_arriba == 0:
					$JumpSound.play()
					click_arriba += 1
					click_abajo = 0
		elif Input.is_action_pressed("ui_down"):
			velocity.y = JUMP_INVERTED
			if click_abajo == 0:
				$JumpSound.play()
				click_abajo += 1
				click_arriba = 0
			#$AnimatedSprite2D.play("duck")
			#$RunCol.disabled = true
		else:
			$AnimatedSprite2D.play("run")
	move_and_slide()  

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
