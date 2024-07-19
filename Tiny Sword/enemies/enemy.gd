class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digiti_prefab: PackedScene

@onready var damage_digit_marker = $DamageDigitMarker

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

func _ready():
	damage_digiti_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount):
	health -= amount
	print("Inimigo levou ", amount, " de dano. A vida total é: ", health)
	
	#piscar node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE,  0.3)
	
	#criar DamageDigit
	
	var damage_digit = damage_digiti_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	#processar morte
	if health <= 0:
		die()
		
func die():
	#caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		death_object.scale = scale
		get_parent().add_child(death_object)
		
		
	#drop
	if randf() <= drop_chance:
		drop_item()
		
	#incrementar contador
	GameManager.monsters_defeated_counter += 1
	
	#deletar node
	queue_free()

func drop_item():
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	drop.scale = scale
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	#listas com 1 item
	if drop_items.size() == 1:
		return drop_items[0]
	
	#calcular chance maxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
		
	#jogar dado
	var random_value = randf() * max_chance
	
	#girar a roleta
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
		
	return drop_items[0]
