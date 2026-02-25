extends Node

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
	print("Música '", music_name, "' carregada com ", music.tracks.size(), " faixas.")
	return true #Retorna true
#endregion

#region Funções de controle de reprodução de todas as faixas
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
#endregion

#region Funções para o ontrole de volume individual e coletivo com fade
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

#Função que executa ao iniciar (é aqui que as músicas serão carregadas)
func _ready() -> void:
	
	#Exemplo de como a biblioteca vai ser carregada
	#(Assim é mais facil e rapido, é mais pesado, mas nosso jogo é leve)
	#var menu = register_music("menu")
	#menu.add_track(preload("res://audio/menu_base.ogg"), "Music")
	#menu.add_track(preload("res://audio/menu_pad.ogg"), "Music")
	#var fase1 = register_music("fase1")
	#fase1.add_track(preload("res://audio/fase1_base.ogg"), "Music")
	#fase1.add_track(preload("res://audio/fase1_bateria.ogg"), "Music")
	#fase1.add_track(preload("res://audio/fase1_melodia.ogg"), "Music")
	#var boss = register_music("boss")
	#boss.add_track(preload("res://audio/boss_base.ogg"), "Music")
	#boss.add_track(preload("res://audio/boss_bateria.ogg"), "Music")
	#boss.add_track(preload("res://audio/boss_baixo.ogg"), "Music")
	#boss.add_track(preload("res://audio/boss_melodia.ogg"), "Music")
	#boss.add_track(preload("res://audio/boss_extra.ogg"), "Music")
	
	pass #não faz nada pro enquanto
