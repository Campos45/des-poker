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
	# O _ready() corre assim que o jogo começa.
	randomize() # Garante que a aleatoriedade é diferente em cada jogo
	create_deck()
	print_deck_to_console()

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
