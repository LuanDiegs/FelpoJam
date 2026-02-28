extends Node

#region Não funciona como eu quero
#region Clases do sistema
#Classe interna que representa as faixas de audio
class Track:
	
	#Variaveis
	var player : AudioStreamPlayer #Player de audio (não é o jogador)
	var bus : String
	
	#Função que inicia as tracks
	func _init(stream: AudioStream, bus_name: String = "Music"):
		player = AudioStreamPlayer.new() #Cria o player de audio
		player.stream = stream #Define a stream correta pro player
		player.bus = bus_name #Define o bus do player
		player.volume_db = -100.00 #Começa mudo

#Classe que representa uma música (coleção de faixas)
class Music:
	
	#Variaveis
	var name : String
	var tracks : Array[Track] = []
	
	#Inicia a musica
	func _init(music_name: String):
		#Define o nome da música
		name = music_name
	
	#Função que "adiciona a track dentro da música"
	func add_track(stream: AudioStream, bus: String = "Music"):
		#Checa se o numero de tracks é maior que sete
		if tracks.size() >= 7:
			#Emite um push error falando que o liite foi atingido
			push_error("Máximo de 7 faixas por música atingido")
			return #Renorna
		#Adiciona as tracks dentro do array de tracks da música
		tracks.append(Track.new(stream, bus))
	
	#Retorna o numero de tracks dentro do array de tracks da musica
	func get_track_count() -> int:
		return tracks.size()
#endregion

#region Variaveis
#Biblioteca de músicas
var library : Dictionary = {}

#Variaveis de estado atual
var current_music : Music = null
var current_players : Array[AudioStreamPlayer] = []

var next_music : Music = null
var next_players : Array[AudioStreamPlayer] = []

#endregion

#region Funções para construir a biblioteca
#Função que registras a musica na biblioteca
func register_music(music_name: String) -> Music:
	#Checa se a musica já existe na bibioteca
	if library.has(music_name):
		#Emite um alerta de push
		push_warning("Música já registrada: ", music_name)
		return library[music_name] #Retorna a musica queestá dentro da biblioteca
	#Cria uma nova musica com base do nome da musica
	var music = Music.new(music_name)
	#Adiciona a musica da biblioteca
	library[music_name] = music
	#Retorna a musica
	return music

#Função que adiciona as tracks dentro das musicas
func add_track_to_music(music_name: String, stream: AudioStreamPlayer, bus: String = "Music"):
	#Pega o nome da musica
	var music = library.get(music_name)
	#Se a musica for valida
	if music:
		#Adiciona a track dentro da musica
		music.add_track(stream, bus)
	else: #Caso contrario (não seja valida)
		#Envia um push error falando que a música não foi encontrada
		push_error("Música não encontrada: ", music_name)
#endregion

#region Funções de carregamento e descarregamento
#Função que descarreva a música atual
func unload_current_music():
	#Cria um loop que pega todos os players de musica
	for player in current_players:
		#Para todos os players de musica
		player.stop()
		#Apaga todos os players de musica da memoria
		player.queue_free()
	#Limpa a array com os playes de música atuais
	current_players.clear()
	#Define a música atual como null
	current_music = null

#Função que carrega a música
func load_music(music_name: String) -> bool:
	#Checa se não tem nenhuma musica com esse nome
	if !library.has(music_name):
		#Emite o push erros que a músic anão foi encontrada
		push_error("Música não encontrada: ", music_name)
		return false #Retorna false
	#Descarrega a música para carregar a proxima
	unload_current_music()
	#Pega a musica na biblioteca com base no nome dela
	var music = library[music_name]
	#Define a musica atual como a musica que pegou na biblioteca
	current_music = music
	#Adiciona os players de audio na àrvores de nós
	for track in music.tracks:
		add_child(track.player)
		current_players.append(track.player)
	#Printa as informações da musica atual no debug
	#print("Música '", music_name, "' carregada com ", music.tracks.size(), " faixas.")
	return true #Retorna true

#Função para descarregar a proxima música
func unload_next_music():
	#Pega os players da proxima música
	for player in next_players:
		#Pausa o player da música
		player.stop()
		#Apaga o player da memoria
		player.queue_free()
	#Limpa o array de proximos  players
	next_players.clear()
	#Define a proxima música como null
	next_music = null

