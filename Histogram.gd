extends HBoxContainer

@export var max_bar_height: float = 200.0 

var bucket_counts: Array[int] = []

func _ready():
	# Sizes the array to 14 based on your 14 ColorRects
	bucket_counts.resize(get_child_count())
	bucket_counts.fill(0)
	_update_bars()

# This is the function your main script was looking for!
func add_to_bucket(bucket_index: int):
	if bucket_index >= 0 and bucket_index < bucket_counts.size():
		bucket_counts[bucket_index] += 1
		_update_bars()

func _update_bars():
	var highest_count = bucket_counts.max()
	
	for i in range(get_child_count()):
		var bar = get_child(i) as ColorRect
		
		# --- NEW CODE: Update the Label ---
		# This grabs the Label (which is the first child of the ColorRect)
		var label = bar.get_child(0) as Label
		if label:
			label.text = str(bucket_counts[i]) # Changes the text to the current count
		# ----------------------------------
		
		if highest_count > 0:
			var height_ratio = float(bucket_counts[i]) / float(highest_count)
			bar.custom_minimum_size.y = height_ratio * max_bar_height
		else:
			bar.custom_minimum_size.y = 0
