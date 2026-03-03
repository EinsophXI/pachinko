extends Node2D

var score = 0
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var buckets = $"Score Buckets"

func _ready():
	score_label.text = "Score: 0"
	
	for bucket in buckets.get_children():
		if bucket is Area2D:
			bucket.body_entered.connect(_on_bucket_body_entered)

func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)

func _on_bucket_body_entered(body):
	if body is RigidBody2D:
		add_score(10)
