extends Node
class_name HandEvaluator

# Tradutor: Converte o nome da carta para um valor numérico para podermos ordenar
const RANK_VALUES = {
	"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,
	"Valete": 11, "Dama": 12, "Rei": 13, "As": 14
}

# Função estática (pode ser chamada de qualquer lado sem precisarmos de criar um Node)
static func evaluate_5_card_hand(cards: Array) -> String:
	var values = []
	var suits = []
	
	# Extrair valores e naipes
	for card in cards:
		values.append(RANK_VALUES[card.rank])
		suits.append(card.suit)
		
	# Ordenar os valores por ordem crescente (ex: 2, 4, 10, 11, 14)
	values.sort()
	
	# 1. Verificar se é Flush (todas as cartas do mesmo naipe)
	var is_flush = true
	var first_suit = suits[0]
	for s in suits:
		if s != first_suit:
			is_flush = false
			break
			
	# 2. Verificar se é Sequência (Straight)
	var is_straight = true
	for i in range(1, 5):
		if values[i] != values[i-1] + 1:
			# Exceção mágica do Poker: Sequência As, 2, 3, 4, 5
			if i == 4 and values[4] == 14 and values[0] == 2 and values[1] == 3 and values[2] == 4 and values[3] == 5:
				is_straight = true
			else:
				is_straight = false
				break
				
	# 3. Contar cartas repetidas (para Pares, Trios, Poker)
	var counts = {}
	for v in values:
		if counts.has(v):
			counts[v] += 1
		else:
			counts[v] = 1
			
	var pairs = 0
	var three_of_a_kind = 0
	var four_of_a_kind = 0
	
	for v in counts:
		if counts[v] == 2: pairs += 1
		if counts[v] == 3: three_of_a_kind += 1
		if counts[v] == 4: four_of_a_kind += 1

	# 4. Decidir qual é a mão (Ordem decrescente de importância)
	if is_straight and is_flush:
		if values[4] == 14 and values[3] == 13: # Acaba em As e Rei
			return "Royal Flush"
		return "Straight Flush"
		
	if four_of_a_kind == 1: return "Poker"
	if three_of_a_kind == 1 and pairs == 1: return "Full House"
	if is_flush: return "Flush"
	if is_straight: return "Sequência (Straight)"
	if three_of_a_kind == 1: return "Trio"
	if pairs == 2: return "Dois Pares"
	if pairs == 1: return "Um Par"
	
	return "Carta Alta"