#Função para pré-carregar uma música (a proxima música) 
func preload_music(music_name : String) -> bool:
	#Checa se a musica é invalida
	if !library.has(music_name):
		#Exibe um push error
		push_error("Música não encontrada: ", music_name)
		return false #retorna falso
	
	##Descarrega a proxima musica 
	unload_next_music()
	
	#Pega a música na  biblioteca
	var music = library[music_name]
	#Define a proxima música como a musica
	next_music = music
	#Pega todas as tracks da música
	for track in music.tracks:
		#Pega o player da track
		var player = track.player
		#Adiciona da cena
		add_child(player)
		#Adiciona o prayer no arrya dos proximos players
		next_players.append(player)
		#Zeza o volume
		player.volume_db = -100
	#REtorna no debug a múscia pré-carregada
	#print("Música '", music_name, "' pré-carregada.")
	return true #retorna true

#endregion

#region Funções de controle de faixas

#Função para mudar para a nova música
func _swap_to_next():
	#descarrega a música atual
	unload_current_music()
	#Muda os players atuais para os players seguintes
	current_players = next_players
	#Muda a música atual para a proxima música
	current_music = next_music
	#DEfine o next players
	next_players = []
	#Define a proxima música como null
	next_music = null

#Função para crossfade com a música seguinte
func crossfade_to_next(duration: float = 2.0):
	#Checa se o next players está vazio
	if next_players.is_empty():
		#Envia um push error
		push_error("Nenhuma música pré-carregada.")
		return #Retorna
	#Se não há música atual, apenas toca a próxima
	if current_players.is_empty():
		#Troca para a proxima musica
		_swap_to_next()
		#Fade in
		fade_in(duration)
		return #retorna
	#Fade out da atual e fade in da próxima simultaneamente
	var tween = create_tween()
	tween.set_parallel(true) #Define o tween como paalelo
	#Pega todos os players atuais
	for player in current_players:
		#Aplica o fade out
		tween.tween_property(player, "volume_db", -100.0, duration)
	#pega todos os  proxios players
	for player in next_players:
		#Seta o volume inicial como -100
		player.volume_db = -100.0
		#Toca os  players
		player.play()
		#Aplica o fadein
		tween.tween_property(player, "volume_db", 0.0, duration)
	#Termina o tween
	await tween.finished
	# Substitui a música atual pela próxima
	unload_current_music()
	#Define o player atuais como os proximos
	current_players = next_players
	#Define a música atual como a proxima múica
	current_music = next_music
	#REseta o proximo players
	next_players = []
	#Define a proxima música como null
	next_music = null

#Conexta o final dsa musica atual com a proxima
func connect_music_finished(callback: Callable):
	#Checa se os players atuais estão vazio
	if current_players.is_empty():
		return #Retorna
	#Conecta apenas o primeiro player (assume que todos têm a mesma duração)
	current_players[0].finished.connect(callback)

#Função para tocar todas as faixas
func play_all():
	for player in current_players:
		if !player.playing:
			player.play()

#Função para parar todas as faixas
func stop_all():
	for player in current_players:
		player.stop()

#Função para pausar todas as faixas
func pause_all():
	for player in current_players:
		player.stream_paused = true

#Função para despausar todas as faixas
func resume_all():
	for player in current_players:
		player.stream_paused = false

#Função para setar o volume individual de cada track
func set_track_volume(track_index: int, volume_db: float, fade_duration: float = 0.0):
	#Checa se o index da track é menor que 0 ou maior ou igual que o tamando do array que salva os players de audio
	if track_index < 0 or track_index >= current_players.size():
		#Emit um push error indicando que o indice da faixa é invalido
		push_error("Índice de faixa inválido: ", track_index)
		return #Retorna
	
	#Pega o player do current players com base no index
	var player = current_players[track_index]
	#Checa se o fade duration é igual ou menor a 0
	if fade_duration <= 0:
		#Define o volume do player como o volume estipulado
		player.volume_db = volume_db
	else: #Caso o contrario (maior que 0)
		#Cria um tween
		var tween = create_tween()
		#Usa o tween para cirar um fade até o volume desejado com base no tempo de duração do fade
		tween.tween_property(player, "volume_db", volume_db, fade_duration)

