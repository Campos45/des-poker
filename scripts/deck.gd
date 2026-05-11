extends Node

# Carregamos a cena visual que criaste para podermos criar cópias dela
const CARD_VISUAL_SCENE = preload("res://scenes/card_visual.tscn")

class Card:
	var suit: String
	var rank: String
	var is_special: bool
	
	func _init(s: String, r: String, special: bool):
		suit = s
		rank = r
		is_special = special

var suits = ["Copas", "Ouros", "Paus", "Espadas"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Valete", "Dama", "Rei", "As"]
var deck = []

# Referência ao contentor que criaste na cena Main
@onready var card_display = $CardDisplay

func _ready():
	randomize()
	create_deck()
	spawn_hand_visuals()

func create_deck():
	deck.clear()
	for suit in suits:
		for rank in ranks:
			var chance = randi() % 100 + 1
			var make_special = chance <= 30
			var new_card = Card.new(suit, rank, make_special)
			deck.append(new_card)
	deck.shuffle()

# Esta função faz a magia de colocar as cartas no ecrã
func spawn_hand_visuals():
	# Tiramos 5 cartas do baralho
	var my_hand = []
	for i in range(5):
		my_hand.append(deck[i])
	
	# Para cada uma dessas 5 cartas:
	# Para cada uma dessas 5 cartas:
	for card_data in my_hand:
		# 1. Criamos uma instância da cena visual
		var new_card_visual = CARD_VISUAL_SCENE.instantiate()
		
		# 2. Adicionamo-la como filha do HBoxContainer (para ficar alinhada)
		card_display.add_child(new_card_visual)
		
		# 3. Passamos os dados (rank, suit, especial) para o script da carta
		new_card_visual.setup_card(card_data) # <--- A TUA LINHA 55 DEVE SER ESTA
	
	# Opcional: Mostrar também a pontuação na consola para confirmar
	var hand_data = HandEvaluator.evaluate_5_card_hand(my_hand)
	var score_data = HandEvaluator.calculate_score(hand_data)
	print("Mão Visualizada: ", hand_data["name"], " | Pontos: ", score_data["total"])
