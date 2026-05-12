extends Node
class_name HandEvaluator

const RANK_VALUES = {
	"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,
	"Valete": 11, "Dama": 12, "Rei": 13, "As": 14
}

const HAND_BASE_STATS = {
	"Royal Flush": {"chips": 100, "mult": 8},
	"Straight Flush": {"chips": 100, "mult": 8},
	"Poker": {"chips": 60, "mult": 7},
	"Full House": {"chips": 40, "mult": 4},
	"Flush": {"chips": 35, "mult": 4},
	"Sequência (Straight)": {"chips": 30, "mult": 4},
	"Trio": {"chips": 30, "mult": 3},
	"Dois Pares": {"chips": 20, "mult": 2},
	"Um Par": {"chips": 10, "mult": 2},
	"Carta Alta": {"chips": 5, "mult": 1}
}
static func evaluate_5_card_hand(cards: Array) -> Dictionary:
	var values = []
	var suits = []
	
	for card in cards:
		values.append(RANK_VALUES[card.rank])
		suits.append(card.suit)
		
	values.sort()
	var num_cards = cards.size() # Descobre quantas cartas foram jogadas!
	
	# Verificações de Flush e Sequência (SÓ OCORREM SE HOUVER EXATAMENTE 5 CARTAS)
	var is_flush = false
	var is_straight = false
	
	if num_cards == 5:
		is_flush = true
		var first_suit = suits[0]
		for s in suits:
			if s != first_suit:
				is_flush = false
				break
				
		is_straight = true
		for i in range(1, 5):
			if values[i] != values[i-1] + 1:
				if i == 4 and values[4] == 14 and values[0] == 2 and values[1] == 3 and values[2] == 4 and values[3] == 5:
					is_straight = true
				else:
					is_straight = false
					break
			
	# Contar as repetições para Pares, Trios e Poker (Funciona para qualquer número de cartas)
	var counts = {}
	for v in values:
		if counts.has(v): counts[v] += 1
		else: counts[v] = 1
			
	var pair_values = []
	var trio_value = -1
	var quad_value = -1
	
	for v in counts:
		if counts[v] == 2: pair_values.append(v)
		if counts[v] == 3: trio_value = v
		if counts[v] == 4: quad_value = v

	# Preparar a resposta
	var hand_name = "Carta Alta"
	var scoring_cards = []
	
	# Determinar a mão e separar APENAS as cartas que pontuam
	if is_straight and is_flush:
		if values[4] == 14 and values[3] == 13:
			hand_name = "Royal Flush"
		else:
			hand_name = "Straight Flush"
		scoring_cards = cards.duplicate()
		
	elif quad_value != -1:
		hand_name = "Poker"
		for c in cards:
			if RANK_VALUES[c.rank] == quad_value: scoring_cards.append(c)
			
	elif trio_value != -1 and pair_values.size() == 1:
		hand_name = "Full House"
		scoring_cards = cards.duplicate()
		
	elif is_flush:
		hand_name = "Flush"
		scoring_cards = cards.duplicate()
		
	elif is_straight:
		hand_name = "Sequência (Straight)"
		scoring_cards = cards.duplicate()
		
	elif trio_value != -1:
		hand_name = "Trio"
		for c in cards:
			if RANK_VALUES[c.rank] == trio_value: scoring_cards.append(c)
			
	elif pair_values.size() >= 2:
		hand_name = "Dois Pares"
		for c in cards:
			if RANK_VALUES[c.rank] in pair_values: scoring_cards.append(c)
			
	elif pair_values.size() == 1:
		hand_name = "Um Par"
		for c in cards:
			if RANK_VALUES[c.rank] in pair_values: scoring_cards.append(c)
			
	else:
		hand_name = "Carta Alta"
		if num_cards > 0:
			var highest_val = values[num_cards - 1] # Vai buscar a última carta (a maior) independentemente do tamanho da lista
			for c in cards:
				if RANK_VALUES[c.rank] == highest_val:
					scoring_cards.append(c)
					break 
					
	return {"name": hand_name, "scoring_cards": scoring_cards}
	
# A nossa matemática agora só recebe o dicionário gerado em cima
static func calculate_score(hand_data: Dictionary) -> Dictionary:
	var hand_name = hand_data["name"]
	var scoring_cards = hand_data["scoring_cards"]
	
	var stats = HAND_BASE_STATS[hand_name]
	var total_chips = stats["chips"]
	var total_mult = stats["mult"]
	
	# Só passamos pelas cartas que de facto pontuam!
	for card in scoring_cards:
		var card_val = RANK_VALUES[card.rank]
		
		if card_val > 10 and card_val < 14: total_chips += 10
		elif card_val == 14: total_chips += 11
		else: total_chips += card_val
			
		if card.is_special:
			total_mult += 1
			
	var final_score = total_chips * total_mult
	return {"chips": total_chips, "mult": total_mult, "total": final_score}