#Função para setar o voluem de todas as tracks juntas
func set_all_volumes(volume_db: float,fade_duration: float = 0.0):
	#Checa se o fade duration é menor ou igual a 0
	if fade_duration <= 0:
		#Pega todos os players de musica atuais
		for player in current_players:
			#Diminui o volume atual pro volume estipulado
			player.volume_db = volume_db
	else: #Caso o contrario (caso o fade duration seja maior que 0)
		#Cria um tween
		var tween = create_tween()
		#Define o tween como paralelo
		tween.set_parallel(true)
		#Pega todos os playes de musica atuais
		for player in current_players:
			#Usa o tween para cirar um fade até o volume desejado com base no tempo de duração do fade
			tween.tween_property(player, "volume_db", volume_db, fade_duration)

#função para fade in
func fade_in(duration: float = 2.0):
	#Executa a 
	set_all_volumes(0.0, duration)

#Função para fade out
func fade_out(duration: float = 2.0, stop_after: bool = true):
	#Cria um tween
	var tween = create_tween()
	#Define ele como paralelo
	tween.set_parallel(true)
	#Pega todos os players de musica atual
	for player in current_players:
		#Usa o tween para cirar um fade até o volume 0 absoluto com base no tempo de duração do fade
		tween.tween_property(player, "volume_db", -100, duration)
	#Checa se stop after is true
	if stop_after:
		#Esperat o tween finalizar
		await tween.finished
		#Para todas as faixas
		stop_all()
#endregion

#region Funções de controle de efeitos
#Retorna qual é o bus da track (por mais que a gente já saiba qual o bus a godot não sabe)
func get_track_bus(track_index : int) -> String:
	#Checa se o index é menor que zero ou maior ou igual que o numero de player do array
	if track_index  < 0 or track_index >= current_players.size():
		#Envia uma mensagem de push
		push_error("Índice de faixa inválido: ", track_index)
		return "" #REtorna nada
	#Define player como o player atual com base no index
	var player = current_players[track_index]
	return player.bus #Retorna o nome da bus do player

#Função para adicionar qualquer efeito existente nativamente na godot
func add_effect_to_track(track_index : int, effect : AudioEffect) -> bool:
	#Pega o bus da track
	var bus_name = get_track_bus(track_index)
	#Checa se o nome do bus não está vazio
	if bus_name.is_empty():
		return false #REtorna falso
	#pega o index do bus
	var bus_idx = AudioServer.get_bus_index(bus_name)
	#Checa se o index do bus é invalido
	if bus_idx == -1:
		#Emite um push erros
		push_error("Bus não encontrado: ", bus_name)
		return false #Retorna false
	#Adiciona o efeito desejado
	AudioServer.add_bus_effect(bus_idx, effect)
	return true #Retorna true

#Função para remover qualquer efeito existente nativamente na godot
func remove_effects_from_track(track_index : int, effect_index : int) -> bool:
	#Pega o nome do bus
	var bus_name = get_track_bus(track_index)
	#Checa se o nome do bus está vazio
	if bus_name.is_empty():
		return false #Retorna falso
	#Pega o index do bus 
	var bus_idx = AudioServer.get_bus_index(bus_name)
	#Checa que o index do bus é invalid
	if bus_idx == -1:
		#Emite um push error
		push_error("Bus não encontrado: ", bus_name)
		return false #Retorna false
	#REmove o efeitos escolhido do bus
	AudioServer.remove_bus_effect(bus_idx, effect_index)
	return true #retorna verdadeiro

#Retorna o numero de efeitos na bus da track
func get_track_effect_count(track_index: int) -> int:
	#Pega o nome do bus da track
	var bus_name = get_track_bus(track_index)
	#Checa se o nome do bus é vazio
	if bus_name.is_empty():
		return -1 #Retorna -1
	#Pegar o index do bus da track
	var bus_idx = AudioServer.get_bus_index(bus_name)
	#Checa se o index do bus é invalido
	if bus_idx == -1:
		return -1 #Retorna -1
	#Retorna o numero de efeitos no bus da track
	return AudioServer.get_bus_effect_count(bus_idx)
#endregion

#os parametros que estão comentados não existem na godot 4.6, tenho que ver depois

