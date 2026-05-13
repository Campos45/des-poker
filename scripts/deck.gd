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

@onready var player_display = $PlayerHandDisplay
@onready var community_display = $CommunityDisplay
@onready var play_button = $PlayButton
@onready var score_label = $ScoreLabel
@onready var next_round_button = $NextRoundButton
@onready var bank_label = $BankLabel # NOVA LINHA PARA A INTERFACE

var global_bank = 0 # NOVA VARIÁVEL: Guarda o total acumulado do jogo inteiro


func _ready():
	randomize()
	next_round_button.hide() 
	create_deck()
	spawn_game_table() 

func create_deck():
	deck.clear()
	for suit in suits:
		for rank in ranks:
			var chance = randi() % 100 + 1
			var make_special = chance <= 30
			var new_card = Card.new(suit, rank, make_special)
			deck.append(new_card)
	deck.shuffle()

func spawn_game_table():
	# 1. Distribuir 5 Cartas Comunitárias para a Mesa
	for i in range(5):
		var card_data = deck.pop_front() 
		var new_card_visual = CARD_VISUAL_SCENE.instantiate()
		community_display.add_child(new_card_visual)
		new_card_visual.setup_card(card_data)
		
	# 2. Distribuir 7 Cartas para a Mão do Jogador
	for i in range(7):
		var card_data = deck.pop_front()
		var new_card_visual = CARD_VISUAL_SCENE.instantiate()
		player_display.add_child(new_card_visual)
		new_card_visual.setup_card(card_data)

func _on_play_button_pressed():
	var selected_cards = []
	var remaining_cards = []
	
	# Analisar a prateleira do Jogador
	for card_visual in player_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			card_visual.queue_free() # Destrói as que jogaste
		else:
			remaining_cards.append(card_visual.card_data)
			
	# Analisar a prateleira da Mesa (Comunitárias)
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
		
	# --- PRIMEIRA MÃO ---
	var hand1_data = HandEvaluator.evaluate_5_card_hand(selected_cards)
	var score1_data = HandEvaluator.calculate_score(hand1_data)
	
	var final_text = "Primeira Mão: " + hand1_data["name"] + "\n"
	final_text += str(score1_data["chips"]) + " Fichas X " + str(score1_data["mult"]) + " Mult = " + str(score1_data["total"]) + "\n\n"
	
	# --- SEGUNDA MÃO (IA) ---
	var hand2_data = HandEvaluator.find_best_hand(remaining_cards)
	var score2_data = hand2_data["score_data"]
	
	final_text += "Segunda Mão (Auto): " + hand2_data["name"] + "\n"
	final_text += str(score2_data["chips"]) + " Fichas X " + str(score2_data["mult"]) + " Mult = " + str(score2_data["total"]) + "\n\n"
	
	# --- GRANDE TOTAL ---
	var grand_total = score1_data["total"] + score2_data["total"]
	final_text += "GRANDE TOTAL DA RONDA: " + str(grand_total) + " Pontos!"
	
	score_label.text = final_text
	
	# --- DEPOSITAR NO BANCO GLOBAL ---
	global_bank += grand_total
	bank_label.text = "Banco Global: " + str(global_bank)
	
	# Troca os botões
	play_button.hide()
	play_button.disabled = false 
	next_round_button.show()

func _on_next_round_button_pressed():
	# Destruir os restos de cartas antigas
	for card in player_display.get_children():
		card.queue_free()
	for card in community_display.get_children():
		card.queue_free()
		
	# Resetar a Interface
	score_label.text = "Pontuação: 0"
	next_round_button.hide()
	play_button.show()
	
	# Nova ronda
	create_deck()
	spawn_game_table()
