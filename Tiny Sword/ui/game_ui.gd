extends CanvasLayer

@onready var timer_label= %TimerLabel
@onready var meat_label = %MeatLabel


func _process(delta):
	#update labels
	timer_label.text = GameManager.elapsed_time_string
	meat_label.text = str(GameManager.meat_counter)
