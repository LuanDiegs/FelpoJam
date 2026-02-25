extends CanvasLayer
class_name SettingsMenu

#Variaveis audio settings
@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var sfx_volume_slider: HSlider

#Variaveis video settings
@export var resolution_option: OptionButton
@export var mode_option: OptionButton
@export var vsync: CheckBox

#EhPauseMenu
@export var is_pause_menu: bool = false

#Biblioteca de resoluções
var base_resolutions = [
	Vector2i(3840, 2160), # 4K
	Vector2i(2566, 1440), # 2K
	Vector2i(1920, 1080), # FullHD
	Vector2i(1600, 900),
	Vector2i(1366, 768), # Comum em Laptops
	Vector2i(1280, 720), # HD
	Vector2i(1024, 576),
	Vector2i(960, 540),
	Vector2i(854, 480), # SD
	Vector2i(800, 450),
	Vector2i(720, 405),
	Vector2i(640, 360),
	Vector2i(560, 315),
	Vector2i(480, 270),
	Vector2i(400, 225),
	Vector2i(320, 180)]
var available_resolutions = []

#configuracoes salvas
var saved_video_settings: Dictionary = {}
var saved_audio_settings: Dictionary = {}


#Função que roda ao iniciar o nó/cena
func _ready() -> void:
	saved_audio_settings = SettingSaveManager.load_audio_settings()
	saved_video_settings = SettingSaveManager.load_video_settings()
	
	#Aplicando a configuração inicial do modo de tela
	setup_display_modes()
	
	#Aplicando a configuração inicial de resolução
	setup_resolutions()
	set_resolution_label_enabled(0)
	
	#Da load nas configs salvas
	load_video_settings()
	
	#Centralizando a janela
	Global.center_window()
	
	#Setando a configuração inicial de todos os sliders
	setup_slider(master_volume_slider, "Master")
	setup_slider(music_volume_slider, "Music")
	setup_slider(sfx_volume_slider, "Effects")
	
	#Connect sinais do mode_option
	mode_option.item_selected.connect(set_resolution_label_enabled)
	
	

#region Funções de Audio
#Função para configuração inicial do sliders
func setup_slider(slider: HSlider, bus_name: String):
	#Salva o index do bus 
	var bus_idx = AudioServer.get_bus_index(bus_name)
	#Checa se o idx do bus não é invalido
	if bus_idx == -1:
		#Emitir o erro que o bus não foi encontrado
		push_error("ERRO: Bus", bus_name, " não encontrada!")
		return # retorna o codigo

	#Define o valor inicial do slider
	slider.value = saved_audio_settings[bus_name]
	
	#Conecta o sinal de mudança do volume
	slider.value_changed.connect(func(valor):
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(valor)) # Faz a mudança em "tempo real no db do bus deo audio
		
		SettingSaveManager.save_audio_settings(bus_name, valor)
	)
#endregion


#region Funções de Video
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
		DisplayServer.WINDOW_MODE_WINDOWED: # modo janela
			mode_option.select(0) # indice 0
		DisplayServer.WINDOW_MODE_FULLSCREEN: # modo tela cheia
			mode_option.select(1) # indice 1
		_: # caso não tenha um modo definido ou esteja invalido
			mode_option.select(0) # Inice 0 por padrão


#Função para aplicar o modo de tela
func apply_display_mode():
	#Pega o index do modo atual selecionado no botão
	var screen_mode_idx = mode_option.selected
	#Checa quais das opções está selecionada no botão e ativa na janela
	match screen_mode_idx:
		0: # Modo janela
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) # aplica o modo janela
		1: # Modo janela sem bordas
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) # aplica o modo tela cheia


#Função que aplica a resolução
func apply_resolution():
	#Se for 1 não aplicamos a resolução
	if mode_option.selected == 1:
		return
	
	#Verifica se vai ser enabled ou nao
	set_resolution_label_enabled(0)
	
	#Salva a resolução selecionada no botão em uma variavel
	var selected_idx = resolution_option.selected
	
	#Checa se o index é invalido
	if selected_idx < 0 or selected_idx >= available_resolutions.size():
		return # Se for retorna
	
	#Pega a resolução selecionada
	var new_res = available_resolutions[selected_idx]
	
	#Pega o modo de tela
	var current_mode = DisplayServer.window_get_mode()
	
	#Checa se  o modo de tela é o modo janela
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(new_res) # modifica o tamanho da janela
		Global.center_window() # centraliza a janela
	else: # Caso não seja (é fullscreen)
		get_viewport().size = new_res # muda a resolução interna da viewport


func apply_vsync():
	#Salva o no do botão do csync em uma variavel
	if vsync: # Checa se a variavel foi salva
		#Salva o valor booleano do botão (ativado ou desativado)
		var vsync_enabled = vsync.button_pressed
		#Salva o modo de vsync como ativo se o vsync_enable for verdadeiro, caso contrario salva como modo destivado
		var vsync_mode = DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
		#Aplica a configuração no vsync na janela
		DisplayServer.window_set_vsync_mode(vsync_mode)


func set_resolution_label_enabled(_index: int):
	var window_mode_is_fullscreen = mode_option.selected == 1 # 1 é o fullscreen
	resolution_option.disabled = window_mode_is_fullscreen
	

func load_video_settings():
	# Vsync
	var vsync_saved = saved_video_settings[SettingSaveManager.video_config.vsync]
	vsync.button_pressed = vsync_saved
	
	var resolution_saved = saved_video_settings[SettingSaveManager.video_config.resolution]
	if resolution_saved != null:
		var index_array = available_resolutions.find(resolution_saved)
		resolution_option.selected = index_array if index_array != -1 else 0
		apply_resolution()

	var window_mode_saved = saved_video_settings[SettingSaveManager.video_config.window]
	var window_mode_converted = 1 if window_mode_saved == DisplayServer.WINDOW_MODE_FULLSCREEN else 0
	mode_option.select(window_mode_converted)

	apply_display_mode()


func save_video_settings():
	# Salva o estado do vsync
	SettingSaveManager.save_video_settings(SettingSaveManager.video_config.vsync, vsync.button_pressed)
	
	# Salva a resolução selecionada
	var resolutionVector = available_resolutions[resolution_option.selected]
	SettingSaveManager.save_video_settings(SettingSaveManager.video_config.resolution, resolutionVector)
	
	# Salva o modo de tela selecionado
	var mode = Window.MODE_FULLSCREEN if mode_option.selected == 1 else Window.MODE_WINDOWED
	SettingSaveManager.save_video_settings(SettingSaveManager.video_config.window, mode)


#Função toggle vsync (só armazena a intenção não aplica nada, o valor será usando no botão aplicar)
func _on_vsync_enable_button_toggled(_toggled_on: bool) -> void:
	pass # Replace with function body.
#endregion


#Função que executa ao pressionar o botão de applicar as cofigurações de cideo
func _apply_video_settings() -> void:
	apply_display_mode() # aplica o modo de tela
	apply_resolution() # aplica a resolução
	apply_vsync() # aplica o vsync
	

	Global.center_window() # centraliza a janela

	save_video_settings() # salva as configurações de vídeo


#Função que executa ao pressionar o botão de voltar para o menu
func _on_return_button_pressed() -> void:
	_apply_video_settings()
	
	if !is_pause_menu:
		Transition.change_to_scene(Global.start_menu)
	else:
		PauseMenu.close_setting_menu()
