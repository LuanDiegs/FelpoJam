extends Control

#Variaveis audio settings
@export var master_volume_slider : HSlider
@export var music_volume_slider : HSlider
@export var sfx_volume_slider : HSlider
@export var master_percent_label : Label
@export var music_percent_label : Label
@export var sfx_percent_label : Label

#VAriaveis video settings
@export var resolution_option : OptionButton
@export var mode_option : OptionButton

#Biblioteca de resoluções
var base_resolutions = [
	Vector2i(3840, 2160), #4K
	Vector2i(2566, 1440), #2K
	Vector2i(1920, 1080), #FullHD
	Vector2i(1600, 900),
	Vector2i(1366, 768), #Comum em Laptops
	Vector2i(1280, 720), #HD
	Vector2i(1024, 576),
	Vector2i(960, 540),
	Vector2i(854, 480), #SD
	Vector2i(800, 450),
	Vector2i(720, 405),
	Vector2i(640, 360),
	Vector2i(560, 315),
	Vector2i(480, 270),
	Vector2i(400, 225),
	Vector2i(320, 180)
]

var available_resolutions = []

#region Funções de Audio
#Função para a mudança de volume
func volume_changed(valor: float, indice_bus: int):
	#Seta o volume do bus indicado que foi convertido de linear para dbs
	AudioServer.set_bus_volume_db(indice_bus, linear_to_db(valor))

#Função que atualiza o label de porcentagem de volume
func update_label(label, Linear_valor: float):
	#Armazena a porcentagem do volume
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
#endregion

#region Funções de Video

#Função para centralizar a janela
func center_window():
	
	#Cria um timer de 1 frame para garantir que o posicionamente foi aplicado
	await get_tree().process_frame
	
	#Obtem a area util da tela (desconsidera a barra de tarefas)
	var screen_rect = DisplayServer.screen_get_usable_rect()
	var window_size = DisplayServer.window_get_size() #salva o tamanho da janela
	#Calula a posição centralizada dentro da area util da tela
	var new_pos = Vector2i(
		screen_rect.position.x + (screen_rect.size.x - window_size.x) / 2,
		screen_rect.position.y + (screen_rect.size.y - window_size.y) /2
	)
	
	#GArante que a posição não seja negativa
	new_pos.x = max(new_pos.x, 0)
	new_pos.y = max(new_pos.y, 0)
	
	#Aplica a nova posição da janela
	DisplayServer.window_set_position(new_pos)

#Função de configuração inicial da resolução
func setup_resolutions():
	
	#Pega a resoluyção maxima da tela principal
	var screen_size = DisplayServer.screen_get_size()
	var max_width = screen_size.x
	var max_height = screen_size.y
	
	#Fitra as resoluõções que cabem na tela do jogador
	for res in base_resolutions:
		if res.x <= max_width and res.y <= max_height:
			available_resolutions.append(res)
	
	#Salva o tamanho da tela
	var current_res = DisplayServer.window_get_size()
	#Checa se a resolução atual não está na lista
	if !available_resolutions.has(current_res):
		#adiciona ela na lista
		available_resolutions.append(current_res)
		#Rorganiza alista novamente
		available_resolutions.sort_custom(func(a, b): return a.x > b.x or (a.x == b.x and a.y > b.y))
	
	#limpa as opções no bitão
	resolution_option.clear()
	#Preenche as opções do botão de resoluções com al ista filtrada
	for res in available_resolutions:
		resolution_option.add_item("%dx%d" % [res.x, res.y])
	
	#Pega a resolução atual selecionada
	var res_idx = available_resolutions.find(current_res)
	#Se o indice não foi invalido aplica a ersolução do indice, se for inalido aplica a resolução maxima do monitor
	resolution_option.select(res_idx if res_idx != -1 else 0)

#Função de configuração inicial de modos de tela
func setup_display_modes():
	
	#Limpando as opções
	mode_option.clear()
	#Adicionando as opções principais de modo de tela no botão
	mode_option.add_item("Janela")
	mode_option.add_item("Tela Cheia")
	
	#Salva o modo atual da tela
	var current_mode = DisplayServer.window_get_mode()
	#Checa quais das opções está ativa na janela e muda o selecionado no botão de seleção de modos
	match current_mode:
		DisplayServer.WINDOW_MODE_WINDOWED: #modo janela
			mode_option.select(0) #indice 0
		DisplayServer.WINDOW_MODE_FULLSCREEN: #modo tela cheia
			mode_option.select(1) #indice 1
		_: #caso não tenha um modo definido ou esteja invalido
			mode_option.select(0) #Inice 0 por padrão

#Função para aplicar o modo de tela
func apply_display_mode():
	#Pega o index do modo atual selecionado no botão
	var screen_mode_idx = mode_option.selected
	#Checa quais das opções está selecionada no botão e ativa na janela
	match screen_mode_idx:
		0: #Modo janela
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) #aplica o modo janela
		1: #Modo janela sem bordas
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) #aplica o modo tela cheia

#Função que aplica a resolução
func apply_resolution():
	#Salva a resolução selecionada no botão em uma variavel
	var selected_idx = resolution_option.selected
	#Checa se o index é invalido
	if selected_idx < 0 or selected_idx >= available_resolutions.size():
		return #Se for retorna
	
	#Pega a resolução selecionada
	var new_res = available_resolutions[selected_idx]
	#Pega o modo de tela
	var current_mode = DisplayServer.window_get_mode()
	#Checa se  o modo de tela é o modo janela
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(new_res) #modifica o tamanho da janela
		center_window() #centraliza a janela
	else: #Caso não seja (é fullscreen)
		get_viewport().size = new_res   # muda a resolução interna da viewport

func apply_vsync():
	#Salva o no do botão do csync em uma variavel
	var vsync_check = $VsyncEnableButton
	if vsync_check: #Checa se a variavel foi salva
		#Salva o valor booleano do botão (ativado ou desativado)
		var vsync_enabled = vsync_check.button_pressed
		#Salva o modo de vsync como ativo se o vsync_enable for verdadeiro, caso contrario salva como modo destivado
		var vsync_mode = DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
		#Aplica a configuração no vsync na janela
		DisplayServer.window_set_vsync_mode(vsync_mode)

#endregion

#Função que roda ao iniciar o nó/cena
func _ready() -> void:
	
	#Aplicando a configuração inicial de resolução
	setup_resolutions()
	#Aplicando a configuração inicial do modo de tela
	setup_display_modes()
	#Centralizando a janela
	center_window()
	
	#Setando a configuração inicial de todos os sliders
	setup_slider(master_volume_slider, master_percent_label, "Master")
	setup_slider(music_volume_slider, music_percent_label, "Music")
	setup_slider(sfx_volume_slider, sfx_percent_label, "Effects")

#Função que executa ao pressionar o botão de voltar para o menu
func _on_return_button_pressed() -> void:
	#MUda para a ceno do menu principal
	get_tree().change_scene_to_file(Global.start_menu)


#Função toggle vsync (só armazena a intenção não aplica nada, o valor será usando no botão aplicar)
func _on_vsync_enable_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

#Função que executa ao pressionar o botão de applicar as cofigurações de cideo
func _on_apply_button_pressed() -> void:
	apply_resolution() #aplica a resolução
	apply_display_mode() #aplica o modo de tela
	center_window() #centraliza a janela
	apply_vsync() #aplica o vsync
