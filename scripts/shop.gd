extends Control

# Referência temporária ao banco do deck principal
var current_bank = 0

@onready var bank_label = $BankLabel

func _ready():
	# Lê o banco global do nó Main (assumindo que o Main ainda está na árvore)
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node:
		current_bank = main_node.global_bank
	update_ui()

func update_ui():
	bank_label.text = "Moedas: " + str(current_bank)

func try_buy_upgrade(hand_name: String, cost: int):
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node and current_bank >= cost:
		current_bank -= cost
		main_node.global_bank = current_bank # Atualiza o banco no jogo principal
		HandEvaluator.level_up_hand(hand_name)
		update_ui()
		print("Compraste upgrade para: ", hand_name)
	else:
		print("Sem dinheiro para ", hand_name)

func _on_pair_button_pressed():
	try_buy_upgrade("Um Par", 2)

func _on_straight_button_pressed():
	try_buy_upgrade("Sequência (Straight)", 3)

func _on_flush_button_pressed():
	try_buy_upgrade("Flush", 4)

func _on_back_button_pressed():
	# Fecha a loja (liberta esta cena)
	queue_free()