#Função para a dicionar reverb na track de audio
func add_reverb_to_track(track_index : int, room_size : float = 0.5, damping : float = 0.5, spread : float = 1.0,
dry : float = 1.0, wet : float = 1.0, hpf : float = 0.0, predelay_msec : float = 0.02,
predelay_feedback : float = 0.01) -> bool:
	var effect = AudioEffectReverb.new()
	effect.room_size = room_size
	effect.damping = damping
	effect.spread = spread
	effect.dry = dry
	effect.wet = wet
	effect.hipass = hpf
	effect.predelay_msec = predelay_msec
	effect.predelay_feedback = predelay_feedback
	return add_effect_to_track(track_index, effect)

#Função para adicionar o efeito de chorus na track
func add_chorus_to_track( track_index : int, voice_count : int = 2, wet : float = 1.0, dry: float = 1.0) -> bool:
	var effect = AudioEffectChorus.new()
	effect.voice_count = voice_count
	effect.wet = wet
	effect.dry = dry
	return add_effect_to_track(track_index, effect)

#Função para adicionar o defeito dedelay na track
func add_delay_to_track( track_index : int, feedback : bool = true, feedback_delay_ms : int = 500.0,
feedback_level_db : float = -6.0, feedback_lowpass : int = 16000, dry : float = 1.0, tap1_active: bool = true,
tap1_delay_ms : float = 250.0, tap1_level_db : float = 0.0, tap1_pan : float = 0.2, tap2_active: bool = true,
tap2_delay_ms : float = 500.0, tap2_level_db : float = 0.0, tap2_pan : float = -0.4) -> bool:
	var effect = AudioEffectDelay.new()
	effect.feedback_active = feedback
	effect.feedback_delay_ms = feedback_delay_ms
	effect.feedback_level_db = feedback_level_db
	effect.feedback_lowpass = feedback_lowpass
	effect.dry = dry
	effect.tap1_active = tap1_active
	effect.tap1_delay_ms = tap1_delay_ms
	effect.tap1_level_db = tap1_level_db
	effect.tap1_pan = tap1_pan
	effect.tap2_active = tap2_active
	effect.tap2_delay_ms = tap2_delay_ms
	effect.tap2_level_db = tap2_level_db
	effect.tap2_pan = tap2_pan
	return add_effect_to_track(track_index, effect)

#Função que adiciona um efeito de filtro na track
func add_filter_to_track( track_index : int, cutoff_hz : float = 2000.0, resonance : float = 0.5,
gain : float = 0.0, db = 0) -> bool:
	var effect = AudioEffectFilter.new()
	effect.cutoff_hz = cutoff_hz
	effect.resonance = resonance
	effect.gain = gain
	effect.db = db
	return add_effect_to_track(track_index, effect)

#Função de efeito de panning da track
func add_panner_to_track(track_index: int, pan: float = 0.0) -> bool:
	var effect = AudioEffectPanner.new()
	effect.pan = pan
	return add_effect_to_track(track_index, effect)

#Função de efeito de expansão stereo da track
func add_stereo_enhance_to_track( track_index : int, pan_pullout: float = 1, time_pullot_ms : float = 50,
surround : float = 0) -> bool:
	var effect = AudioEffectStereoEnhance.new()
	effect.pan_pullout = pan_pullout
	effect.time_pullout_ms = time_pullot_ms
	effect.surround = surround
	return add_effect_to_track(track_index, effect)

#Função de efeito de mudança pitch de track
func add_pitch_shift_to_track(track_index: int,
pitch_scale: float = 1.0, fft_size : int = 2, oversampling: int = 4) -> bool:
	var effect = AudioEffectPitchShift.new()
	effect.pitch_scale = pitch_scale
	effect.fft_size = fft_size
	effect.oversampling = oversampling
	return add_effect_to_track(track_index, effect)

#Função para adicionar efeito de phaser na track
func add_phaser_to_track(track_index : int, depth : float = 1.0, feedback : float = 0.7,
range_max_hz : float = 1600, range_min_hz : float = 440, rate_hz : float = 0.5) -> bool:
	var effect = AudioEffectPhaser.new()
	effect.depth = depth
	effect.feedback = feedback
	effect.range_max_hz = range_max_hz
	effect.range_min_hz = range_min_hz
	effect.rate_hz = rate_hz
	return add_effect_to_track(track_index, effect)

