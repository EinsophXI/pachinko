extends Node2D

var score = 0

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var histogram = $CanvasLayer/HBoxContainer
@onready var buckets = $Buckets 

func _ready():
	print("--- GAME STARTED ---")
	
	# Check if our nodes are actually connected
	if not score_label:
		print("ERROR: Godot cannot find the ScoreLabel!")
	if not histogram:
		print("ERROR: Godot cannot find the Histogram!")
	if not buckets:
		print("ERROR: Godot cannot find the Buckets folder! Did the name change?")
		return # Stops the script here if it can't find the buckets
		
	score_label.text = "Score: 0"
	
	var bucket_index = 0
	var connected_count = 0
	
	# Loop through and connect the buckets
	for bucket in buckets.get_children():
		if bucket is Area2D:
			bucket.body_entered.connect(_on_bucket_body_entered.bind(bucket_index))
			connected_count += 1
		bucket_index += 1
		
	print("Successfully connected ", connected_count, " buckets!")

func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)
	print("Score updated! New score is: ", score)

func _on_bucket_body_entered(body, bucket_index):
	print("BING! Something entered bucket number ", bucket_index)
	print("The object that entered is called: ", body.name)
	
	if body is RigidBody2D: 
		print("It's a valid RigidBody2D ball! Adding points...")
		add_score(10) 
		histogram.add_to_bucket(bucket_index)
	else:
		print("Wait, the object wasn't a RigidBody2D. No points added.")
