extends Control

# Referências aos nós visuais que criámos
@onready var background = $ColorRect
@onready var text_label = $Label

# Esta função vai ser chamada pelo baralho para preencher a carta
func setup_card(card_data):
	# card_data é aquela classe "Card" que criaste no deck.gd
	
	# Construir o texto (ex: "As\nCopas") o \n faz parágrafo
	var display_text = card_data.rank + "\n" + card_data.suit
	
	if card_data.is_special:
		display_text += "\n⭐"
		background.color = Color(1, 0.9, 0.5) # Fica amarelada/dourada
	else:
		background.color = Color(1, 1, 1) # Fica branca
		
	text_label.text = display_text
	
	# Mudar a cor do texto dependendo do naipe
	if card_data.suit == "Copas" or card_data.suit == "Ouros":
		text_label.add_theme_color_override("font_color", Color(1, 0, 0)) # Vermelho
	else:
		text_label.add_theme_color_override("font_color", Color(0, 0, 0)) # Preto
