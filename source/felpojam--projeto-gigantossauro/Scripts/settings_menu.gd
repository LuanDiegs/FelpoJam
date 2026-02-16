extends Control

#Variaveis
@export var master_volume_slider : HSlider
@export var music_volume_slider : HSlider
@export var sfx_volume_slider : HSlider
@export var master_percent_label : Label
@export var music_percent_label : Label
@export var sfx_percent_label : Label

#Função para a mudança de volume
func volume_changed(valor: float, indice_bus: int):
	
	#Seta o volume do bus indicado que foi convertido de linear para dbs
	AudioServer.set_bus_volume_db(indice_bus, linear_to_db(valor))

#Função que atualiza o label de porcentagem de volume
func update_label(label, Linear_valor: float):
	
	#ARmazena a porcentagem do volume
	var percent = round(Linear_valor * 100)
	#Muda o texto do label
	label.text = str(percent) + "%"

#Função para configuração inicial do sliders
func setup_slider(slider: HSlider, label: Label, bus_name: String):
	
	#Salva o index do bus 
	var bus_idx = AudioServer.get_bus_index(bus_name)
	#Checa se o idx do bus não é invalido
	if bus_idx == -1:
		#Emitir o erro que o bus não foi encontrado
		push_error("ERRO: Bus", bus_name, " não encontrada!")
		return #retorna o codigo

	#Define o valor inicial do slider
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	#Atualiza o valor do slide no label
	update_label(label, slider.value)
	
	#Conecta o sinal de mudança do volume
	slider.value_changed.connect(func(valor):
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(valor)) #Faz a mudança em "tempo real no db do bus deo audio
		update_label(label, valor) #Faz a mudança em "tempo real" no valor do label
	)

#Função que roda ao iniciar o nó/cena
func _ready() -> void:
	#Setando a configuração inicial de todos os sliders
	setup_slider(master_volume_slider, master_percent_label, "Master")
	setup_slider(music_volume_slider, music_percent_label, "Music")
	setup_slider(sfx_volume_slider, sfx_percent_label, "Effects")

#Função que executa ao pressionar o botão de voltar para o menu
func _on_settings_button_pressed() -> void:
	#MUda para a ceno do menu principal
	get_tree().change_scene_to_file(Global.start_menu)
