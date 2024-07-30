extends CanvasLayer

@onready var timer_label: Label = %TimeLabel
@onready var meat_label: Label = %MeatLabel

var time_elapsed: float = 0.0
var meat_counter: int = 0

func _ready():
	GameManager.player.meat_collected.connect(on_meat_collected)
	
func _process(delta: float):
	# Update timer
	time_elapsed += delta
	#floor é para arredondar o numero, mas a floori arredonda para um int
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60 
	var minutes: int = time_elapsed_in_seconds / 60
	
	# Para formatar dessa maneira 02:59
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func on_meat_collected(regeneration_value: int):
	meat_counter += 1
	meat_label.text = str(meat_counter)
