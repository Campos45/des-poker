extends Node

const CARD_VISUAL_SCENE = preload("res://scenes/card_visual.tscn")

class Card:
	var suit: String
	var rank: String
	var is_special: bool
	var special_type: String 
	
	func _init(s: String, r: String, special: bool, type: String = ""):
		suit = s
		rank = r
		is_special = special
		special_type = type

var suits = ["Copas", "Ouros", "Paus", "Espadas"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Valete", "Dama", "Rei", "As"]

var master_player_deck = [] 
var current_player_deck = [] 
var current_community_deck = [] 

@onready var player_display = $PlayerHandDisplay
@onready var community_display = $CommunityDisplay
@onready var play_button = $PlayButton
@onready var score_label = $ScoreLabel
@onready var next_round_button = $NextRoundButton
@onready var bank_label = $BankLabel 

var global_bank = 0 
var current_round = 1 


func _ready():
	randomize()
	next_round_button.hide() 
	generate_master_player_deck() 
	start_new_round()

# Cria o Baralho Permanente do Jogador com as novas cartas Especiais
func generate_master_player_deck():
	master_player_deck.clear()
	var math_specials = ["Fichas Pesadas", "Estrela Multiplicadora", "O Cilindro Par", "A Sinergia", "Barris da Taverna", "A Solitária", "Dividendo Fixo", "A Mealheiro", "Fundo de Emergência", "Veterana de Serviço", "Overclock", "Gato Preto"]
	
	for suit in suits:
		for rank in ranks:
			var chance = randi() % 100 + 1
			var make_special = chance <= 30
			var type = ""
			
			if make_special:
				type = math_specials[randi() % math_specials.size()]
				
			var new_card = Card.new(suit, rank, make_special, type)
			master_player_deck.append(new_card)

# Prepara os baralhos da mesa comunitária e clona o baralho do jogador			
func start_new_round():
	current_community_deck.clear()
	for suit in suits:
		for rank in ranks:
			current_community_deck.append(Card.new(suit, rank, false))
	current_community_deck.shuffle()
	
	current_player_deck = master_player_deck.duplicate()
	current_player_deck.shuffle()
	
	spawn_game_table()

# Desenha as cartas nas prateleiras
func spawn_game_table():
	# 1. Distribuir 5 Cartas Comunitárias Neutras
	for i in range(5):
		var card_data = current_community_deck.pop_front() 
		var new_card_visual = CARD_VISUAL_SCENE.instantiate()
		community_display.add_child(new_card_visual)
		new_card_visual.setup_card(card_data)
		
	# 2. Distribuir 7 Cartas do teu Baralho Especial
	for i in range(7):
		if current_player_deck.size() > 0: 
			var card_data = current_player_deck.pop_front()
			var new_card_visual = CARD_VISUAL_SCENE.instantiate()
			player_display.add_child(new_card_visual)
			new_card_visual.setup_card(card_data)

# O clique do Botão de Jogar
func _on_play_button_pressed():
	var selected_cards = []
	var remaining_cards = []
	
	# Verifica prateleira do Jogador (Cartas usadas são destruídas)
	for card_visual in player_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			card_visual.queue_free() 
		else:
			remaining_cards.append(card_visual.card_data)
			
	# Verifica prateleira da Mesa (Cartas comunitárias NÃO são destruídas)
	for card_visual in community_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			card_visual.toggle_selection() 
		remaining_cards.append(card_visual.card_data)
			
	# Validações das regras de jogo
	if selected_cards.size() > 5:
		score_label.text = "Aviso: Seleciona no máximo 5 cartas combinadas!"
		return
	elif selected_cards.size() == 0:
		score_label.text = "Aviso: Seleciona pelo menos 1 carta!"
		return
		
	# O pacote com as informações vitais do jogo neste momento
	var game_context = {"bank": global_bank, "round": current_round}
	
	var hand1_data = HandEvaluator.evaluate_5_card_hand(selected_cards)
	var score1_data = HandEvaluator.calculate_score(hand1_data, game_context) 
	
	
	var final_text = "Primeira Mão: " + hand1_data["name"] + " (Nv " + str(HandEvaluator.hand_levels[hand1_data["name"]]) + ")\n"
	final_text += str(score1_data["chips"]) + " Fichas X " + str(score1_data["mult"]) + " Mult = " + str(score1_data["total"]) + "\n\n"
	
	# IA avalia a 2ª Mão
	var hand2_data = HandEvaluator.find_best_hand(remaining_cards)
	var score2_data = hand2_data["score_data"]
	
	final_text += "Segunda Mão (Auto): " + hand2_data["name"] + " (Nv " + str(HandEvaluator.hand_levels[hand2_data["name"]]) + ")\n"
	final_text += str(score2_data["chips"]) + " Fichas X " + str(score2_data["mult"]) + " Mult = " + str(score2_data["total"]) + "\n\n"
	
	# Soma final
	# ...
	# --- SOMA E PROCESSAMENTO DE EFEITOS SECUNDÁRIOS ---
	var grand_total = score1_data["total"] + score2_data["total"]
	final_text += "GRANDE TOTAL DA RONDA: " + str(grand_total) + " Pontos!\n\n"
	
	# 1. Somar Dinheiro das Cartas Económicas
	var total_money = score1_data.get("money", 0) + score2_data.get("money", 0)
	if total_money > 0:
		global_bank += total_money
		bank_label.text = "Pontuação Total: " + str(global_bank)
		final_text += "🤑 Moedas Geradas no Banco: +" + str(total_money) + "\n"
		
	# 2. Executar a Destruição Permanente ("A Mealheiro")
	var all_destroyed_cards = score1_data.get("destroy", []) + score2_data.get("destroy", [])
	for bad_card in all_destroyed_cards:
		# Procura a carta idêntica no Baralho Mestre do Jogador e apaga-a para todo o sempre
		for m_card in master_player_deck:
			if m_card.suit == bad_card.suit and m_card.rank == bad_card.rank and m_card.special_type == bad_card.special_type:
				master_player_deck.erase(m_card)
				final_text += "🔥 " + bad_card.rank + " de " + bad_card.suit + " (" + bad_card.special_type + ") foi DESTRUÍDA para sempre!\n"
				break # Remove apenas a primeira cópia que encontrar
	
	score_label.text = final_text
	
	play_button.hide()
	play_button.disabled = false 
	next_round_button.show()

# O clique do botão Próxima Ronda
func _on_next_round_button_pressed():
	# Limpa o resto da mesa
	for card in player_display.get_children():
		card.queue_free()
	for card in community_display.get_children():
		card.queue_free()
		
	score_label.text = "Pontuação: 0"
	next_round_button.hide()
	play_button.show()
	
	current_round += 1 # Adiciona isto para as Veteranas de Serviço ficarem mais fortes!
	start_new_round()
