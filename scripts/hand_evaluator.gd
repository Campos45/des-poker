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

# --- NOVO: Níveis atuais das mãos ---
static var hand_levels = {
	"Royal Flush": 1, "Straight Flush": 1, "Poker": 1,
	"Full House": 1, "Flush": 1, "Sequência (Straight)": 1,
	"Trio": 1, "Dois Pares": 1, "Um Par": 1, "Carta Alta": 1
}

# --- NOVO: A tua tabela de bónus por nível! ---
const UPGRADE_SCALING = {
	"Royal Flush": {"chips": 200, "mult": 15},
	"Straight Flush": {"chips": 100, "mult": 8},
	"Poker": {"chips": 50, "mult": 5},
	"Full House": {"chips": 40, "mult": 4},
	"Flush": {"chips": 30, "mult": 3},
	"Sequência (Straight)": {"chips": 25, "mult": 3},
	"Trio": {"chips": 20, "mult": 2},
	"Dois Pares": {"chips": 15, "mult": 2},
	"Um Par": {"chips": 10, "mult": 1},
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
	
static func calculate_score(hand_data: Dictionary) -> Dictionary:
	var hand_name = hand_data["name"]
	var scoring_cards = hand_data["scoring_cards"]
	
	var stats = HAND_BASE_STATS[hand_name]
	var level = hand_levels[hand_name]
	var upgrade_bonus = UPGRADE_SCALING[hand_name]
	
	# Fórmula mágica: Base + (Bónus * (Nível - 1))
	var total_chips = stats["chips"] + (upgrade_bonus["chips"] * (level - 1))
	var total_mult = stats["mult"] + (upgrade_bonus["mult"] * (level - 1))
	
	for card in scoring_cards:
		var card_val = RANK_VALUES[card.rank]
		
		if card_val > 10 and card_val < 14: total_chips += 10
		elif card_val == 14: total_chips += 11
		else: total_chips += card_val
			
		if card.is_special:
			total_mult += 1
			
	var final_score = total_chips * total_mult
	return {"chips": total_chips, "mult": total_mult, "total": final_score}

# FUNÇÃO NOVA: A Loja vai usar isto para subir as mãos de nível!
static func level_up_hand(hand_name: String):
	if hand_levels.has(hand_name):
		hand_levels[hand_name] += 1
# --- MOTOR DE INTELIGÊNCIA ARTIFICIAL (SEGUNDA MÃO) ---

# 1. Função que o jogo vai chamar para descobrir a melhor mão
static func find_best_hand(available_cards: Array) -> Dictionary:
	# Se sobrarem 5 ou menos cartas, não há muito a escolher, joga essas!
	if available_cards.size() <= 5:
		var eval = evaluate_5_card_hand(available_cards)
		var score = calculate_score(eval)
		eval["score_data"] = score
		return eval

	# Gera todas as combinações possíveis de 5 cartas
	var combos = get_combinations(available_cards, 5)
	var best_hand = {}
	var highest_score = -1

	# Testa uma por uma!
	for combo in combos:
		var eval = evaluate_5_card_hand(combo)
		var score = calculate_score(eval)
		
		# Se esta combinação der mais pontos que a anterior, passa a ser a favorita
		if score["total"] > highest_score:
			highest_score = score["total"]
			eval["score_data"] = score
			best_hand = eval

	return best_hand

# 2. Algoritmo para iniciar a geração de combinações
static func get_combinations(arr: Array, k: int) -> Array:
	var result = []
	_combine(arr, k, 0, [], result)
	return result

# 3. A Matemática Recursiva (O motor que faz as misturas)
static func _combine(arr: Array, k: int, start: int, current: Array, result: Array):
	if current.size() == k:
		result.append(current.duplicate())
		return
	for i in range(start, arr.size()):
		current.append(arr[i])
		_combine(arr, k, i + 1, current, result)
		current.pop_back()
		
