class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed = 3
@export_category("Sword")
@export var sword_damage = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar = $HealthProgressBar

var input_vector = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking = false
var attack_cooldown = 0.0
var hitbox_cooldown = 0.0
var ritual_cooldown = 0.0

signal meat_collected(value: int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): 
							GameManager.meat_counter+=1
													)

func _process(delta):
	GameManager.player_position = position
	
	#ler input
	read_input()
	
	#processar ataque
	update_attack_cooldown(delta)
	#ataque
	if Input.is_action_just_pressed("attack"):
		attack()

	#processar animação e rotação de sprite
	play_run_idle_animation()
	
	if not is_attacking:
		rotate_sprite()
		
	#processar dano
	update_hitbox_detection(delta)

	#ritual
	update_ritual(delta)
	
	# atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta):
	#modificar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()
	
	
func update_attack_cooldown(delta: float):
	#atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_ritual(delta: float):
	#atualizar temporizador
	ritual_cooldown -= delta
	
	if ritual_cooldown > 0: return
	
	#resetar o temporizador
	ritual_cooldown = ritual_interval
	
	#criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


func read_input():
	#obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
func attack():
	if is_attacking:
		return
		
	#tocar animação
	animation_player.play("attack_side_1")
	
	#configurar temporizador
	attack_cooldown = 0.6
	
	#marcar ataque
	is_attacking = true
	

func play_run_idle_animation():
	#tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
				
func rotate_sprite():
		#girar sprite
	if input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
	

func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position- position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.3:
				enemy.damage(sword_damage)
	

func update_hitbox_detection(delta):
	#temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	#frequencia (2x por segundo)
	hitbox_cooldown = 0.5
	
	#detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy = body
			var damage_amount = 1
			damage(damage_amount)


func damage(amount):
	if health <= 0: return
	
	health -= amount
	print("Jogador recebeu ", amount, " de dano. A vida total é: ", health)
	
	#piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE,  0.3)
	
	
	#processar morte
	if health <= 0:
		die()



func die():
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		scale.x = 3
		scale.y = 3
		death_object.scale = scale
		get_parent().add_child(death_object)
		
	print("Jogador morreu!")
	queue_free()

func heal(amount) -> int:
	health += amount
	if health > max_health:
		health = max_health
	
	print("Jogador recebeu ", amount, " de cura. A vida total é: ", health, "/", max_health)
	return health
