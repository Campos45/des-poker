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

static var hand_levels = {
	"Royal Flush": 1, "Straight Flush": 1, "Poker": 1,
	"Full House": 1, "Flush": 1, "Sequência (Straight)": 1,
	"Trio": 1, "Dois Pares": 1, "Um Par": 1, "Carta Alta": 1
}

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
	var num_cards = cards.size() 
	
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

	var hand_name = "Carta Alta"
	var scoring_cards = []
	
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
			var highest_val = values[num_cards - 1]
			for c in cards:
				if RANK_VALUES[c.rank] == highest_val:
					scoring_cards.append(c)
					break 
					
	# Retornamos a mão, as cartas que pontuam, e todas as que foram jogadas
	return {"name": hand_name, "scoring_cards": scoring_cards, "all_played_cards": cards}

# Adicionámos "context" para a função saber o dinheiro e a ronda
static func calculate_score(hand_data: Dictionary, context: Dictionary = {"bank": 0, "round": 1, "community": []}) -> Dictionary:
	var hand_name = hand_data["name"]
	var scoring_cards = hand_data["scoring_cards"]
	var all_played_cards = hand_data["all_played_cards"]
	
	var stats = HAND_BASE_STATS[hand_name]
	var level = hand_levels[hand_name]
	var upgrade_bonus = UPGRADE_SCALING[hand_name]
	
	var total_chips = stats["chips"] + (upgrade_bonus["chips"] * (level - 1))
	var total_mult = stats["mult"] + (upgrade_bonus["mult"] * (level - 1))
	
	var even_cards_count = 0
	var red_cards_count = 0
	var money_earned = 0
	var cards_to_destroy = []
	var cards_to_create = 0 # NOVA: Quantas cartas novas vamos gerar?
	var has_black_cat = false
	
	for c in all_played_cards:
		var val = RANK_VALUES[c.rank]
		if val % 2 == 0 and val <= 10: 
			even_cards_count += 1
		if c.suit == "Copas" or c.suit == "Ouros": 
			red_cards_count += 1
	
	for card in scoring_cards:
		var card_val = RANK_VALUES[card.rank]
		var numeric_value = card_val
		
		if card_val > 10 and card_val < 14: numeric_value = 10
		elif card_val == 14: numeric_value = 11
		
		total_chips += numeric_value
			
		if card.is_special:
			total_mult += 1 
			match card.special_type:
				"Fichas Pesadas": total_chips += 30
				"Estrela Multiplicadora": total_mult += 4 
				"O Cilindro Par": total_chips += (5 * even_cards_count)
				"A Sinergia": total_chips += (10 * red_cards_count)
				"Barris da Taverna":
					total_mult += 15
					total_chips -= 10
				"A Solitária":
					if all_played_cards.size() == 1: total_chips += 100
				"Dividendo Fixo": money_earned += 1
				"A Mealheiro":
					money_earned += numeric_value
					cards_to_destroy.append(card)
				"Fundo de Emergência":
					if context["bank"] < 2: total_chips += 20
				"Veterana de Serviço": total_chips += (5 * context["round"])
				"Overclock":
					total_chips += numeric_value 
					if randf() <= 0.20: cards_to_destroy.append(card)
				"Gato Preto": has_black_cat = true
				
				# --- AS NOVAS CARTAS ---
				"Imposto de Retenção":
					total_mult = max(1, total_mult - 1) # Impede que o multiplicador vá abaixo de 1
					money_earned += 3
				"Blue Chip":
					if context["bank"] >= 2:
						money_earned -= 2 # Gasta 2 moedas
						total_mult *= 3   # Triplica!
				"Sensor BLE":
					var matches = 0
					# Lê as cartas da mesa comunitária
					if context.has("community"):
						for comm_card in context["community"]:
							if comm_card.suit == card.suit:
								matches += 1
					total_mult += matches
				"Colheita Farta":
					if hand_name == "Full House":
						money_earned += 3
						cards_to_create += 2 # Dá ordem para gerar 2 cartas!
	
	if total_chips < 0: total_chips = 0
	var final_score = total_chips * total_mult
	
	if has_black_cat:
		if randf() <= 0.50: final_score *= 2 
		else: final_score /= 2 
	
	# Retornamos também as "cards_to_create"
	return {
		"chips": total_chips, 
		"mult": total_mult, 
		"total": int(final_score), 
		"money": money_earned, 
		"destroy": cards_to_destroy,
		"create": cards_to_create 
	}
	
static func level_up_hand(hand_name: String):
	if hand_levels.has(hand_name):
		hand_levels[hand_name] += 1

static func find_best_hand(available_cards: Array, context: Dictionary = {"bank": 0, "round": 1}) -> Dictionary:
	if available_cards.size() <= 5:
		var eval = evaluate_5_card_hand(available_cards)
		var score = calculate_score(eval, context) # Adicionado o context aqui
		eval["score_data"] = score
		return eval

	var combos = get_combinations(available_cards, 5)
	var best_hand = {}
	var highest_score = -1

	for combo in combos:
		var eval = evaluate_5_card_hand(combo)
		var score = calculate_score(eval, context) # Adicionado o context aqui
		
		if score["total"] > highest_score:
			highest_score = score["total"]
			eval["score_data"] = score
			best_hand = eval

	return best_hand

static func get_combinations(arr: Array, k: int) -> Array:
	var result = []
	_combine(arr, k, 0, [], result)
	return result

static func _combine(arr: Array, k: int, start: int, current: Array, result: Array):
	if current.size() == k:
		result.append(current.duplicate())
		return
	for i in range(start, arr.size()):
		current.append(arr[i])
		_combine(arr, k, i + 1, current, result)
		current.pop_back()
