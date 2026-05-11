extends Node


# Definimos as propriedades que uma Carta vai ter
class Card:
	var suit: String # Naipe (Copas, Espadas, etc)
	var rank: String # Valor (As, 2, 3... Rei)
	var is_special: bool # Se a carta é especial (os tais 30%)
	
	# Função para inicializar a carta
	func _init(s: String, r: String, special: bool):
		suit = s
		rank = r
		is_special = special

# Variáveis do nosso Baralho
var suits = ["Copas", "Ouros", "Paus", "Espadas"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Valete", "Dama", "Rei", "As"]
var deck = []

func _ready():
	randomize()
	create_deck()
	# print_deck_to_console() # Podes colocar um '#' antes desta linha para esconder o baralho todo da consola e não fazer spam
	
	# --- TESTE DO SPRINT 3 ---
	print("\n--- TESTE DE PONTUAÇÃO ---")
	var my_hand = []
	for i in range(5):
		my_hand.append(deck[i])
		
	var hand_text = "Mão jogada: "
	for card in my_hand:
		var special_mark = "⭐" if card.is_special else ""
		hand_text += "[" + card.rank + " " + card.suit + special_mark + "] "
	print(hand_text)
	
	# 1. Descobrir qual é a mão e as cartas que pontuam
	var hand_data = HandEvaluator.evaluate_5_card_hand(my_hand)
	print("Mão detetada: ", hand_data["name"])
	
	# Imprimir quais foram as cartas usadas para os pontos!
	var scoring_text = "Cartas que contaram: "
	for card in hand_data["scoring_cards"]:
		var special_mark = "⭐" if card.is_special else ""
		scoring_text += "[" + card.rank + special_mark + "] "
	print(scoring_text)
	
	# 2. Calcular os pontos
	var score_data = HandEvaluator.calculate_score(hand_data)
	print("Matemática: ", score_data["chips"], " Fichas X ", score_data["mult"], " Mult")
	print("PONTUAÇÃO FINAL DA RONDA: ", score_data["total"], " Pontos!")

func create_deck():
	deck.clear() # Limpa baralhos anteriores
	
	# Cria as 52 cartas
	for suit in suits:
		for rank in ranks:
			# Rola um dado virtual de 1 a 100. Se cair em 30 ou menos, é especial!
			var chance = randi() % 100 + 1
			var make_special = chance <= 30
			
			var new_card = Card.new(suit, rank, make_special)
			deck.append(new_card)
	
	# Baralha as cartas no final
	deck.shuffle()

# Apenas para testarmos se está a funcionar!
func print_deck_to_console():
	print("--- NOVO BARALHO GERADO ---")
	var especiais_count = 0
	
	for card in deck:
		var text = card.rank + " de " + card.suit
		if card.is_special:
			text += " (⭐ ESPECIAL)"
			especiais_count += 1
		print(text)
		
	print("Total de cartas: ", deck.size())
	print("Total de cartas especiais geradas nesta ronda: ", especiais_count)
