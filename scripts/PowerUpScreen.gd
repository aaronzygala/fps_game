extends PanelContainer


@onready var card_one = $MarginContainer/VBoxContainer/HBoxContainer/CardOne
@onready var card_two = $MarginContainer/VBoxContainer/HBoxContainer/CardTwo
@onready var card_three = $MarginContainer/VBoxContainer/HBoxContainer/CardThree
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func center_pivots(card):
	card.pivot_offset = Vector2(card.size.x/2, card.size.y/2)

func create_new_tween():
	var tween = create_tween()
	tween.set_parallel(true)
	return tween

func scale_card(tween, card, reset:bool):
	center_pivots(card)
	var button_scale = 1.05
	if reset:
		button_scale = 1.0 
	tween.tween_property(card, "scale", Vector2(button_scale, button_scale), 0.08)

func rotate_card(tween, card, left:bool, reset:bool):
	center_pivots(card)
	var button_rotation = 5
	if left: 
		button_rotation = -5
	if reset:
		button_rotation = 0
	tween.tween_property(card, "rotation", deg_to_rad(button_rotation), 0.08)

func _on_card_one_mouse_entered():
	var tween = create_new_tween()
	var left = true
	var reset = false
	#card_one.border_color.Color(0, 1, 0.5)
	scale_card(tween, card_one, reset)
	rotate_card(tween, card_one, left, reset)

func _on_card_one_mouse_exited():
	var tween = create_new_tween()
	var left = true
	var reset = true
	#card_one.border_color.Color(0, 1, 0.5)
	scale_card(tween, card_one, reset)
	rotate_card(tween, card_one, left, reset)

func _on_card_two_mouse_entered():
	var reset = false
	var tween = create_new_tween()
	#card_one.border_color.Color(0, 1, 0.5)
	scale_card(tween, card_two, reset)

func _on_card_two_mouse_exited():
	var tween = create_new_tween()
	var reset = true
	#card_one.border_color.Color(0, 1, 0.5)
	scale_card(tween, card_two, reset)

func _on_card_three_mouse_entered():
	var tween = create_new_tween()
	var reset = false
	var left = false
	#card_one.border_color.Color(0, 1, 0.5)
	scale_card(tween, card_three, reset)
	rotate_card(tween, card_three, left, reset)

func _on_card_three_mouse_exited():
	var tween = create_new_tween()
	var reset = true
	var left = false
	#card_one.border_color.Color(0, 1, 0.5)
	scale_card(tween, card_three, reset)
	rotate_card(tween, card_three, left, reset)
