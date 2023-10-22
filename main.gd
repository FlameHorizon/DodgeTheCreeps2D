extends Node

@export var mob_scene: PackedScene
@export var difficulty_increase_rate: float
@export var difficulty_cap: float
var score


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$DifficultTimer.stop()
	
	$HUD.show_game_over()
	$DeathSound.play()
	$Music.stop()


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	
	$StartTimer.start()
	$DifficultTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


# Custom feature
# Increases difficulty every tick by increasing spawn rate of mobs.
func _on_difficult_timer_timeout():
	if $MobTimer.wait_time > difficulty_cap:
		$MobTimer.wait_time = max(difficulty_cap, 
								  $MobTimer.wait_time - difficulty_increase_rate)
		print_debug("Increased difficulty. Running at: " + str($MobTimer.wait_time))
	else:
		$DifficultTimer.stop()
		print_debug("Difficulty is set at max. Running at: " + str($MobTimer.wait_time))