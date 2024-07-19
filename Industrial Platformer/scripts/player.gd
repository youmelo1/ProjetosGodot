extends CharacterBody2D


@export var SPEED = 3.0
@export_range(0,1) var lerp_factor = 0.125

@onready var sprite = %Sprite


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#velocity = direction * SPEED * 100
	
	# Linear Interpolation
	# L         ERP
	
	var target_velociy = direction * SPEED * 100
	
	velocity = lerp(velocity, target_velociy, lerp_factor)
	
	move_and_slide()
	
	var target_rotation = direction.x * 45
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rotation, lerp_factor)
	
	
	
