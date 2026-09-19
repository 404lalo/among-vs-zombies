extends Node

@export var mob_scene: PackedScene
var score
var last_ammo_threshold

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	
func new_game():
	score = 0
	last_ammo_threshold = 0
	$Player.start($StartPosition.position)
	$Player.shot_enemy.connect(_on_player_shot_enemy)
	$Player.ammo_changed.connect($HUD.update_ammo)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_ammo($Player.ammo)
	$HUD.show_message("Get Ready")

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)
	check_ammo_bonus()
	
func _on_player_shot_enemy(mob) -> void:
	mob.queue_free()
	score += 5
	$HUD.update_score(score)
	check_ammo_bonus()
	
func check_ammo_bonus() -> void:
	while score - last_ammo_threshold >= 10:
		last_ammo_threshold += 10
		$Player.ammo += randi_range(1, 3)
		$HUD.update_ammo($Player.ammo)

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