#Função para adicionar o efetiro de distorção na trak
func add_distortion_to_track(track_index : int, mode : int = 0, pre_gain : float = 1.0, post_gain : float = 1.0,
	drive : float = 0, keep_hf_hz : int = 16000) -> bool:
	var effect = AudioEffectDistortion.new()
	effect.mode = mode
	effect.pre_gain = pre_gain
	effect.post_gain = post_gain
	effect.drive = drive
	effect.keep_hf_hz = keep_hf_hz
	return add_effect_to_track(track_index, effect)

##Função que executa ao iniciar (é aqui que as músicas serão carregadas)
#func _ready() -> void:
	#
	#
	##Exemplo de como a biblioteca vai ser carregada
	##(Assim é mais facil e rapido, é mais pesado, mas nosso jogo é leve)
	##var menu = register_music("menu")
	##menu.add_track(preload("res://audio/menu_base.ogg"), "Music")
	##menu.add_track(preload("res://audio/menu_pad.ogg"), "Music")
	##var fase1 = register_music("fase1")
	##fase1.add_track(preload("res://audio/fase1_base.ogg"), "Music")
	##fase1.add_track(preload("res://audio/fase1_bateria.ogg"), "Music")
	##fase1.add_track(preload("res://audio/fase1_melodia.ogg"), "Music")
	##var boss = register_music("boss")
	##boss.add_track(preload("res://audio/boss_base.ogg"), "Music")
	##boss.add_track(preload("res://audio/boss_bateria.ogg"), "Music")
	##boss.add_track(preload("res://audio/boss_baixo.ogg"), "Music")
	##boss.add_track(preload("res://audio/boss_melodia.ogg"), "Music")
	##boss.add_track(preload("res://audio/boss_extra.ogg"), "Music")
	#
	#pass #não faz nada pro enquanto
#endregion

# Não usa @onready para evitar erro, vamos criar no _ready
var music_player: AudioStreamPlayer

var musicas = {
	"tutorial": preload("res://Assets/Musicas/Tutorial/Tutorial.ogg"),
	"level1": preload("res://Assets/Musicas/Level 1/Level 1.ogg"),
	"level2": preload("res://Assets/Musicas/Level 2/Level 2.ogg"),
	"level3": preload("res://Assets/Musicas/Level 3/Level 3.ogg"),
	"boss": preload("res://Assets/Musicas/Boss/Boss.ogg")
}

func _ready():
	# Cria o player se não existir
	if not has_node("MusicPlayer"):
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		add_child(music_player)
	else:
		music_player = $MusicPlayer
		
	# Configurações iniciais (opcional)
	music_player.volume_db = 0.0
	music_player.bus = "Music"
	


func trocar_musica(nome: String, fade_duration: float = 0.0):
	if not musicas.has(nome):
		push_error("Música não encontrada: ", nome)
		return
	var nova_stream = musicas[nome]
	if music_player.stream == nova_stream and music_player.playing:
		print("Música '", nome, "' já está tocando.")
		return
	if fade_duration <= 0.0:
		music_player.stream = nova_stream
		music_player.play()
		print("Tocando música: ", nome)
		return
	# Crossfade (igual ao código anterior)
	var tween = create_tween()
	tween.set_parallel(true)
	if music_player.playing:
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
	var novo_player = AudioStreamPlayer.new()
	novo_player.stream = nova_stream
	print(music_player.bus)
	novo_player.bus = music_player.bus
	novo_player.volume_db = -80.0
	add_child(novo_player)
	novo_player.play()
	tween.tween_property(novo_player, "volume_db", 0.0, fade_duration)
	await tween.finished
	music_player.stop()
	music_player.queue_free()
	music_player = novo_player
	print("Crossfade concluído: ", nome)

# Função para parar a música (com fade opcional)
func parar_musica(fade_duration: float = 0.0):
	if fade_duration <= 0.0:
		music_player.stop()
	else:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		await tween.finished
		music_player.stop()

# Função para pausar/despausar
func pausar_musica(pausado: bool):
	music_player.stream_paused = pausado

# Função para ajustar volume (em dB)
func set_volume(db: float):
	music_player.volume_db = db
