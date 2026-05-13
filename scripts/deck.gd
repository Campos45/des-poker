extends Node

const CARD_VISUAL_SCENE = preload("res://scenes/card_visual.tscn")

class Card:
	var suit: String
	var rank: String
	var is_special: bool
	# Preparado para o futuro: vai guardar o nome da carta especial (ex: "A Mealheiro")
	var special_type: String 
	
	func _init(s: String, r: String, special: bool, type: String = ""):
		suit = s
		rank = r
		is_special = special
		special_type = type

var suits = ["Copas", "Ouros", "Paus", "Espadas"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Valete", "Dama", "Rei", "As"]

# --- NOVAS VARIÁVEIS DE BARALHO ---
var master_player_deck = [] # O baralho que te pertence. Só muda se destruíres/ganhares cartas permanentemente.
var current_player_deck = [] # A cópia baralhada que usas na ronda atual.
var current_community_deck = [] # O baralho neutro da mesa (renovado a cada ronda).

@onready var player_display = $PlayerHandDisplay
@onready var community_display = $CommunityDisplay
@onready var play_button = $PlayButton
@onready var score_label = $ScoreLabel
@onready var next_round_button = $NextRoundButton

func _ready():
	randomize()
	next_round_button.hide() 
	generate_master_player_deck() # Cria o teu baralho inicial 1 vez por jogo
	start_new_round()

# 1. Cria o Baralho Permanente do Jogador (No início do jogo)
func generate_master_player_deck():
	master_player_deck.clear()
	for suit in suits:
		for rank in ranks:
			var chance = randi() % 100 + 1
			var make_special = chance <= 30
			# Por enquanto são especiais genéricas, mais tarde atribuímos os nomes aqui
			var new_card = Card.new(suit, rank, make_special, "Generica")
			master_player_deck.append(new_card)

# 2. Prepara e distribui as cartas para uma nova ronda
func start_new_round():
	# Renova o baralho comunitário do zero (sem cartas especiais)
	current_community_deck.clear()
	for suit in suits:
		for rank in ranks:
			current_community_deck.append(Card.new(suit, rank, false))
	current_community_deck.shuffle()
	
	# Clona o teu baralho mestre para esta ronda e baralha
	# (Assim manténs as tuas cartas, mas a ordem é nova)
	current_player_deck = master_player_deck.duplicate()
	current_player_deck.shuffle()
	
	spawn_game_table()

func spawn_game_table():
	# 1. Distribuir 5 Cartas Comunitárias Neutras
	for i in range(5):
		var card_data = current_community_deck.pop_front() 
		var new_card_visual = CARD_VISUAL_SCENE.instantiate()
		community_display.add_child(new_card_visual)
		new_card_visual.setup_card(card_data)
		
	# 2. Distribuir 7 Cartas do teu Baralho Especial
	for i in range(7):
		if current_player_deck.size() > 0: # Prevenção: caso o baralho fique pequeno
			var card_data = current_player_deck.pop_front()
			var new_card_visual = CARD_VISUAL_SCENE.instantiate()
			player_display.add_child(new_card_visual)
			new_card_visual.setup_card(card_data)

func _on_play_button_pressed():
	var selected_cards = []
	var remaining_cards = []
	
	for card_visual in player_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			card_visual.queue_free() 
		else:
			remaining_cards.append(card_visual.card_data)
			
	for card_visual in community_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			card_visual.toggle_selection() 
		remaining_cards.append(card_visual.card_data)
			
	if selected_cards.size() > 5:
		score_label.text = "Aviso: Seleciona no máximo 5 cartas combinadas!"
		return
	elif selected_cards.size() == 0:
		score_label.text = "Aviso: Seleciona pelo menos 1 carta!"
		return
		
	var hand1_data = HandEvaluator.evaluate_5_card_hand(selected_cards)
	var score1_data = HandEvaluator.calculate_score(hand1_data)
	
	var final_text = "Primeira Mão: " + hand1_data["name"] + "\n"
	final_text += str(score1_data["chips"]) + " Fichas X " + str(score1_data["mult"]) + " Mult = " + str(score1_data["total"]) + "\n\n"
	
	var hand2_data = HandEvaluator.find_best_hand(remaining_cards)
	var score2_data = hand2_data["score_data"]
	
	final_text += "Segunda Mão (Auto): " + hand2_data["name"] + "\n"
	final_text += str(score2_data["chips"]) + " Fichas X " + str(score2_data["mult"]) + " Mult = " + str(score2_data["total"]) + "\n\n"
	
	var grand_total = score1_data["total"] + score2_data["total"]
	final_text += "GRANDE TOTAL DA RONDA: " + str(grand_total) + " Pontos!"
	
	score_label.text = final_text
	
	play_button.hide()
	play_button.disabled = false 
	next_round_button.show()

func _on_next_round_button_pressed():
	for card in player_display.get_children():
		card.queue_free()
	for card in community_display.get_children():
		card.queue_free()
		
	score_label.text = "Pontuação: 0"
	next_round_button.hide()
	play_button.show()
	
	# Inicia uma nova ronda clonando o teu master_deck atualizado
	start_new_round()
