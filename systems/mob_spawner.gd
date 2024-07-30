extends Node2D

@export var mobs_per_minute: float = 60.0
@export var creatures: Array[PackedScene]
var cooldown : float = 0.0

@onready var path_follow_2d : PathFollow2D = %PathFollow2D

func _ready():
	pass

func _process(delta: float):
	#Temporizador (cooldown)
	cooldown -= delta
	if cooldown > 0: return 
	
	#Frequencia: Monstros por minuto
	# 60 monstros/minuto = 1 monstro por segundo	
	# 120 monstros/minuto = 2 monstro por segundo
	# intervalo em segundos entre monstros = 60 / frequencia
	# 60 / 60 = 1
	# 60 / 120 = 0.5
	# 60 / 30 = 2
	# interval = 60 / mobs_per_minute
	var interval = 60.0 / mobs_per_minute 
	cooldown = interval
	
	#Instanciar uma criatura aleatoria
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	#usamos a global positions pois assimm temos exatamente a posicao do progress_ratio do follow 2d que escolhemos 
	# e nao a posicao baseada a partir daquele elemento especifico ex: -5555 da posicao do mob spawner
	# com global pegamos examente aquela posicao sem se basear em nenhum node como referencia
	creature.global_position = get_point()
	get_parent().add_child(creature)
	#- pegar criatura aleatoria 
	#- pegar ponto aleatorio
	#- instanciar cena
	#- colocar na posicao certa
	pass
	
func get_point():
	path_follow_2d.progress_ratio = randf() #random float entre 0.0 e 1.0
	return path_follow_2d.global_position
