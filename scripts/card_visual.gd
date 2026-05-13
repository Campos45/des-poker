extends Control

var card_data = null
var is_selected = false

@onready var background = $ColorRect
@onready var text_label = $Label
@onready var button = $Button

# --- NOVO: O nosso dicionário com as descrições dos efeitos ---
const SPECIAL_DESCRIPTIONS = {
	# ... (mantém as anteriores) ...
	"Fichas Pesadas": "Dá +30 Fichas base, independentemente do valor da carta.",
	"Estrela Multiplicadora": "Dá +4 de Multiplicador.",
	"O Cilindro Par": "+5 Fichas por cada carta Par (2, 4, 6, 8, 10) que enviares na mesma jogada.",
	"A Sinergia": "+10 Fichas por cada outra carta vermelha na mão.",
	
	"Barris da Taverna": "Fica Bêbada: dá +15 de Mult mas debita -10 Fichas.",
	"A Solitária": "Dá +100 Fichas se for a ÚNICA carta a ser submetida na jogada.",
	"Dividendo Fixo": "Gera +1 Moeda para a tua Pontuação Total assim que pontuar.",
	"A Mealheiro": "Destrói-se para sempre ao ser jogada, mas deposita o seu valor em Moedas.",
	
	"Fundo de Emergência": "Se o teu Banco estiver abaixo de 2, dá +20 Fichas.",
	"Veterana de Serviço": "+5 Fichas por cada ronda passada desde que o jogo começou.",
	"Overclock": "Dobra o seu próprio valor de Fichas, mas tem 20% de chance de ser DESTRUÍDA.",
	"Gato Preto": "50% de probabilidade de dobrar os pontos totais da mão; 50% de os dividir a meio.",
	
	"Imposto de Retenção": "Reduz o multiplicador em -1, mas gera +3 Moedas.",
	"Blue Chip": "Custa 2 Moedas do teu banco. Se pagares, TRIPLICA o multiplicador base.",
	"Sensor BLE": "Ganha +1 de Mult por cada carta do seu naipe na Mesa Comunitária.",
	"Colheita Farta": "Se pontuar num Full House, dá 3 Moedas e gera 2 Cartas Especiais novas no teu Baralho."
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
