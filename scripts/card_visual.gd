extends Control

@onready var background = $ColorRect
@onready var text_label = $Label

var is_selected = false
var card_data = null 

func setup_card(data):
	card_data = data 
	
	var display_text = card_data.rank + "\n" + card_data.suit
	
	if card_data.is_special:
		display_text += "\n⭐"
		background.color = Color(1, 0.9, 0.5)
	else:
		background.color = Color(1, 1, 1)
		
	text_label.text = display_text
	
	if card_data.suit == "Copas" or card_data.suit == "Ouros":
		text_label.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		text_label.add_theme_color_override("font_color", Color(0, 0, 0))

# A nova função que o botão aciona automaticamente
func _on_button_pressed():
	toggle_selection()

func toggle_selection():
	is_selected = !is_selected 
	
	if is_selected:
		background.position.y -= 20
		text_label.position.y -= 20
	else:
		background.position.y += 20
		text_label.position.y += 20
