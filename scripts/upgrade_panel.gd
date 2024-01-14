extends Panel

@onready var btn_shot_speed_1: Button = $'Shot Speed 1'
@onready var btn_shot_speed_2: Button = $'Shot Speed 2'
@onready var btn_shot_speed_3: Button = $'Shot Speed 3'
@onready var btn_extra_shot_1: Button = $'Extra Shot 1'
@onready var btn_extra_shot_2: Button = $'Extra Shot 2'
@onready var btn_extra_jump: Button = $'Extra Jump'
@onready var btn_double_the_bats: Button = $'Double The Bats'
@onready var btn_quadruple_bats: Button = $'Quadruple Bats'
@onready var btn_all_the_bats: Button = $'All The Bats'

func _ready():
	button_setup(btn_shot_speed_1, Upgrades.shot_speed_1_cost, Upgrades.shot_speed_1)
	button_setup(btn_shot_speed_2, Upgrades.shot_speed_2_cost, Upgrades.shot_speed_2)
	button_setup(btn_shot_speed_3, Upgrades.shot_speed_3_cost, Upgrades.shot_speed_3)
	button_setup(btn_extra_shot_1, Upgrades.extra_shot_1_cost, Upgrades.extra_shot_1)
	button_setup(btn_extra_shot_2, Upgrades.extra_shot_2_cost, Upgrades.extra_shot_2)
	button_setup(btn_extra_jump, Upgrades.extra_jump_cost, Upgrades.extra_jump)
	button_setup(btn_double_the_bats, Upgrades.double_the_bats_cost, Upgrades.double_the_bats)
	button_setup(btn_quadruple_bats, Upgrades.quadruple_the_bats_cost, Upgrades.quadruple_the_bats)
	button_setup(btn_all_the_bats, Upgrades.all_the_bats_cost, Upgrades.quadruple_the_bats)

func button_setup(btn: Button, cost: int, bought : bool):
	if bought: set_button_bought(btn)
	else: btn.text = btn.text + " " + str(cost)

func buy(cost : int, btn : Button) -> bool:
	if cost <= Globals.coins:
		Globals.coins -= cost
		# Play Sound
		set_button_bought(btn)
		return true
	return false

func set_button_bought(button : Button):
	button.text = button.text + " bought"
	button.disabled = true

func _on_shot_speed_1_pressed() -> void:
	Upgrades.shot_speed_1 = buy(Upgrades.shot_speed_1_cost, 
	btn_shot_speed_1)

func _on_shot_speed_2_pressed() -> void:
	Upgrades.shot_speed_2 = buy(Upgrades.shot_speed_2_cost, 
	btn_shot_speed_2) 

func _on_shot_speed_3_pressed() -> void:
	Upgrades.shot_speed_3 = buy(Upgrades.shot_speed_3_cost, 
	btn_shot_speed_3) 


func _on_extra_shot_1_pressed() -> void:
	Upgrades.extra_shot_1 = buy(Upgrades.extra_shot_1_cost, 
	btn_extra_shot_1) 


func _on_extra_shot_2_pressed() -> void:
	Upgrades.extra_shot_2 = buy(Upgrades.extra_shot_2_cost, 
	btn_extra_shot_2) 


func _on_extra_jump_pressed() -> void:
	Upgrades.extra_jump = buy(Upgrades.extra_jump_cost, 
	btn_extra_jump) 

func _on_double_the_bats_pressed() -> void:
	Upgrades.double_the_bats = buy(Upgrades.double_the_bats_cost, 
	btn_double_the_bats) 
	
func _on_quadruple_bats_pressed() -> void:
	Upgrades.quadruple_the_bats = buy(Upgrades.quadruple_the_bats_cost, 
	btn_quadruple_bats) 

func _on_all_the_bats_pressed() -> void:
	Upgrades.all_the_bats = buy(Upgrades.all_the_bats_cost, 
	btn_all_the_bats) 
