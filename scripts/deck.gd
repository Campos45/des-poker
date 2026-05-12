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

func _ready():
	randomize()
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

# Nova função de distribuir cartas (Substitui a antiga spawn_hand_visuals)
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

# Atualizar o botão para ler as duas prateleiras e destruir as cartas usadas
func _on_play_button_pressed():
	var selected_cards = []
	
	# Procurar cartas selecionadas na Mão do Jogador
	for card_visual in player_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			
	# Procurar cartas selecionadas nas Comunitárias
	for card_visual in community_display.get_children():
		if card_visual.is_selected:
			selected_cards.append(card_visual.card_data)
			
	# As regras mantêm-se: máximo 5 cartas no total
	if selected_cards.size() > 5:
		score_label.text = "Aviso: Seleciona no máximo 5 cartas combinadas!"
		return
	elif selected_cards.size() == 0:
		score_label.text = "Aviso: Seleciona pelo menos 1 carta!"
		return
		
	# 1. Calcular a Primeira Mão
	var hand_data = HandEvaluator.evaluate_5_card_hand(selected_cards)
	var score_data = HandEvaluator.calculate_score(hand_data)
	
	score_label.text = "Primeira Mão: " + hand_data["name"] + "\n"
	score_label.text += str(score_data["chips"]) + " Fichas X " + str(score_data["mult"]) + " Mult\n"
	score_label.text += "Total: " + str(score_data["total"]) + " Pontos!"
	
	# 2. DESTRUIR AS CARTAS USADAS DA MÃO DO JOGADOR
	for card_visual in player_display.get_children():
		if card_visual.is_selected:
			card_visual.queue_free() # Magia do Godot: Elimina o objeto do jogo!
			
	# 3. BAIXAR AS CARTAS COMUNITÁRIAS USADAS (Para não ficarem levantadas)
	for card_visual in community_display.get_children():
		if card_visual.is_selected:
			card_visual.toggle_selection()
			
	# 4. Desativar o botão para não podermos clicar outra vez nesta ronda
	play_button.disabled = true
