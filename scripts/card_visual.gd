extends Control

var card_data = null
var is_selected = false

@onready var background = $ColorRect
@onready var text_label = $Label
@onready var button = $Button

# --- NOVO: O nosso dicionário com as descrições dos efeitos ---
const SPECIAL_DESCRIPTIONS = {
	"Fichas Pesadas": "Dá +30 Fichas base, independentemente do valor da carta.",
	"Estrela Multiplicadora": "Dá +4 de Multiplicador.",
	"O Cilindro Par": "+5 Fichas por cada carta Par (2, 4, 6, 8, 10) que enviares na mesma jogada.",
	"A Sinergia": "+10 Fichas por cada outra carta vermelha na mão."
}

func setup_card(data):
	card_data = data 
	
	var display_text = card_data.rank + "\n" + card_data.suit
	
	if card_data.is_special:
		display_text += "\n⭐\n" + card_data.special_type
		background.color = Color(1, 0.9, 0.5)
		
		# Procura a descrição no dicionário e aplica-a ao Botão
		if SPECIAL_DESCRIPTIONS.has(card_data.special_type):
			button.tooltip_text = SPECIAL_DESCRIPTIONS[card_data.special_type]
		else:
			button.tooltip_text = "Efeito desconhecido."
	else:
		background.color = Color(1, 1, 1)
		button.tooltip_text = "" # Limpa qualquer texto, porque as normais não têm descrição
		
	text_label.text = display_text
	
	# Pinta as copas e ouros de vermelho
	if card_data.suit == "Copas" or card_data.suit == "Ouros":
		text_label.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		text_label.add_theme_color_override("font_color", Color(0, 0, 0))

func _on_button_pressed():
	toggle_selection()

func toggle_selection():
	is_selected = !is_selected
	if is_selected:
		position.y -= 20
	else:
		position.y += 20
