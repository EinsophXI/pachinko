extends Node2D

var score = 0

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var histogram = $CanvasLayer/HBoxContainer
@onready var score_buckets_folder = $"Score Buckets"
@onready var spawn_point = $SpawnPoint

@export var ball_scene: PackedScene
@export var bucket_yields: Array[int] = [0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2]

func _ready():
	print("--- GAME STARTED ---")
	
	if not score_label: print("ERROR: Cannot find ScoreLabel!")
	if not histogram: print("ERROR: Cannot find Histogram!")
	if not score_buckets_folder: 
		print("ERROR: Cannot find 'Score Buckets' folder!")
		return 
		
	score_label.text = "Score: 0"
	
	var bucket_index = 0
	var connected_count = 0
	
	# Loop through the Score Buckets folder
	for bucket in score_buckets_folder.get_children():
		if bucket is Area2D:
			bucket.body_entered.connect(Callable(self, "_on_bucket_body_entered").bind(bucket_index))
			connected_count += 1
		bucket_index += 1
		
	print("Successfully connected ", connected_count, " buckets!")

func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)

func _on_bucket_body_entered(body, bucket_index):
	if body is RigidBody2D: 
		
		# --- NEW: COOLDOWN TIMER SYSTEM ---
		# Check if the ball is currently on cooldown
		if body.has_meta("cooldown") and body.get_meta("cooldown") == true:
			return 
			
		# Put the ball on cooldown immediately so it doesn't double-trigger
		body.set_meta("cooldown", true)
		
		var balls_to_spawn = 0
		if bucket_index < bucket_yields.size():
			balls_to_spawn = bucket_yields[bucket_index]
			
		if histogram and histogram.has_method("add_to_bucket"):
			histogram.add_to_bucket(bucket_index)
			
		if balls_to_spawn == 0:
			# Sink bucket! Delete the ball.
			body.queue_free()
		else:
			# Doubler bucket!
			var extra_balls = balls_to_spawn - 1
			if extra_balls > 0:
				if spawn_point:
					spawn_new_balls(spawn_point.global_position, extra_balls)
					
		# --- NEW: REMOVE THE COOLDOWN ---
		# Wait half a second, then allow the ball to score again
		await get_tree().create_timer(0.5).timeout
		
		# Check if the ball still exists (it might have fallen off screen or been deleted)
		if is_instance_valid(body):
			body.set_meta("cooldown", false)

func spawn_new_balls(spawn_position: Vector2, amount: int):
	for i in range(amount):
		if ball_scene:
			var new_ball = ball_scene.instantiate()
			
			# FIX: Set the exact position BEFORE we add it to the game tree!
			var random_offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
			new_ball.global_position = spawn_position + random_offset
			
			# Now safely add it to the game
			call_deferred("add_child", new_ball)
			print("SUCCESS: Ball spawned at top!")
		else:
			print("CRITICAL ERROR: Ball Scene is missing from the Inspector!")
