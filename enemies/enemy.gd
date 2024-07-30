class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab: PackedScene

@onready var damage_digit_marker = $DamageDigitMarker

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount: int):
	health -= amount
	print("Inimigo recebeu dano de ", amount,".A vida total e de", health)
	
	#Piscar inimigo
	modulate = Color.RED
	
	var tween = create_tween()
	#Qual sera o metodo da curva de modulacao
	tween.set_ease(Tween.EASE_IN)
	# Qual e a transicao
	tween.set_trans(Tween.TRANS_QUINT)
	# 4 parametros (qual objeto modificar, a propriedade q queremos modificar, valor final, duracao)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

# Criar DamageDigit
	var damage_digit_marker = $DamageDigitMarker
	var damage_digit =  damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	#Processar morte
	if health <= 0:
		die()

func die():
	#Criamos um prefab onde o objeto esta, se tiver um objeto instanciado
	if death_prefab:
		#Chamamos a prefab que e uma receita de bolo, mas passamos para uma nova variavel 
		# pois podemos ter difentes mortes
		var death_object = death_prefab.instantiate()
		#Colocar o objeto na mesma posicao que o inimigo esta agora
		death_object.position = position
		#Colocar o objeto na cena
		get_parent().add_child(death_object)
	
	#Destruimos essa entidade do inimigo
	queue_free()
