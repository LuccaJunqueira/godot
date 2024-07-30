class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
@export_category("Touch")
@export var touch_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("Life")
@export var health: int = 20
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var touch_area: Area2D = $TouchArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0,0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_colldown: float = 0.0
var hitbox_colldown: float = 0.0
var ritual_cooldown: float = 0.0 

# Signal avisa para todos quando pega uma carne por exemplo
signal meat_collection(value: int)

func _ready():
	GameManager.player = self
	
func _process(delta: float):
	GameManager.player_position = position
	
	read_input()
	
	#Processar attack
	update_attack_colldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	#Processar animacao e rotacao de sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
		
	#Processar dano
	update_hitbox_detection(delta)
	
	#Ritual
	update_ritual(delta)

func update_attack_colldown(delta: float):
	#Atualizar temporizador de ataque
	if is_attacking:
		attack_colldown -= delta
		if attack_colldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_ritual(delta: float):
	#Atualizar temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: 
		return
	ritual_cooldown = ritual_interval
	
	#Criar ritual			
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
func _physics_process(delta: float):
		
	#Modificar a  velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()
	
func read_input():
	#Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.15)
	
	#Apagar deadzone do input_vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0	
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0	
		
	#Atualizar o is_runnig
	was_running = is_running
	#se o valor de input vector nao for zero
	is_running = not input_vector.is_zero_approx()
	
func play_run_idle_animation():
	# Tocar animacao 
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite():
	#Girar Sprite
	if input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
	#com elif ele nao aceita que seja igual a 0, com else ele executaria direto 
	elif input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
						
func attack():
	#se ja estiver atacando ele retorna e nao segue com a func
	if is_attacking:
		return
	#attack_side
	#Tocar animacao 
	animation_player.play("attack_side")
	
	#Configurar temporizador
	attack_colldown = 0.6
	
	#Marcar attack
	is_attacking = true
	
func deal_damage_to_enemies():
	var bodies = touch_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.damage(touch_damage)
	#Acessar todos os inimigos
	
	#Chamar a funcao damage
	#Com touch_attack como primeiro parametro

func update_hitbox_detection(delta: float):
	#Temporizador
	hitbox_colldown -= delta
	if hitbox_colldown > 0: return
	
	#Frequencia (2x por segundo)
	hitbox_colldown = 0.5
	#HitBoxArea
	#Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 2
			damage(damage_amount)
	

func damage(amount: int):
	if health <= 0:
		return 
		
	health -= amount
	print("Player recebeu dano de ", amount,".A vida total e de", health)
	
	#Piscar inimigo
	modulate = Color.RED
	
	var tween = create_tween()
	#Qual sera o metodo da curva de modulacao
	tween.set_ease(Tween.EASE_IN)
	# Qual e a transicao
	tween.set_trans(Tween.TRANS_QUINT)
	# 4 parametros (qual objeto modificar, a propriedade q queremos modificar, valor final, duracao)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

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
	
	print("Player morreu!")
	#Destruimos essa entidade do inimigo
	queue_free()
	
func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ".  A vida total e de ", health, "/", max_health)
	return health


