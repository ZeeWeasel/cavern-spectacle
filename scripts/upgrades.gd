extends Node

var shot_speed_1 : bool = false
var shot_speed_1_cost = 25

var shot_speed_2 : bool = false
var shot_speed_2_cost = 50

var shot_speed_3 : bool = false
var shot_speed_3_cost = 50

func shot_speed_bonus_total() -> float:
	var shot_speed_bonus : float = 0.0
	if shot_speed_1: shot_speed_bonus -= .05
	if shot_speed_2: shot_speed_bonus -= .05
	if shot_speed_3: shot_speed_bonus -= .05
	return shot_speed_bonus

var extra_shot_1 : bool = false
var extra_shot_1_cost = 100

var extra_shot_2 : bool = false
var extra_shot_2_cost = 100

func extra_shots() -> int:
	if extra_shot_2: return 2
	elif extra_shot_1: return 1
	else: return 0 

var extra_jump : bool = false
var extra_jump_cost = 20

func extra_jumps() -> int:
	if extra_jump: return 1
	return 0

var double_the_bats : bool = false
var double_the_bats_cost = -50

var quadruple_the_bats : bool = false
var quadruple_the_bats_cost = -50

var all_the_bats : bool = false
var all_the_bats_cost = -100

func bat_multiplier() -> int:
	if all_the_bats: return 8
	if quadruple_the_bats: return 4
	if double_the_bats: return 2
	return 1

