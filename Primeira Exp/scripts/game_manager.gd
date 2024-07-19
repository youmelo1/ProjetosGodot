extends Node

@export var object_templates: Array[PackedScene]

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				spawn_object(event.position)
		if event.button_index == 2:
			if event.pressed:
				spawn_bouncy_object(event.position)


func spawn_object(position):
	var object_template = object_templates[0]
	var object: RigidBody2D = object_template.instantiate()
	object.position = position
	add_child(object)
	
func spawn_bouncy_object(position):
	var object_template = object_templates[1]
	var object: RigidBody2D = object_template.instantiate()
	object.position = position
	add_child(object)
