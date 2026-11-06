# Kravenox: Quadros do Cisma. Todo o jogo num nó só.
#
# O Kravenox anda sem parar por um caminho de quadros. Cada quadro guarda um
# poder comprado na loja; quando ele pisa no quadro, o poder dispara. Os
# monstros do livro chegam em ondas: 15 ondas, chefe na 5, na 10 e na 15.
#
# O visual vem das artes oficiais: o Kravenox e o Thornox são recortes das
# estátuas 3D (kravenox/3d), os monstros são recortes das pinturas
# conceituais (kravenox/arte/conceitos) e o fundo é a pintura da Cratera do
# Cisma. Tudo é desenhado em _draw() a partir de dados simples.
extends Node2D

const LARG := 480.0
const ALT := 820.0
var TAM := 84.0
var PASSO_GRADE := 94.0
var OX := 57.0
var OY := 200.0
const LOJA_Y := 600.0
const NIVEL_MAX := 5
const VERSAO := "2026-11-07b"   # aparece em Ajustes: diz qual versão está no aparelho
const FASES := 4             # ondas por capítulo; a 4ª tem chefe
const TOTAL_CAPITULOS := 76  # Livro I (35) + Livro II (41)
const CAPS_POR_MUNDO := 4
var CENTRO := Vector2(240, 383)   # meio do anel: onde o Kravenox espera entre as ondas
var ANEL: Array = []   # o caminho do mundo atual (montado em montar_caminho)

# Caminhos dos mundos: voltas fechadas na grade (x, y), na ordem em que o
# Kravenox anda. Começam pequenos e crescem ao longo dos mundos.
const FORMAS := {
	"cruz": [[1, 0], [2, 0], [3, 0], [3, 1], [4, 1], [4, 2], [3, 2], [3, 3], [2, 3], [1, 3], [1, 2], [0, 2], [0, 1], [1, 1]],
	"degrau": [[0, 0], [1, 0], [2, 0], [2, 1], [3, 1], [4, 1], [4, 2], [4, 3], [3, 3], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]],
	"dente": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [4, 1], [4, 2], [4, 3], [3, 3], [3, 2], [2, 2], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]],
	"cruz grande": [[1, 0], [2, 0], [3, 0], [3, 1], [4, 1], [4, 2], [4, 3], [3, 3], [3, 4], [2, 4], [1, 4], [1, 3], [0, 3], [0, 2], [0, 1], [1, 1]],
	"dois dentes": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [5, 1], [5, 2], [5, 3], [4, 3], [4, 2], [3, 2], [3, 3], [2, 3], [2, 2], [1, 2], [1, 3], [0, 3], [0, 2], [0, 1]],
}
# Um caminho por mundo (19): "anel LxA" é um anel retangular. Espelhado = true vira de lado.
const CAMINHO_DO_MUNDO := [
	["anel 3x3", false], ["anel 4x3", false], ["anel 4x4", false], ["anel 3x5", false], ["cruz", false],
	["anel 5x4", false], ["degrau", false], ["dente", false], ["cruz grande", false], ["anel 5x5", false],
	["anel 6x4", false], ["anel 6x5", false], ["dois dentes", false], ["degrau", true], ["dente", true],
	["cruz grande", false], ["dois dentes", true], ["anel 6x5", false], ["dois dentes", false],
]
# Os 76 capítulos do livro (títulos do RPG em kravenox-jogar/rpg/js)
const CAPITULOS := [
	"O Despertar no Reino Quebrado", "Ecos do Cisma", "As Sentinelas", "A Vila Sem Nome", "A Primeira Raiz",
	"O Sangue dos Irmãos", "A Coisa que Dormia", "Os Sinos do Vazio", "O Abismo entre os Irmãos", "A Filha Esquecida",
	"O Sétimo Sino", "A Escolha", "A Quarta Essência", "O Reino em Guerra", "A Cidade das Cinzas",
	"O Sangue da Essência", "O Gigante do Vazio", "O que Existia Antes", "O Coração do Primeiro", "A Queda de Valdora",
	"A Sala da Fonte", "O Homem que Kravenox Seria", "As Ruínas do Passado", "O Último Caminho", "A Última Batalha",
	"Depois do Fim", "Além das Montanhas", "A Primeira Cidade", "O Mundo que Virá", "A Queda da Primeira Cidade",
	"O Exército das Sombras", "O Rei dos Espinhos", "O Peso da Escolha", "O Rei do Vazio", "A Nova Essência",
	"A Cidade sem Nome", "O Irmão que Morreu", "O Último Rei", "A Guerra dos Mundos", "O Terceiro Espinho",
	"O Primeiro Mundo", "Aquilo que Sou", "O Nascimento do Caos", "A Cidade que Não Existia", "O Pai dos Devoradores",
	"A Prisão entre Mundos", "A Porta", "A Primeira Origem", "Os Antigos", "O Mundo sem Nome",
	"A Cidade dos Espinhos", "O Homem Antes do Rei", "O Rei do Último Mundo", "A Escolha que Não Foi Sua", "Quando a Fonte Morreu",
	"A Biblioteca do Fim", "O Primeiro Leitor", "O Mundo Depois do Fim", "Aquele que Existia Antes", "O Livro de Thornox",
	"O Destino de Thornox", "A Estrada entre as Estrelas", "A Porta Dentro de Thornox", "O que a Fonte Escondeu", "O Caminho até o Fim",
	"O Começo Depois do Fim", "Um Mundo sem Nome", "A Menina que Lembrava", "Aveline", "A Última Escolha de Aveline",
	"A Estrela Azul", "O Primeiro Kravenox", "A Escolha que Faltava", "O Último Inimigo", "O Mundo Verde",
	"O que Fica Depois do Fim",
]
# Começa simples: cada poder e cada monstro aparece a partir de um capítulo.
const ITEM_DESDE := {"garras": 1, "espinhos": 1, "cristal": 1, "raio": 2, "passo": 3, "esmagamento": 5, "fonte": 7, "rasgo": 9, "escudo": 4, "corrida": 6}
const MONSTRO_DESDE := {"larva": 1, "esfera": 2, "verme": 4, "sentinela": 6}
# Melhorias permanentes, compradas com fragmentos ganhos a cada missão.
const MELHORIAS := [
	{"id": "vida", "nome": "Couraça de Espinhos", "desc": "+20 de vida", "max": 20, "custo": 4},
	{"id": "essencia", "nome": "Essência Guardada", "desc": "+6 de essência no começo", "max": 20, "custo": 4},
	{"id": "forca", "nome": "Fúria do Cisma", "desc": "+10% de dano dos poderes", "max": 20, "custo": 6},
	{"id": "passo", "nome": "Passo Predador", "desc": "+6% de velocidade", "max": 5, "custo": 5},
	{"id": "sorte", "nome": "Olho do Vazio", "desc": "+1 troca grátis por onda", "max": 2, "custo": 10},
	{"id": "defesa", "nome": "Pele de Pedra", "desc": "-3% do dano que ele recebe", "max": 10, "custo": 6},
	{"id": "critico", "nome": "Olhos de Brasa", "desc": "+3% de chance de crítico (dano em dobro)", "max": 10, "custo": 6},
]
# As formas do Kravenox (folha de sprites, universo/personagens/kravenox.md):
# ele muda de forma conforme o nível (1 + a soma das melhorias).
const FORMAS_KX := [
	[1, "Despertar Frágil"], [3, "Essência Retornando"], [6, "Espinhos Aflorados"], [10, "Sede de Poder"],
	[15, "Corrupção Crescente"], [21, "Vontade do Abismo"], [28, "Forma Corrompida"], [36, "Asas do Cisma"],
	[46, "Poder Terrível"], [58, "Soberano do Reino Quebrado"],
]
const CONQUISTAS := [
	{"id": "mundo1", "nome": "Vença o Mundo 1", "tipo": "feitos", "meta": 4, "premio": 10},
	{"id": "caps20", "nome": "Vença 20 capítulos", "tipo": "feitos", "meta": 20, "premio": 25},
	{"id": "livro1", "nome": "Vença o Livro I (35 capítulos)", "tipo": "feitos", "meta": 35, "premio": 50},
	{"id": "fim", "nome": "Vença os 76 capítulos", "tipo": "feitos", "meta": 76, "premio": 120},
	{"id": "m500", "nome": "Espante 500 monstros", "tipo": "mortes", "meta": 500, "premio": 10},
	{"id": "m5000", "nome": "Espante 5000 monstros", "tipo": "mortes", "meta": 5000, "premio": 40},
	{"id": "chefes", "nome": "Derrote 10 chefes", "tipo": "chefes", "meta": 10, "premio": 15},
	{"id": "fusoes", "nome": "Funda itens 30 vezes", "tipo": "fusoes", "meta": 30, "premio": 12},
	{"id": "nv5", "nome": "Leve um item ao nível 5", "tipo": "nivel5", "meta": 1, "premio": 15},
	{"id": "torre", "nome": "Defenda a torre 10 vezes", "tipo": "bonus", "meta": 10, "premio": 20},
	{"id": "pesadelo", "nome": "Vença um capítulo no Pesadelo", "tipo": "feitos_p", "meta": 1, "premio": 15},
	{"id": "asas", "nome": "Alcance a forma Asas do Cisma", "tipo": "nivel", "meta": 36, "premio": 30},
]

# Paleta da fantasia sombria: preto azulado, roxo do Vazio, vermelho do
# Kravenox, ouro velho para a interface.
var NOITE := Color8(12, 10, 18)
var PEDRA := Color8(38, 34, 46)
var PEDRA_CLARA := Color8(58, 52, 70)
var PEDRA_ESC := Color8(20, 18, 26)
var PEDRA_BORDA := Color8(74, 66, 90)
var TINTA := Color8(8, 6, 10)
var BRANCO := Color8(232, 226, 236)
var CINZA := Color8(150, 142, 160)
var OURO := Color8(214, 178, 106)
var OURO_ESC := Color8(120, 94, 52)
var ROXO := Color8(160, 100, 255)
var ROXO_ESC := Color8(60, 34, 100)
var VERMELHO := Color8(214, 40, 44)
var SANGUE := Color8(110, 18, 24)
var VERDE := Color8(90, 200, 120)
var AZUL := Color8(120, 160, 205)

# Poderes do Kravenox (os cinco primeiros vêm do Cratera do Cisma)
var ITENS := {
	"garras": {"nome": "Garras", "custo": 8, "cor": Color8(230, 60, 50), "curta": "Golpe em volta", "desc": "arranha e empurra todos os monstros em volta do Kravenox"},
	"espinhos": {"nome": "Espinhos Vorazes", "custo": 10, "cor": Color8(200, 40, 60), "curta": "Espinhos em roda", "desc": "solta espinhos para todos os lados"},
	"raio": {"nome": "Raio da Essência", "custo": 12, "cor": Color8(170, 110, 255), "curta": "Raio em cadeia", "desc": "um raio pula de um monstro para o outro"},
	"esmagamento": {"nome": "Esmagamento", "custo": 14, "cor": Color8(200, 140, 80), "curta": "Dano em área", "desc": "esmaga o chão e fere tudo numa área grande"},
	"rasgo": {"nome": "Rasgo do Abismo", "custo": 12, "cor": Color8(230, 30, 90), "curta": "Corte que atravessa", "desc": "um corte que vai até o monstro mais perto e atravessa a fila"},
	"cristal": {"nome": "Cristal de Vida", "custo": 9, "cor": Color8(90, 220, 170), "curta": "Cura a vida", "desc": "devolve vida ao Kravenox"},
	"passo": {"nome": "Passo Predador", "custo": 7, "cor": Color8(110, 210, 120), "curta": "Pula quadros", "desc": "o Kravenox dá um salto e pula quadros para a frente: 2 no nível 1, 4 no nível 2, 6 no nível 3, e assim por diante; só o quadro onde ele cai dispara"},
	"corrida": {"nome": "Corrida do Cisma", "custo": 9, "cor": Color8(255, 150, 60), "curta": "Corre mais rápido", "desc": "o Kravenox dispara correndo e todas as casas por onde passa disparam: 2x por 2 casas no nível 1, 4x por 4 casas no nível 2, 6x por 6 casas no nível 3, e assim por diante"},
	"escudo": {"nome": "Escudo de Espinhos", "custo": 10, "cor": Color8(110, 170, 255), "curta": "Escudo extra", "desc": "cria um escudo por cima da vida; quanto maior o nível, mais escudo ele guarda"},
	"fonte": {"nome": "Fonte de Essência", "custo": 10, "cor": Color8(190, 130, 255), "curta": "Dá essência", "desc": "rende essência para gastar na loja"},
}

# Monstros do livro e do gibi (universo/inimigos, biblia/personagens).
# "alt" é a altura na tela em pixels; "anda" é o jeito de se mexer.
var MONSTROS := {
	"larva": {"nome": "Larva da Essência", "hp": 22.0, "vel": 34.0, "dano": 5.0, "premio": 2, "img": "larva", "alt": 44.0, "anda": "rasteja"},
	"esfera": {"nome": "Sentinela Esférica", "hp": 14.0, "vel": 70.0, "dano": 4.0, "premio": 2, "img": "esfera", "alt": 46.0, "anda": "flutua"},
	"verme": {"nome": "Verme de Dentes", "hp": 34.0, "vel": 58.0, "dano": 7.0, "premio": 3, "img": "verme", "alt": 50.0, "anda": "morde"},
	"sentinela": {"nome": "Sentinela do Vazio", "hp": 55.0, "vel": 30.0, "dano": 10.0, "premio": 4, "img": "sentinela", "alt": 82.0, "anda": "marcha"},
	"larvamae": {"nome": "Larva-Mãe", "hp": 420.0, "vel": 18.0, "dano": 20.0, "premio": 40, "img": "larva", "alt": 118.0, "anda": "rasteja", "chefe": true, "tinta": Color(1.0, 0.72, 0.95)},
	"semrosto": {"nome": "Sentinela sem Rosto", "hp": 1100.0, "vel": 14.0, "dano": 28.0, "premio": 80, "img": "sentinela", "alt": 150.0, "anda": "marcha", "chefe": true, "tinta": Color(0.8, 0.7, 1.0)},
	"thornox": {"nome": "Thornox", "hp": 2300.0, "vel": 16.0, "dano": 35.0, "premio": 0, "img": "thornox", "alt": 130.0, "anda": "marcha", "chefe": true},
}
const FILHOTES := {"larvamae": "larva", "semrosto": "esfera", "thornox": "verme"}

var fonte: Font          # texto corrido (Alegreya Sans)
var fonte_titulo: Font   # títulos (Cinzel)
var tex := {}            # nome -> Texture2D
var tex_branca := {}     # nome -> silhueta branca (piscar ao levar dano)
var fundo: Texture2D
var vinheta: Texture2D
var robo := false        # modo de teste automático (--robo)
var tempo := 0.0

# estado da partida
var onda := 0
var essencia := 25
var hp_max := 150.0
var hp := 150.0
var quadros := []
var k_pos := 0.0
var k_vel := 1.4
var k_rapido := 0.0       # casas que ainda faltam correndo (Corrida do Cisma)
var k_mult := 1.0         # quantas vezes mais rápido ele corre
var k_ultimo := 0
var k_dir := 1
var k_anim := 0.0
var k_flash := 0.0
var monstros := []
var tiros := []
var efeitos := []
var textos := []
var fila := []
var t_spawn := 0.0
var gap := 1.0
var t_onda := 0.0   # depois de 20 s de onda os monstros ficam mais rápidos
var estado := "loja"   # loja / onda / derrota / vitoria
var selec := []        # [] ou ["loja", i] ou ["quadro", i]
var vender := false
var vel_jogo := 1
var trocas_gratis := 1
var brilho := []
var mortes := 0
var msg := ""
var msg_t := 0.0
var loja := []

# telas e progresso
var tela := "abertura"   # abertura / inicio / mundos / melhorias / bestiario / jogo
var t_tela := 0.0
var capitulo := 1
var premio_fim := 0
var k_vis := Vector2.ZERO  # onde o Kravenox está de fato (entre as ondas ele anda até o meio)
var k_no_anel := false     # já chegou ao quadro e está dando a volta
var k_andando := false
var k_pausa := 0.0
var k_salto := 0.0
var fim_onda_t := -1.0   # o último monstro morreu: um instante em câmera lenta antes da loja
var salvar_logo := -1.0  # grava a partida um pouco depois, com tudo parado (gravar dá uma travadinha no Safari)       # quadros que ainda faltam no salto do Passo Predador
var destaque_cap := 0    # capítulo que acabou de ser vencido (brilha no mapa)       # pausa curta ao sair do caminho, antes de ir ao meio
var escudo := 0.0        # escudo por cima da vida (item Escudo)
var escudo_flash := 0.0
var bonus_pendente := false   # venceu a fase 4: falta a fase bônus
var bonus_res := ""           # "" / "ok" / "caiu"
var premio_bonus := 0
var torre_hp := 0.0
var torre_max := 0.0
var torre_flash := 0.0
var rolagem := 0.0       # rolagem do mapa dos mundos
var toque_ini := Vector2.ZERO
var toque_rola := 0.0
var arrastou := false
var arrasto := {}        # item sendo arrastado com o dedo: {"de": "loja"/"quadro", "i", "p", "moveu"}
var prog := {}
var robo_tentativas := 0
var modo := "normal"          # normal / pesadelo
var efeitos_ligados := true
var PAPEL_C := Color8(230, 215, 180)

# som: trilhas do RPG 2D (kravenox-jogar/rpg/music) e efeitos do Cratera do Cisma
const TRILHAS_EM_LACO := ["abismo", "batalha", "chefe", "espinhos", "reino"]
const EFEITOS := ["acerto", "corte", "raio", "esmagamento", "dano", "gema", "chefe", "nivel", "thornox"]
var musica: AudioStreamPlayer
var faixa := ""
var som_ligado := true
var efeitos_som := {}
var vozes := []
var ultimo_som := {}


func _ready() -> void:
	randomize()
	robo = "--robo" in OS.get_cmdline_user_args() or "--robo" in OS.get_cmdline_args()
	fonte = load("res://fontes/alegreya-sans-bold.ttf")
	var cinzel := FontVariation.new()
	cinzel.base_font = load("res://fontes/cinzel.ttf")
	cinzel.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
	fonte_titulo = cinzel
	for nome in ["kravenox", "thornox", "larva", "esfera", "verme", "sentinela"]:
		carregar(nome)
	# o andar do Kravenox: os 4 quadros de passo do Cratera do Cisma
	for n in 4:
		carregar("kravenox-passo-%d" % n, "")
	fundo = load("res://assets/arte/cratera.png")
	vinheta = gerar_vinheta()
	preparar_som()
	carregar_progresso()
	if robo:
		tela = "jogo"
		# --cap=60 começa no capítulo 60 com as melhorias no máximo (para testar o fim)
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--cap="):
				capitulo = int(a.substr(6))
				for m in MELHORIAS:
					prog["melhorias"][m["id"]] = m["max"]
	novo_jogo()


func preparar_som() -> void:
	musica = AudioStreamPlayer.new()
	musica.volume_db = -7.0
	add_child(musica)
	for n in EFEITOS:
		efeitos_som[n] = load("res://sons/%s.wav" % n)
	for _i in 8:
		var v := AudioStreamPlayer.new()
		v.volume_db = -9.0
		add_child(v)
		vozes.append(v)


var tw_musica: Tween


func tocar_musica(nome: String) -> void:
	if nome == faixa or robo:
		return
	faixa = nome
	var st: AudioStreamOggVorbis = load("res://musica/%s.ogg" % nome)
	st.loop = nome in TRILHAS_EM_LACO
	st.loop_offset = 0.5   # o mesmo ponto de volta que o RPG usa (music/index.json)
	if not som_ligado:
		musica.stream = st
		return
	# troca com fade: a música que está tocando abaixa, a nova sobe
	if tw_musica and tw_musica.is_valid():
		tw_musica.kill()
	var tw := create_tween()
	tw_musica = tw
	if musica.playing:
		tw.tween_property(musica, "volume_db", -40.0, 0.6)
	tw.tween_callback(func():
		musica.stream = st
		musica.volume_db = -40.0
		musica.play())
	tw.tween_property(musica, "volume_db", -7.0, 0.8)


func som(nome: String) -> void:
	if robo or not efeitos_ligados:
		return
	var agora := Time.get_ticks_msec()
	if agora - int(ultimo_som.get(nome, -1000)) < 70:
		return
	ultimo_som[nome] = agora
	for v in vozes:
		if not v.playing:
			v.stream = efeitos_som[nome]
			v.pitch_scale = randf_range(0.94, 1.06)
			v.play()
			return


func musica_certa() -> String:
	if tela != "jogo":
		return "reino"
	match estado:
		"onda":
			if onda == FASES:
				return "espinhos" if chefe_do_capitulo() == "thornox" else "chefe"
			return "batalha"
		"vitoria":
			return "vitoria"
		"derrota":
			return "gameover"
	return "abismo"


func ligar_som(sim: bool) -> void:
	som_ligado = sim
	if sim:
		faixa = ""
		tocar_musica(musica_certa())
	else:
		musica.stop()


# As artes são grandes e aparecem pequenas: mipmaps deixam o contorno liso.
func carregar(nome: String, pasta := "arte") -> void:
	var t: Texture2D = load("res://assets/%s/%s.png" % [pasta, nome]) if pasta != "" else load("res://assets/%s.png" % nome)
	var img := t.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var cor := img.duplicate()
	cor.generate_mipmaps()
	tex[nome] = ImageTexture.create_from_image(cor)
	for y in img.get_height():
		for x in img.get_width():
			img.set_pixel(x, y, Color(1, 1, 1, img.get_pixel(x, y).a))
	img.generate_mipmaps()
	tex_branca[nome] = ImageTexture.create_from_image(img)


func gerar_vinheta() -> Texture2D:
	var w := 120
	var h := 205
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var d := Vector2((x - w / 2.0) / (w / 2.0), (y - h * 0.42) / (h / 2.0)).length()
			img.set_pixel(x, y, Color(0.02, 0.01, 0.04, clampf((d - 0.45) * 1.1, 0.0, 0.85)))
	return ImageTexture.create_from_image(img)


# ------------------------------------------------------------ progresso
const ARQUIVO := "user://progresso.json"


func carregar_progresso() -> void:
	prog = {"liberado": 1, "feitos": {}, "fragmentos": 0, "melhorias": {}, "vistos": {}, "bonus": {}}
	if robo or not FileAccess.file_exists(ARQUIVO):
		return
	var f := FileAccess.open(ARQUIVO, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		for k in d.keys():   # tudo o que estiver salvo (inclusive a partida em andamento)
			prog[k] = d[k]
	prog["liberado"] = clampi(int(prog["liberado"]), 1, TOTAL_CAPITULOS)
	prog["fragmentos"] = int(prog["fragmentos"])
	modo = str(prog.get("modo", "normal"))
	var pt = prog.get("partida", null)
	if pt is Dictionary:
		# o iPhone recarregou a página no meio de um capítulo: volta nele, no mesmo modo
		modo = str(pt.get("modo", "normal"))
		cap_sel = int(pt.get("capitulo", 0))


func salvar() -> void:
	if robo:
		return
	var f := FileAccess.open(ARQUIVO, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(prog))
		f.close()   # fecha na hora: no navegador é aí que o arquivo vai para o armazenamento do aparelho


func mundo_de(c: int) -> int:
	return (c - 1) / CAPS_POR_MUNDO + 1


func feito(c: int) -> bool:
	return prog["feitos"].has(str(c))


func fim_capitulo(venceu: bool) -> void:
	var dobro := 2 if modo == "pesadelo" else 1
	if venceu:
		contar_missao("caps")
		if modo == "pesadelo":
			if not prog.has("feitos_p"):
				prog["feitos_p"] = {}
			premio_fim = (3 + mundo_de(capitulo) + (0 if prog["feitos_p"].has(str(capitulo)) else 3)) * dobro
			prog["feitos_p"][str(capitulo)] = true
			prog["liberado_p"] = maxi(int(prog.get("liberado_p", 1)), mini(capitulo + 1, TOTAL_CAPITULOS))
		else:
			premio_fim = 3 + mundo_de(capitulo) + (0 if feito(capitulo) else 3)
			prog["feitos"][str(capitulo)] = true
			prog["liberado"] = maxi(int(prog["liberado"]), mini(capitulo + 1, TOTAL_CAPITULOS))
	else:
		premio_fim = maxi(0, onda - 1) * dobro
	prog["fragmentos"] = int(prog["fragmentos"]) + premio_fim
	salvar()


func custo_melhoria(m: Dictionary) -> int:
	return int(m["custo"]) * (nivel_melhoria(m["id"]) + 1)


func comprar_melhoria(i: int) -> bool:
	var m: Dictionary = MELHORIAS[i]
	var lv := nivel_melhoria(m["id"])
	var c := custo_melhoria(m)
	if lv >= int(m["max"]) or int(prog["fragmentos"]) < c:
		return false
	prog["fragmentos"] = int(prog["fragmentos"]) - c
	prog["melhorias"][m["id"]] = lv + 1
	salvar()
	som("nivel")
	return true


func pode_melhorar() -> bool:
	for m in MELHORIAS:
		if nivel_melhoria(m["id"]) < int(m["max"]) and int(prog["fragmentos"]) >= custo_melhoria(m):
			return true
	return false


func comecar_capitulo(c: int) -> void:
	capitulo = clampi(c, 1, TOTAL_CAPITULOS)
	tela = "jogo"
	novo_jogo()
	retomar_partida()


# ------------------------------------------------------------ continuar de onde parou
# O Safari do iPhone às vezes recarrega a página (tela bloqueada, troca de app,
# falta de memória). Entre as ondas o jogo guarda o capítulo, a fase, a vida, a
# essência e os itens dos quadros; ao abrir o capítulo de novo, continua dali.
func salvar_partida() -> void:
	if robo or tela != "jogo" or estado != "loja":
		return
	var qs := []
	for q in quadros:
		qs.append(null if q == null else {"id": q["id"], "nv": int(q["nv"])})
	prog["partida"] = {"modo": modo, "capitulo": capitulo, "onda": onda, "essencia": essencia, "hp": hp, "escudo": escudo,
		"quadros": qs, "loja": loja, "trocas": trocas_gratis, "bonus_pendente": bonus_pendente,
		"premio_fim": premio_fim, "mortes": mortes, "tamanho": ANEL.size()}
	salvar()


func limpar_partida() -> void:
	if prog.has("partida"):
		prog.erase("partida")
		salvar()


func partida_guardada() -> Dictionary:
	var pt = prog.get("partida", null)
	return pt if pt is Dictionary else {}


func retomar_partida() -> void:
	var pt := partida_guardada()
	if pt.is_empty() or int(pt["capitulo"]) != capitulo or int(pt.get("tamanho", -1)) != ANEL.size() or str(pt.get("modo", "normal")) != modo:
		return
	onda = int(pt["onda"])
	essencia = int(pt["essencia"])
	hp = minf(hp_max, float(pt["hp"]))
	escudo = float(pt.get("escudo", 0.0))
	trocas_gratis = int(pt.get("trocas", 1))
	bonus_pendente = bool(pt.get("bonus_pendente", false))
	premio_fim = int(pt.get("premio_fim", 0))
	mortes = int(pt.get("mortes", 0))
	for i in mini(ANEL.size(), pt["quadros"].size()):
		var q = pt["quadros"][i]
		quadros[i] = null if q == null else {"id": str(q["id"]), "nv": int(q["nv"])}
	var lj: Array = pt.get("loja", [])
	if lj.size() == 3:
		loja = lj.map(func(x): return null if x == null else str(x))
	if bonus_pendente:
		aviso("Continuando: falta a fase bônus", 3.0)
	else:
		aviso("Continuando de onde parou: fase %d de %d" % [onda + 1, FASES], 3.0)


func _notification(what: int) -> void:
	# o app foi para segundo plano: guarda (vale entre as ondas)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		salvar_partida()


func ir_para(t: String) -> void:
	tela = t
	t_tela = 0.0
	if t == "mundos":
		# vindo de um capítulo, mostra o mundo dele; vindo do início, o próximo capítulo
		var c := capitulo if destaque_cap > 0 else liberado_modo()
		rolagem = clampf((mundo_de(c) - 1) * CARD_ALTO - 60.0, 0.0, rolagem_max())


func nivel_melhoria(id: String) -> int:
	return int(prog["melhorias"].get(id, 0))


# Monta o caminho do mundo do capítulo e calcula o tamanho dos quadros para
# caber na área do tabuleiro (entre o placar e a loja).
func forma_por_nome(nome: String) -> Array:
	if not nome.begins_with("anel "):
		return FORMAS[nome]
	var t := nome.substr(5).split("x")
	var c := int(t[0])
	var l := int(t[1])
	var v := []
	for x in c:
		v.append([x, 0])
	for y in range(1, l):
		v.append([c - 1, y])
	for x in range(c - 2, -1, -1):
		v.append([x, l - 1])
	for y in range(l - 2, 0, -1):
		v.append([0, y])
	return v


func montar_caminho() -> void:
	var w := clampi(mundo_de(capitulo) - 1, 0, CAMINHO_DO_MUNDO.size() - 1)
	var forma := forma_por_nome(CAMINHO_DO_MUNDO[w][0])
	var espelho: bool = CAMINHO_DO_MUNDO[w][1]
	var cols := 0
	var lins := 0
	for c in forma:
		cols = maxi(cols, c[0] + 1)
		lins = maxi(lins, c[1] + 1)
	ANEL = []
	for c in forma:
		ANEL.append(Vector2i(cols - 1 - c[0] if espelho else c[0], c[1]))
	if espelho:
		ANEL.reverse()   # continua andando no sentido horário
	PASSO_GRADE = minf(94.0, minf(460.0 / cols, 390.0 / lins))
	TAM = PASSO_GRADE - 10.0
	OX = (LARG - (cols - 1) * PASSO_GRADE - TAM) / 2.0
	OY = 196.0 + (390.0 - ((lins - 1) * PASSO_GRADE + TAM)) / 2.0
	# ponto de espera: o meio das casas vazias de dentro do caminho
	var soma := Vector2.ZERO
	var n := 0
	for y in range(1, lins - 1):
		for x in range(1, cols - 1):
			if not ANEL.has(Vector2i(x, y)):
				soma += Vector2(OX + x * PASSO_GRADE + TAM / 2, OY + y * PASSO_GRADE + TAM / 2)
				n += 1
	if n == 0:
		for i in ANEL.size():
			soma += centro_quadro(i)
		n = ANEL.size()
	CENTRO = soma / n


func novo_jogo() -> void:
	montar_caminho()
	onda = 0
	essencia = 25 + 6 * nivel_melhoria("essencia") + 3 * (capitulo - 1)
	hp_max = 150.0 + 20 * nivel_melhoria("vida")
	hp = hp_max
	# em caminhos maiores ele anda um pouco mais rápido, para a volta não demorar demais
	k_vel = 1.4 * (1.0 + 0.06 * nivel_melhoria("passo")) * sqrt(ANEL.size() / 12.0)
	k_vis = CENTRO + Vector2(0, -18)
	k_no_anel = false
	k_andando = false
	k_pausa = 0.0
	k_salto = 0.0
	fim_onda_t = -1.0
	escudo = 0.0
	bonus_pendente = false
	bonus_res = ""
	premio_bonus = 0
	torre_hp = 0.0
	quadros = []
	quadros.resize(ANEL.size())
	brilho = []
	brilho.resize(ANEL.size())
	brilho.fill(0.0)
	k_pos = 0.0
	k_rapido = 0.0
	k_mult = 1.0
	k_ultimo = 0
	k_dir = 1
	monstros = []
	tiros = []
	efeitos = []
	textos = []
	fila = []
	estado = "loja"
	selec = []
	vender = false
	trocas_gratis = 1 + nivel_melhoria("sorte")
	mortes = 0
	if capitulo == 1:
		aviso("Arraste um poder da loja até um quadro", 6.0)
	else:
		aviso("Capítulo %d · %s" % [capitulo, CAPITULOS[capitulo - 1]], 3.0)
	sortear_loja()


# ------------------------------------------------------------ tabuleiro
func centro_quadro(i: int) -> Vector2:
	var g: Vector2i = ANEL[i]
	return Vector2(OX + g.x * PASSO_GRADE + TAM / 2, OY + g.y * PASSO_GRADE + TAM / 2)


func ret_quadro(i: int) -> Rect2:
	var g: Vector2i = ANEL[i]
	return Rect2(OX + g.x * PASSO_GRADE, OY + g.y * PASSO_GRADE, TAM, TAM)


func pos_kravenox() -> Vector2:
	var a := int(k_pos) % ANEL.size()
	var b := (a + 1) % ANEL.size()
	var f := k_pos - floorf(k_pos)
	return centro_quadro(a).lerp(centro_quadro(b), f) + Vector2(0, -18)


# ------------------------------------------------------------ loja
func sortear_loja() -> void:
	loja = []
	var ids := ITENS.keys().filter(func(k): return ITEM_DESDE[k] <= capitulo)
	for _i in 3:
		loja.append(ids.pick_random())


func preco(iid: String) -> int:
	return ITENS[iid]["custo"] + (capitulo - 1) / 6


func valor_venda(q: Dictionary) -> int:
	return (ITENS[q["id"]]["custo"] * int(pow(2, q["nv"] - 1))) / 2


func colocar(i: int, item: Dictionary) -> bool:
	var q = quadros[i]
	if q == null:
		quadros[i] = item
		return true
	if q["id"] == item["id"] and q["nv"] == item["nv"] and q["nv"] < NIVEL_MAX:
		q["nv"] += 1
		contar_total("fusoes")
		if q["nv"] >= NIVEL_MAX:
			contar_total("nivel5")
		som("nivel")
		anel(centro_quadro(i), 10, 60, 0.4, OURO)
		aviso("Fundiu! %s nível %d" % [ITENS[q["id"]]["nome"], q["nv"]])
		return true
	return false


func aviso(t: String, dur := 2.5) -> void:
	msg = t
	msg_t = dur


# ------------------------------------------------------------ ondas
func iniciar_onda() -> void:
	if quadros.all(func(q): return q == null):
		aviso("Coloque pelo menos um poder num quadro!")
		return
	salvar_partida()
	onda += 1
	estado = "onda"
	selec = []
	vender = false
	var tipos := ["larva", "larva", "larva", "larva"]
	if capitulo >= MONSTRO_DESDE["esfera"]:
		tipos += ["esfera", "esfera", "esfera"]
	if capitulo >= MONSTRO_DESDE["verme"]:
		tipos += ["verme", "verme"]
	if capitulo >= MONSTRO_DESDE["sentinela"]:
		tipos += ["sentinela", "sentinela"]
	if capitulo >= 12:
		tipos += ["verme", "sentinela"]
	fila = []
	for _i in 4 + onda * 2 + mini(8, (capitulo - 1) / 3):
		fila.append(tipos.pick_random())
	if onda > FASES:
		# fase bônus: muitos monstros, rápidos, indo para a torre do centro
		bonus_pendente = false
		fila = []
		for _i in mini(30, 10 + capitulo / 2):
			fila.append(tipos.pick_random())
		torre_max = 200.0 + 40.0 * capitulo
		torre_hp = torre_max
		aviso("Fase bônus: os monstros vão atrás da torre!", 3.0)
		t_spawn = 0.8
		t_onda = 0.0
		gap = 0.45
		return
	if onda == FASES:
		var c := chefe_do_capitulo()
		fila.insert(3, c)
		aviso("Chefe: %s!" % MONSTROS[c]["nome"], 3.0)
	else:
		aviso("Fase %d de %d" % [onda, FASES], 1.5)
	t_spawn = 0.8
	t_onda = 0.0
	gap = maxf(0.35, 1.3 - onda * 0.1 - capitulo * 0.01)


# Nos dois primeiros capítulos de cada mundo, a Larva-Mãe; no terceiro, a
# Sentinela sem Rosto; no último, o Thornox.
func bonus_ativo() -> bool:
	return onda > FASES and estado == "onda"


func chefe_do_capitulo() -> String:
	var j := (capitulo - 1) % CAPS_POR_MUNDO
	return "thornox" if j == 3 else ("semrosto" if j == 2 else "larvamae")


func criar_monstro(tipo: String, p = null) -> void:
	var m: Dictionary = MONSTROS[tipo]
	if p == null:
		match randi_range(0, 2):
			0:
				p = Vector2(-40, randf_range(80, LOJA_Y - 40))
			1:
				p = Vector2(LARG + 40, randf_range(80, LOJA_Y - 40))
			_:
				p = Vector2(randf_range(0, LARG), -40)
	var chefe: bool = m.get("chefe", false)
	if chefe:
		som("thornox" if tipo == "thornox" else "chefe")
	prog["vistos"][tipo] = true
	var cresce := 0.10 * (capitulo - 1) - 0.035 * maxi(0, capitulo - 40)   # cresce mais devagar no Livro II
	var esc := (1.0 + cresce) * (1.0 + 0.12 * (onda - 1))
	var vida: float = m["hp"] * esc
	if chefe:
		vida = 170.0 * (1.0 + 1.3 * cresce) * {"larvamae": 1.0, "semrosto": 1.4, "thornox": 1.8}[tipo]
	var forte := 1.8 if modo == "pesadelo" else 1.0
	vida *= forte
	monstros.append({"tipo": tipo, "pos": p, "hp": vida, "hp_max": vida, "vel": m["vel"],
		"dano": m["dano"] * 0.7 * (1.0 + 0.03 * (capitulo - 1) + 0.05 * onda) * (1.4 if modo == "pesadelo" else 1.0),
		"premio": m["premio"] if not chefe else 10 + capitulo, "t_ataque": 0.0,
		"flash": 0.0, "anim": randf() * 2.0, "chefe": chefe, "t_poder": 4.0})


# ------------------------------------------------------------ poderes
func ativar(i: int) -> void:
	brilho[i] = 0.35
	# mordida básica: sempre acerta quem está colado nele (evita empate eterno)
	var kb := pos_kravenox()
	for m in monstros:
		if m["pos"].distance_to(kb) < 60:
			ferir(m, 5.0 + onda)
	var q = quadros[i]
	if q == null:
		return
	var nv: int = q["nv"]
	var mult := (1.0 + 0.8 * (nv - 1)) * (1.0 + 0.1 * nivel_melhoria("forca"))
	var k := pos_kravenox()
	match q["id"]:
		"garras":
			som("corte")
			var r := 105.0 + nv * 10
			efeitos.append({"t": "garra", "p": k, "r": r, "vida": 0.3})
			for m in monstros:
				var d: Vector2 = m["pos"] - k
				if d.length() < r:
					ferir(m, 17 * mult)
					if not m["chefe"]:
						m["pos"] += d.normalized() * 16   # o golpe empurra
					efeitos.append({"t": "arranhao", "p": m["pos"] + Vector2(0, -12), "vida": 0.28, "a": randf_range(-1.1, -0.6)})
		"espinhos":
			som("corte")
			var n := 8 + (nv - 1) * 2
			for j in n:
				var a := float(j) / n * TAU
				tiros.append({"p": k, "v": Vector2.from_angle(a) * 330, "dano": 9 * mult, "fura": 0,
					"vida": 1.0, "cor": Color8(30, 30, 40), "r": 5.0, "acertos": []})
		"raio":
			som("raio")
			var alvos := monstros.duplicate()
			alvos.sort_custom(func(x, y): return x["pos"].distance_to(k) < y["pos"].distance_to(k))
			var de := k
			for m in alvos.slice(0, 2 + nv):
				efeitos.append({"t": "raio", "a": de, "b": m["pos"], "vida": 0.2})
				ferir(m, 15 * mult)
				de = m["pos"]
		"esmagamento":
			som("esmagamento")
			var r := 150.0 + nv * 12
			anel(k + Vector2(0, 18), 20, r, 0.35, Color8(200, 150, 90))
			for m in monstros:
				if m["pos"].distance_to(k) < r:
					ferir(m, 16 * mult)
		"rasgo":
			som("corte")
			var alvo = mais_perto(k)
			var a: float = (alvo["pos"] - k).angle() if alvo != null else randf() * TAU
			var desvios := [0.0]
			if nv >= 5:
				desvios = [-0.3, 0.0, 0.3]
			elif nv >= 3:
				desvios = [-0.2, 0.2]
			for d in desvios:
				tiros.append({"p": k, "v": Vector2.from_angle(a + d) * 480, "dano": 24 * mult, "fura": 99,
					"vida": 1.4, "cor": Color8(220, 30, 90), "r": 9.0, "acertos": []})
		"cristal":
			som("gema")
			var cura := 4 + 3 * nv
			hp = minf(hp_max, hp + cura)
			texto_voa(k + Vector2(0, -40), "+%d" % cura, Color8(90, 220, 160))
			anel(k, 10, 50, 0.3, Color8(90, 220, 160))
		"passo":
			# salto: pula 2 quadros por nível sem ativar os do meio
			k_salto = float(mini(2 * nv, ANEL.size() - 1))
			texto_voa(k + Vector2(0, -44), "+%d quadros" % int(k_salto), VERDE)
			anel(k + Vector2(0, 18), 10, 40, 0.25, VERDE)
		"corrida":
			k_mult = 2.0 * nv
			k_rapido = 2.0 * nv
			texto_voa(k + Vector2(0, -44), "%dx" % int(k_mult), Color8(255, 170, 90))
			anel(k + Vector2(0, 18), 10, 44, 0.25, Color8(255, 150, 60))
		"escudo":
			var teto := 20.0 + 20.0 * nv
			if escudo < teto:
				som("nivel")
				var ganho := minf(4.0 + 4.0 * nv, teto - escudo)
				escudo += ganho
				texto_voa(k + Vector2(0, -44), "+%d escudo" % int(ganho), AZUL)
				anel(k, 20, 46, 0.3, AZUL)
		"fonte":
			som("gema")
			essencia += nv
			texto_voa(k + Vector2(0, -40), "+%d" % nv, OURO)
	anel(centro_quadro(i), 20, 50, 0.25, ITENS[q["id"]]["cor"])


func anel(p: Vector2, r0: float, r1: float, vida: float, cor: Color) -> void:
	efeitos.append({"t": "anel", "p": p, "r0": r0, "r1": r1, "vida": vida, "max": vida, "cor": cor})


func mais_perto(p: Vector2):
	var melhor = null
	var md := INF
	for m in monstros:
		var d: float = m["pos"].distance_to(p)
		if d < md:
			md = d
			melhor = m
	return melhor


func texto_voa(p: Vector2, t: String, cor: Color) -> void:
	textos.append({"p": p, "txt": t, "cor": cor, "vida": 0.8})


func ferir(m: Dictionary, dano: float) -> void:
	if m["hp"] <= 0:
		return
	var critico := randf() < 0.03 * nivel_melhoria("critico")
	if critico:
		dano *= 2.0
	m["hp"] -= dano
	m["flash"] = 0.1
	if critico:
		texto_voa(m["pos"] + Vector2(randf_range(-8, 8), -38), "%d!" % int(dano), OURO)
	else:
		texto_voa(m["pos"] + Vector2(randf_range(-8, 8), -30), str(int(dano)), BRANCO)
	if m["hp"] <= 0:
		contar_total("mortes")
		if m["chefe"]:
			contar_total("chefes")
		som("acerto")
		mortes += 1
		contar_missao("mortes")
		essencia += m["premio"]
		for _i in (40 if m["chefe"] else 10):
			efeitos.append({"t": "part", "p": m["pos"], "v": Vector2.from_angle(randf() * TAU) * randf_range(40, 160), "vida": 0.6})
		if m["premio"] > 0:
			texto_voa(m["pos"] + Vector2(0, -10), "+%d" % m["premio"], OURO)


# ------------------------------------------------------------ laço
func _process(delta: float) -> void:
	if robo:
		for _i in 300:
			if not passo_robo():
				return
			atualizar(1.0 / 60.0)
		return
	t_tela += delta
	if tela == "jogo":
		atualizar(minf(delta, 0.05))
	else:
		tempo += delta
	tocar_musica(musica_certa())
	queue_redraw()


func andar_no_anel(dt: float) -> void:
	if k_salto > 0:
		# no salto ele corre bem rápido e só o quadro onde cai dispara
		var antes_s := pos_kravenox().x
		var d := minf(k_salto, k_vel * 7.0 * dt)
		k_pos = fmod(k_pos + d, float(ANEL.size()))
		k_salto -= d
		k_anim += dt * k_vel * 14
		var depois_s := pos_kravenox().x
		if absf(depois_s - antes_s) > 0.01:
			k_dir = 1 if depois_s > antes_s else -1
		if k_salto <= 0.001:
			k_salto = 0.0
			var cai := int(k_pos + 0.5) % ANEL.size()
			k_ultimo = cai
			anel(centro_quadro(cai), 10, 50, 0.3, VERDE)
			ativar(cai)
		k_vis = pos_kravenox()
		k_andando = true
		return
	# corrida: 2x por 2 casas no nível 1, 4x por 4 casas no nível 2...
	var vel := k_vel * (k_mult if k_rapido > 0 else 1.0)
	if k_rapido > 0:
		k_rapido -= vel * dt
		if k_rapido <= 0:
			k_rapido = 0.0
			k_mult = 1.0
	var antes := pos_kravenox().x
	k_pos = fmod(k_pos + vel * dt, float(ANEL.size()))
	k_anim += dt * vel * 6
	var depois := pos_kravenox().x
	if absf(depois - antes) > 0.01:
		k_dir = 1 if depois > antes else -1
	var atual := int(k_pos + 0.5) % ANEL.size()   # o quadro em que ele está pisando
	if atual != k_ultimo:
		k_ultimo = atual
		ativar(atual)

	k_vis = pos_kravenox()
	k_andando = true


func atualizar(dt: float) -> void:
	dt *= vel_jogo
	if fim_onda_t > 0:
		fim_onda_t -= dt
		if fim_onda_t > 0.45:
			dt *= 0.4   # câmera lenta: dá para ver o último monstro morrer
	tempo += dt
	msg_t -= dt
	for i in ANEL.size():
		brilho[i] = maxf(0.0, brilho[i] - dt)
	var vivos := []
	for e in efeitos:
		e["vida"] -= dt
		if e["t"] == "part":
			e["p"] += e["v"] * dt
		if e["vida"] > 0:
			vivos.append(e)
	efeitos = vivos
	for t in textos:
		t["p"].y -= 40 * dt
		t["vida"] -= dt
	textos = textos.filter(func(t): return t["vida"] > 0)
	# Fora do anel ele anda a pé, no passo normal: para o meio quando a onda
	# acaba e de volta ao seu quadro quando a próxima começa.
	k_flash = maxf(0.0, k_flash - dt)
	escudo_flash = maxf(0.0, escudo_flash - dt)
	torre_flash = maxf(0.0, torre_flash - dt)
	if k_no_anel and estado != "onda":
		# a onda acabou: termina o passo até o próximo quadro, sem virar no meio
		var antes := k_vis.x
		var alvo_k := floorf(k_pos) + 1.0
		k_pos += k_vel * 0.8 * dt
		k_anim += dt * k_vel * 6
		if k_pos >= alvo_k:
			k_pos = fmod(alvo_k, float(ANEL.size()))
			k_no_anel = false
			k_pausa = 0.35
		k_vis = pos_kravenox()
		k_andando = true
		if absf(k_vis.x - antes) > 0.01:
			k_dir = 1 if k_vis.x > antes else -1
	elif k_pausa > 0 and estado != "onda":
		k_pausa -= dt
		k_andando = false
	elif not (estado == "onda" and k_no_anel):
		var alvo := pos_kravenox() if estado == "onda" else CENTRO + Vector2(0, -18)
		var d := alvo - k_vis
		# desacelera nos últimos passos, para chegar sem tranco
		var passo_px := k_vel * PASSO_GRADE * dt * clampf(d.length() / 45.0, 0.35, 1.0)
		k_andando = d.length() > 0.5
		if d.length() <= passo_px:
			k_vis = alvo
			k_andando = false
			if estado == "onda":
				k_no_anel = true
				k_ultimo = int(k_pos + 0.5) % ANEL.size()
		else:
			k_vis += d.normalized() * passo_px
			k_anim += dt * k_vel * 6
			if absf(d.x) > 1:
				k_dir = 1 if d.x > 0 else -1
	if estado != "onda":
		for t in tiros:
			t["p"] += t["v"] * dt
			t["vida"] -= dt
		tiros = tiros.filter(func(t): return t["vida"] > 0)
		if salvar_logo > 0:
			salvar_logo -= dt
			if salvar_logo <= 0 and not k_andando:
				salvar_logo = -1.0
				salvar_partida()
			elif salvar_logo <= 0:
				salvar_logo = 0.1
		return

	# o Kravenox anda sem parar (depois de chegar ao anel)
	if k_no_anel:
		andar_no_anel(dt)

	if not fila.is_empty():
		t_spawn -= dt
		if t_spawn <= 0:
			criar_monstro(fila.pop_front())
			t_spawn = gap * randf_range(0.6, 1.3)

	t_onda += dt
	var pressa := 1.0 + maxf(0.0, t_onda - 20.0) * 0.05
	var k := k_vis
	var novos := []
	for m in monstros:
		m["anim"] += dt
		m["flash"] -= dt
		var alvo_m: Vector2 = CENTRO + Vector2(0, -10) if bonus_ativo() else k
		var para: Vector2 = alvo_m - m["pos"]
		var alcance := 70.0 if m["chefe"] else (44.0 if bonus_ativo() else 34.0)
		if para.length() > alcance:
			m["pos"] += para.normalized() * m["vel"] * pressa * dt
		else:
			m["t_ataque"] -= dt
			if m["t_ataque"] <= 0:
				m["t_ataque"] = 1.0
				if bonus_ativo():
					torre_hp -= m["dano"]
					torre_flash = 0.15
					som("esmagamento")
					texto_voa(CENTRO + Vector2(0, -70), "-%d" % int(m["dano"]), VERMELHO)
				else:
					var dano: float = m["dano"] * (1.0 - 0.03 * nivel_melhoria("defesa"))
					if escudo > 0:
						var tira := minf(escudo, dano)
						escudo -= tira
						dano -= tira
						escudo_flash = 0.2
					hp -= dano
					som("dano")
					k_flash = 0.15
					texto_voa(k + Vector2(0, -50), "-%d" % int(m["dano"]), AZUL if dano <= 0 else VERMELHO)
		if m["chefe"]:
			m["t_poder"] -= dt
			if m["t_poder"] <= 0:
				m["t_poder"] = 5.0
				novos.append(m)
	for m in novos:
		var filhote: String = FILHOTES[m["tipo"]]
		for _i in 2:
			criar_monstro(filhote, m["pos"] + Vector2(randf_range(-40, 40), randf_range(-40, 40)))

	for t in tiros:
		t["p"] += t["v"] * dt
		t["vida"] -= dt
		for m in monstros:
			if m["hp"] <= 0 or t["acertos"].has(m):
				continue
			var raio := 50.0 if m["chefe"] else 18.0
			if m["pos"].distance_to(t["p"]) < raio + t["r"]:
				ferir(m, t["dano"])
				t["acertos"].append(m)
				if t["fura"] <= 0:
					t["vida"] = 0.0
					break
				t["fura"] -= 1
	tiros = tiros.filter(func(t): return t["vida"] > 0)
	monstros = monstros.filter(func(m): return m["hp"] > 0)

	if hp <= 0:
		hp = 0.0
		estado = "derrota"
		fim_capitulo(false)
		limpar_partida()
	elif bonus_ativo() and torre_hp <= 0:
		# a torre caiu: acaba o bônus, o capítulo já estava vencido
		torre_hp = 0.0
		bonus_res = "caiu"
		monstros.clear()
		fila.clear()
		tiros.clear()
		estado = "vitoria"
		limpar_partida()
	elif fila.is_empty() and monstros.is_empty():
		# o último monstro morreu: a onda acaba e o progresso é gravado NA HORA (se o
		# Safari recarregar logo depois, nada se perde); a câmera lenta é só visual
		fim_onda_t = 0.9
		efeitos.append({"t": "anel", "p": k_vis, "r0": 20, "r1": 160, "vida": 0.6, "max": 0.6, "cor": OURO})
		if bonus_ativo():
			bonus_res = "ok"
			if not prog.has("bonus"):
				prog["bonus"] = {}
			prog["bonus"][str(capitulo)] = true
			premio_bonus = (2 + mundo_de(capitulo)) * (2 if modo == "pesadelo" else 1)
			contar_missao("bonus")
			contar_total("bonus")
			premio_fim += premio_bonus
			prog["fragmentos"] = int(prog["fragmentos"]) + premio_bonus
			estado = "vitoria"
			limpar_partida()
		elif onda >= FASES:
			fim_capitulo(true)
			bonus_pendente = true
			estado = "loja"
			essencia += 8 + capitulo / 3
			hp = minf(hp_max, hp + 30)
			trocas_gratis = 1 + nivel_melhoria("sorte")
			sortear_loja()
			aviso("Capítulo vencido! Agora a fase bônus: defenda a torre", 4.0)
			salvar_partida()
		else:
			estado = "loja"
			var premio := 5 + onda + capitulo / 3
			essencia += premio
			hp = minf(hp_max, hp + 30)
			trocas_gratis = 1 + nivel_melhoria("sorte")
			sortear_loja()
			aviso("Onda vencida! +%d de essência, +30 vida" % premio, 3.0)
			salvar_partida()


# ------------------------------------------------------------ toque
func botoes() -> Dictionary:
	var b := {}
	for i in 3:
		b["loja%d" % i] = Rect2(26 + i * 148, LOJA_Y + 52, 132, 104)
	b["trocar"] = Rect2(24, ALT - 62, 130, 46)
	b["lixo"] = Rect2(170, ALT - 62, 60, 46)
	b["onda"] = Rect2(246, ALT - 62, 210, 46)
	b["vel"] = Rect2(LARG - 70, 92, 54, 36)
	b["som"] = Rect2(LARG - 116, 92, 40, 36)
	b["voltar"] = Rect2(10, 10, 36, 32)
	b["denovo"] = Rect2(LARG / 2 - 120, ALT / 2 + 30, 240, 54)
	b["mundos"] = Rect2(LARG / 2 - 120, ALT / 2 + 96, 240, 48)
	return b


func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		var p: Vector2 = make_input_local(ev).position
		if tela == "mundos" and ev.pressed and ev.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			rolagem = clampf(rolagem + (60.0 if ev.button_index == MOUSE_BUTTON_WHEEL_DOWN else -60.0), 0.0, rolagem_max())
			return
		if ev.button_index != MOUSE_BUTTON_LEFT:
			return
		if tela == "jogo":
			if ev.pressed:
				if not comecar_arrasto(p):
					clique(p)
			elif not arrasto.is_empty():
				soltar_arrasto(p)
			return
		# nos menus o toque vale ao soltar, para o mapa poder rolar com o dedo
		if ev.pressed:
			toque_ini = p
			toque_rola = rolagem
			arrastou = false
		elif not arrastou:
			clique_menu(p)
	elif ev is InputEventMouseMotion and tela == "jogo" and not arrasto.is_empty():
		var p: Vector2 = make_input_local(ev).position
		if p.distance_to(toque_ini) > 10:
			arrasto["moveu"] = true
		arrasto["p"] = p
	elif ev is InputEventMouseMotion and tela == "mundos" and (ev.button_mask & MOUSE_BUTTON_MASK_LEFT):
		var p: Vector2 = make_input_local(ev).position
		if p.distance_to(toque_ini) > 10:
			arrastou = true
		if arrastou:
			rolagem = clampf(toque_rola - (p.y - toque_ini.y), 0.0, rolagem_max())
	elif ev is InputEventKey and ev.pressed and ev.keycode == KEY_SPACE and tela == "jogo" and estado == "loja":
		iniciar_onda()


func clique(p: Vector2) -> void:
	clique_jogo(p)
	if tela == "jogo" and estado == "loja":
		salvar_partida()


func clique_jogo(p: Vector2) -> void:
	var b := botoes()
	if estado == "derrota" or estado == "vitoria":
		if b["denovo"].has_point(p):
			if estado == "vitoria" and capitulo >= TOTAL_CAPITULOS:
				ir_para("inicio")
			else:
				comecar_capitulo(capitulo + (1 if estado == "vitoria" else 0))
		elif b["mundos"].has_point(p):
			destaque_cap = capitulo if estado == "vitoria" else 0
			ir_para("mundos")
		return
	if b["voltar"].has_point(p):
		destaque_cap = capitulo   # volta para o mundo deste capítulo
		ir_para("mundos")
		return
	if b["vel"].has_point(p):
		vel_jogo = 2 if vel_jogo == 1 else 1
		return
	if b["som"].has_point(p):
		ligar_som(not som_ligado)
		return
	if estado != "loja":
		return
	for i in 3:
		if b["loja%d" % i].has_point(p) and loja[i] != null:
			if essencia < preco(loja[i]):
				aviso("Essência insuficiente")
				return
			vender = false
			selec = [] if selec == ["loja", i] else ["loja", i]
			return
	if b["trocar"].has_point(p):
		var custo := 0 if trocas_gratis > 0 else 2
		if essencia >= custo:
			essencia -= custo
			trocas_gratis = 0
			sortear_loja()
			selec = []
		else:
			aviso("Essência insuficiente")
		return
	if b["lixo"].has_point(p):
		vender = not vender
		selec = []
		aviso("Toque num quadro para vender" if vender else "", 2.0)
		return
	if b["onda"].has_point(p):
		iniciar_onda()
		return
	for i in ANEL.size():
		if ret_quadro(i).has_point(p):
			clique_quadro(i)
			return
	selec = []


func clique_quadro(i: int) -> void:
	var q = quadros[i]
	if vender:
		if q != null:
			var v := valor_venda(q)
			essencia += v
			quadros[i] = null
			aviso("Vendido por %d" % v)
		vender = false
		return
	if not selec.is_empty() and selec[0] == "loja":
		var li: int = selec[1]
		var iid: String = loja[li]
		var custo := preco(iid)
		if essencia >= custo and colocar(i, {"id": iid, "nv": 1}):
			essencia -= custo
			som("gema")
			loja[li] = null
		elif essencia >= custo:
			aviso("Quadro ocupado (só funde item igual e de mesmo nível)")
		selec = []
		return
	if not selec.is_empty() and selec[0] == "quadro":
		var de: int = selec[1]
		selec = []
		if de == i:
			return
		var item = quadros[de]
		if q == null:
			quadros[i] = item
			quadros[de] = null
		elif colocar(i, item.duplicate()):
			quadros[de] = null
		else:
			quadros[i] = item   # troca de lugar
			quadros[de] = q
		return
	if q != null:
		selec = ["quadro", i]


# Modo --robo: compra sozinho entre as ondas (prefere fundir) e inicia a próxima.
func passo_robo() -> bool:
	if estado == "vitoria" or estado == "derrota":
		var venceu := estado == "vitoria"
		var gastou := true
		while gastou:
			gastou = false
			var melhor := -1
			for i in MELHORIAS.size():
				var m: Dictionary = MELHORIAS[i]
				if nivel_melhoria(m["id"]) < int(m["max"]) and int(prog["fragmentos"]) >= custo_melhoria(m):
					if melhor < 0 or custo_melhoria(m) < custo_melhoria(MELHORIAS[melhor]):
						melhor = i
			if melhor >= 0:
				gastou = comprar_melhoria(melhor)
		print("ROBO cap %d: %s na fase %d (tentativa %d) · bônus %s · fragmentos %d · melhorias %s" % [capitulo,
			"venceu" if venceu else "perdeu", onda, robo_tentativas + 1, bonus_res, int(prog["fragmentos"]), str(prog["melhorias"])])
		if venceu:
			robo_tentativas = 0
			if capitulo >= TOTAL_CAPITULOS:
				print("ROBO fim: venceu os %d capítulos" % TOTAL_CAPITULOS)
				get_tree().quit()
				return false
			comecar_capitulo(capitulo + 1)
		else:
			robo_tentativas += 1
			if robo_tentativas >= 8:
				print("ROBO fim: parou no capítulo %d" % capitulo)
				get_tree().quit()
				return false
			comecar_capitulo(capitulo)
		return true
	if estado != "loja":
		return true
	var b := botoes()
	for i in 3:
		if loja[i] != null and essencia >= preco(loja[i]):
			clique(b["loja%d" % i].get_center())
			var alvo := -1
			for k in ANEL.size():
				if quadros[k] != null and quadros[k]["id"] == loja[i] and quadros[k]["nv"] == 1:
					alvo = k
					break
			if alvo < 0:
				alvo = quadros.find(null)
			if alvo >= 0:
				clique(ret_quadro(alvo).get_center())
			else:
				selec = []
	if essencia >= 14 and quadros.any(func(q): return q == null or q["nv"] < 3):
		clique(b["trocar"].get_center())
		return true
	clique(b["onda"].get_center())
	return true



# ------------------------------------------------------------ desenho
func caixa(r: Rect2, cor: Color, raio := 6, borda := 0, cor_borda := Color.BLACK, centro := true, sombra := 0) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = cor
	sb.draw_center = centro
	sb.set_corner_radius_all(raio)
	# sem suavização nem sombra desfocada: as duas geram muitas formas por caixa e
	# pesavam no celular. A sombra virou uma caixa escura deslocada.
	sb.anti_aliasing = false
	sb.corner_detail = 3
	if borda > 0:
		sb.set_border_width_all(borda)
		sb.border_color = cor_borda
	if sombra > 0 and centro:
		var sb2 := StyleBoxFlat.new()
		sb2.bg_color = Color(0, 0, 0, 0.45)
		sb2.set_corner_radius_all(raio + 1)
		sb2.anti_aliasing = false
		sb2.corner_detail = 3
		draw_style_box(sb2, Rect2(r.position + Vector2(0, 3), r.size + Vector2(0, 1)))
	draw_style_box(sb, r)


# Retângulo com degradê vertical (pedra iluminada de cima)
func degrade(r: Rect2, cima: Color, baixo: Color) -> void:
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([cima, cima, baixo, baixo]))


# Brilho redondo: uma imagem pronta de degradê, tingida (antes eram 6 círculos
# por brilho, o que pesava muito no celular).
var tex_brilho: Texture2D


func brilho_suave(c: Vector2, r: float, cor: Color, forca := 1.0) -> void:
	if tex_brilho == null:
		var n := 64
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d := Vector2(x + 0.5 - n / 2.0, y + 0.5 - n / 2.0).length() / (n / 2.0)
				var a := clampf(1.0 - d, 0.0, 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, a * a * 0.9 + a * 0.1))
		img.generate_mipmaps()
		tex_brilho = ImageTexture.create_from_image(img)
	draw_texture_rect(tex_brilho, Rect2(c - Vector2(r, r), Vector2(r, r) * 2), false, Color(cor, minf(1.0, 0.42 * forca)))


func escrever(t: String, centro: Vector2, tam: int, cor: Color, contorno := true, f: Font = null) -> void:
	if f == null:
		f = fonte
	var w := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	var p := Vector2(centro.x - w / 2, centro.y + tam * 0.36)
	if contorno:
		draw_string_outline(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 6, Color(TINTA, cor.a * 0.9))
	draw_string(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func escrever_esq(t: String, p: Vector2, tam: int, cor: Color, f: Font = null) -> void:
	if f == null:
		f = fonte
	draw_string_outline(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 6, Color(TINTA, 0.9))
	draw_string(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func botao(r: Rect2, t: String, cor: Color, ativo := true, cheio := false) -> void:
	var c := cor if ativo else Color(CINZA, 0.5)
	if cheio and ativo:
		caixa(r, Color(cor.darkened(0.55), 0.95), 7, 2, c, true, 4)
		degrade(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6, r.size.y * 0.4)), Color(1, 1, 1, 0.1), Color(1, 1, 1, 0))
	else:
		caixa(r, Color(0.07, 0.06, 0.09, 0.92), 7, 2, Color(c, 0.85), true, 4)
	escrever(t, r.get_center(), 18, c if not cheio else BRANCO, false)


func cristal(c: Vector2, s: float, cor := Color(0, 0, 0, 0)) -> void:
	if cor.a == 0:
		cor = ROXO
	brilho_suave(c, s * 2.2, cor, 0.8)
	var pts := PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.6, -s * 0.15), c + Vector2(0, s), c + Vector2(-s * 0.6, -s * 0.15)])
	draw_colored_polygon(pts, cor.darkened(0.3))
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.6, -s * 0.15), c + Vector2(0, s * 0.1)]), cor.lightened(0.35))
	pts.append(pts[0])
	draw_polyline(pts, Color(TINTA, 0.8), 1.2, true)


# Desenha uma arte com o pé em "base", altura "alt" na tela.
func desenhar_arte(nome: String, base: Vector2, alt: float, virar: bool, mod := Color.WHITE,
		branco := false, giro := 0.0, esmaga := Vector2.ONE) -> Rect2:
	var t: Texture2D = tex_branca[nome] if branco else tex[nome]
	var esc := alt / t.get_height()
	var tam := t.get_size() * esc
	draw_set_transform(base, giro, Vector2(-esmaga.x if virar else esmaga.x, esmaga.y))
	draw_texture_rect(t, Rect2(Vector2(-tam.x / 2, -tam.y), tam), false, mod)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	return Rect2(base.x - tam.x / 2, base.y - tam.y * esmaga.y, tam.x, tam.y * esmaga.y)


# Contorno de luz: a silhueta branca tingida, desenhada em volta da arte.
func contorno(nome: String, base: Vector2, alt: float, virar: bool, cor: Color, giro := 0.0, esmaga := Vector2.ONE) -> void:
	for d in [Vector2(-2, 0), Vector2(2, 0), Vector2(0, -2), Vector2(0, 2)]:
		desenhar_arte(nome, base + d, alt, virar, cor, true, giro, esmaga)


func sombra_chao(c: Vector2, rx: float, a := 0.55) -> void:
	draw_set_transform(c, 0, Vector2(1, 0.28))
	for k in 3:
		draw_circle(Vector2.ZERO, rx * (1.0 - k * 0.2), Color(0, 0, 0, a * 0.4))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)


func desenhar_fundo(veu := 0.38) -> void:
	# a pintura da Cratera do Cisma, escurecida para o que vem por cima aparecer
	draw_texture_rect(fundo, Rect2(0, 0, LARG, ALT), false)
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.03, 0.02, 0.06, veu))
	draw_texture_rect(vinheta, Rect2(0, 0, LARG, ALT), false)
	# névoa roxa lenta sobre a cratera
	for k in 3:
		var p := Vector2(LARG / 2 + sin(tempo * 0.2 + k * 2.1) * 120, 390 + cos(tempo * 0.17 + k) * 80)
		brilho_suave(p, 170, ROXO_ESC, 0.5)


func _draw() -> void:
	match tela:
		"abertura":
			desenhar_abertura()
		"inicio":
			desenhar_inicio()
		"mundos":
			desenhar_mundos()
		"melhorias":
			desenhar_melhorias()
		"bestiario":
			desenhar_bestiario()
		"missoes":
			desenhar_missoes()
		"kravenox":
			desenhar_kravenox_tela()
		"formas":
			desenhar_formas()
		"conquistas":
			desenhar_conquistas()
		"ajustes":
			desenhar_ajustes()
		_:
			desenhar_jogo()


func desenhar_jogo() -> void:
	desenhar_fundo()
	for i in ANEL.size():
		desenhar_quadro(i)
	desenhar_mundo()
	desenhar_topo()   # por cima dos monstros que entram pelo alto
	desenhar_loja()
	desenhar_arrasto()
	if msg_t > 0 and msg != "":
		var w := fonte.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		var a := clampf(msg_t * 2, 0, 1)
		caixa(Rect2(LARG / 2 - w / 2 - 14, 158, w + 28, 28), Color(0.05, 0.04, 0.07, 0.9 * a), 14, 1, Color(OURO, 0.7 * a))
		escrever(msg, Vector2(LARG / 2, 172), 18, Color(BRANCO, a), false)
	if estado == "derrota" or estado == "vitoria":
		draw_rect(Rect2(0, 0, LARG, ALT), Color(0.02, 0.01, 0.03, 0.84))
		var venceu := estado == "vitoria"
		var final := venceu and capitulo >= TOTAL_CAPITULOS
		var base := Vector2(LARG / 2, ALT / 2 - 110)
		brilho_suave(base + Vector2(0, -70), 120, OURO if venceu else VERMELHO, 0.7)
		desenhar_arte("kravenox", base, 140, false, Color.WHITE if venceu else Color(0.45, 0.4, 0.5))
		var titulo := "O REINO É DO KRAVENOX" if final else ("CAPÍTULO CONCLUÍDO" if venceu else "O KRAVENOX CAIU")
		escrever(titulo, Vector2(LARG / 2, ALT / 2 - 76), 26, OURO if venceu else VERMELHO, true, fonte_titulo)
		var t2 := "Capítulo %d · %s" % [capitulo, CAPITULOS[capitulo - 1]] if venceu else "Chegou à fase %d de %d" % [onda, FASES]
		escrever(t2, Vector2(LARG / 2, ALT / 2 - 42), 17, BRANCO)
		cristal(Vector2(LARG / 2 - 58, ALT / 2 - 8), 9, VERMELHO)
		escrever_esq("+%d fragmentos" % premio_fim, Vector2(LARG / 2 - 42, ALT / 2), 19, Color8(255, 170, 160))
		if bonus_res == "ok":
			escrever("Bônus: a torre ficou de pé! (+%d)" % premio_bonus, Vector2(LARG / 2, ALT / 2 + 18), 15, OURO, false)
		elif bonus_res == "caiu":
			escrever("Bônus: a torre caiu", Vector2(LARG / 2, ALT / 2 + 18), 15, CINZA, false)
		var t_botao := "Início" if final else ("Próximo capítulo" if venceu else "Tentar de novo")
		botao(botoes()["denovo"], t_botao, OURO, true, true)
		botao(botoes()["mundos"], "Mundos", AZUL)


func desenhar_topo() -> void:
	degrade(Rect2(0, 0, LARG, 150), Color(0.02, 0.01, 0.03, 0.85), Color(0.02, 0.01, 0.03, 0.0))
	var bv: Rect2 = botoes()["voltar"]
	botao(bv, "", OURO)
	draw_polyline(PackedVector2Array([bv.get_center() + Vector2(4, -8), bv.get_center() + Vector2(-4, 0), bv.get_center() + Vector2(4, 8)]), OURO, 2.5, true)
	var t := "FASE %d/%d" % [maxi(onda, 1) if estado == "onda" else mini(onda + 1, FASES), FASES]
	if onda > FASES or bonus_pendente:
		t = "BÔNUS"
	var w := fonte_titulo.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	escrever_esq(t, Vector2(LARG - 16 - w, 31), 14, BRANCO, fonte_titulo)
	var tit := encurtar(("PESADELO · " if modo == "pesadelo" else "") + "CAP. %d · %s" % [capitulo, CAPITULOS[capitulo - 1].to_upper()], fonte_titulo, 13, LARG - 80 - w)
	escrever_esq(tit, Vector2(56, 31), 13, OURO, fonte_titulo)
	# trilha das fases
	var y := 60.0
	var x0 := 70.0
	var x1 := LARG - 70.0
	draw_line(Vector2(x0, y), Vector2(x1, y), Color(0, 0, 0, 0.7), 5)
	var feito_x := x0 + (x1 - x0) * clampf((onda - 1) / float(FASES - 1), 0, 1)
	if onda > 1:
		draw_line(Vector2(x0, y), Vector2(feito_x, y), SANGUE, 3)
	# a estrela do bônus, depois da fase do chefe
	var pe := Vector2(x1 + 34, y)
	var no_bonus := onda > FASES or bonus_pendente
	draw_line(Vector2(x1, y), pe, Color(0, 0, 0, 0.7), 3)
	if onda > FASES and estado == "onda":
		brilho_suave(pe, 24, OURO, 1.4)
	var est := []
	for k in 10:
		est.append(pe + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (9.0 if k % 2 == 0 else 4.0))
	poli(est, OURO if no_bonus else PEDRA_CLARA, 1.2)
	for o in range(1, FASES + 1):
		var x := x0 + (x1 - x0) * (o - 1) / (FASES - 1)
		var p := Vector2(x, y)
		var feita := o < onda or (o == onda and estado != "onda")
		var atual := o == onda and estado == "onda"
		if o == FASES:
			var r := 10.0
			var cor := ROXO if not feita else SANGUE
			if atual:
				brilho_suave(p, 26, ROXO, 1.4)
			var d := PackedVector2Array([p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0)])
			draw_colored_polygon(d, PEDRA_ESC)
			var d2 := d.duplicate()
			d2.append(d[0])
			draw_polyline(d2, cor, 2, true)
			draw_circle(p, 3, cor)
		else:
			if atual:
				brilho_suave(p, 20, VERMELHO, 1.5)
			draw_circle(p, 8.5, TINTA)
			draw_circle(p, 7, VERMELHO if atual else (SANGUE if feita else PEDRA_CLARA))
	# essência
	caixa(Rect2(16, 84, 122, 40), Color(0.05, 0.04, 0.07, 0.85), 8, 1, Color(ROXO, 0.5))
	cristal(Vector2(38, 104), 11)
	escrever_esq(str(essencia), Vector2(58, 113), 24, BRANCO)
	# vida
	var bw := 196.0
	var bx := 148.0
	caixa(Rect2(bx, 88, bw, 30), Color(0.05, 0.04, 0.07, 0.9), 8, 1, Color(VERMELHO, 0.5))
	var fr := clampf(hp / hp_max, 0, 1)
	if fr > 0:
		var r := Rect2(bx + 4, 92, (bw - 8) * fr, 22)
		degrade(r, Color8(200, 40, 44), Color8(110, 14, 20))
		draw_line(r.position + Vector2(2, 3), Vector2(r.end.x - 2, r.position.y + 3), Color(1, 1, 1, 0.18), 2)
	if escudo > 0:
		var re := Rect2(bx + 4, 110, (bw - 8) * clampf(escudo / hp_max, 0, 1), 5)
		degrade(re, Color8(150, 200, 255), Color8(60, 110, 220))
	var tv := "%d / %d" % [int(maxf(0, hp)), int(hp_max)]
	if escudo > 0:
		tv += "  +%d" % int(escudo)
	escrever(tv, Vector2(bx + bw / 2, 103), 16, BRANCO)
	botao(botoes()["vel"], "x%d" % vel_jogo, OURO)
	var bs: Rect2 = botoes()["som"]
	botao(bs, "", OURO if som_ligado else CINZA)
	var c := bs.get_center() + Vector2(-4, 0)
	var cor := OURO if som_ligado else CINZA
	draw_colored_polygon(PackedVector2Array([c + Vector2(-8, -4), c + Vector2(-3, -4), c + Vector2(3, -10),
		c + Vector2(3, 10), c + Vector2(-3, 4), c + Vector2(-8, 4)]), cor)
	if som_ligado:
		draw_arc(c + Vector2(4, 0), 6, -0.9, 0.9, 8, cor, 2, true)
		draw_arc(c + Vector2(4, 0), 11, -0.9, 0.9, 10, cor, 2, true)
	else:
		draw_line(c + Vector2(7, -5), c + Vector2(15, 5), cor, 2, true)
		draw_line(c + Vector2(15, -5), c + Vector2(7, 5), cor, 2, true)


var tex_laje := {}


# Pinta a laje de pedra uma vez (com borda, degradê, miolo e rachaduras) e a
# reaproveita em todos os quadros. A versão vazia já traz o "+" roxo.
func textura_laje(vazia: bool) -> Texture2D:
	if tex_laje.has(vazia):
		return tex_laje[vazia]
	var n := 100
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var m := 3   # margem para a sombra
	img.fill_rect(Rect2i(m + 1, m + 4, n - 2 * m, n - 2 * m), Color(0, 0, 0, 0.5))   # sombra
	for y in range(m, n - m):
		var t := float(y - m) / (n - 2 * m)
		var cor := PEDRA_CLARA.lerp(PEDRA_ESC, t)
		img.fill_rect(Rect2i(m, y, n - 2 * m, 1), cor)
	var b := PEDRA_BORDA
	img.fill_rect(Rect2i(m, m, n - 2 * m, 2), b)
	img.fill_rect(Rect2i(m, n - m - 2, n - 2 * m, 2), b)
	img.fill_rect(Rect2i(m, m, 2, n - 2 * m), b)
	img.fill_rect(Rect2i(n - m - 2, m, 2, n - 2 * m), b)
	var dentro := Rect2i(m + 8, m + 8, n - 2 * m - 16, n - 2 * m - 16)
	img.fill_rect(dentro, Color(0.06, 0.05, 0.08, 1).lerp(PEDRA_ESC, 0.35))
	img.fill_rect(Rect2i(dentro.position, Vector2i(dentro.size.x, 1)), Color(0, 0, 0, 0.6))
	img.fill_rect(Rect2i(dentro.position, Vector2i(1, dentro.size.y)), Color(0, 0, 0, 0.6))
	for k in [[20, 30, 1, 1], [60, 70, 1, -1], [70, 20, -1, 1]]:
		for j in 12:
			img.set_pixel(k[0] + j * k[2], k[1] + j * k[3] / 2, Color(0, 0, 0, 0.45))
	# cantos arredondados de leve
	for c in [Vector2i(m, m), Vector2i(n - m - 1, m), Vector2i(m, n - m - 1), Vector2i(n - m - 1, n - m - 1)]:
		img.set_pixelv(c, Color(0, 0, 0, 0))
	if vazia:
		var cc := Color(ROXO, 0.3)
		var meio := n / 2
		img.fill_rect(Rect2i(meio - 11, meio - 1, 22, 2), cc)
		img.fill_rect(Rect2i(meio - 1, meio - 11, 2, 22), cc)
		for k in 64:
			var a := k * TAU / 64
			img.set_pixel(meio + int(cos(a) * 17), meio + int(sin(a) * 17), Color(ROXO, 0.2))
	img.generate_mipmaps()
	tex_laje[vazia] = ImageTexture.create_from_image(img)
	return tex_laje[vazia]


func desenhar_quadro(i: int) -> void:
	var r := ret_quadro(i)
	var q = quadros[i]
	var sel := selec == ["quadro", i]
	var luz: float = brilho[i] / 0.35
	# laje de pedra: uma imagem pronta (antes eram várias caixas e linhas por quadro)
	draw_texture_rect(textura_laje(q == null), r.grow(3), false)
	if luz > 0:
		caixa(r.grow(1), Color(0, 0, 0, 0), 7, 3, Color(ROXO, luz), false)
		brilho_suave(r.get_center(), 60, ROXO, luz)
	if sel or (vender and q != null):
		caixa(r.grow(3), Color(0, 0, 0, 0), 8, 3, OURO if sel else VERMELHO, false)
	var c := r.get_center()
	if q == null:
		pass   # o "+" roxo já vem na imagem da laje vazia
	elif not (not arrasto.is_empty() and arrasto["moveu"] and arrasto["de"] == "quadro" and arrasto["i"] == i):
		icone(q["id"], c + Vector2(0, -4), 0.95)
		# nível em marcas douradas
		var n: int = q["nv"]
		for k in n:
			var px := c.x + (k - (n - 1) / 2.0) * 10
			var p := Vector2(px, r.end.y - 11)
			var d := PackedVector2Array([p + Vector2(0, -4), p + Vector2(3.5, 0), p + Vector2(0, 4), p + Vector2(-3.5, 0)])
			draw_colored_polygon(d, OURO)


func poli(pts: Array, cor: Color, borda := 0.0, cor_borda := Color(0, 0, 0, 0.85)) -> void:
	var p := PackedVector2Array(pts)
	draw_colored_polygon(p, cor)
	if borda > 0:
		p.append(p[0])
		draw_polyline(p, cor_borda, borda, true)


func icone(iid: String, c: Vector2, e: float) -> void:
	var cor: Color = ITENS[iid]["cor"]
	var P := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * e
	brilho_suave(c, 34 * e, cor, 0.9)
	match iid:
		"garras":
			# três garras curvas, vermelho escuro com fio claro
			for k in [-11.0, 0.0, 11.0]:
				var pts := []
				for j in 7:
					var t := j / 6.0
					pts.append(P.call(k - 5 + t * 9 + sin(t * 2.4) * 4, 18 - t * 38))
				for j in range(6, -1, -1):
					var t := j / 6.0
					pts.append(P.call(k + 1 + t * 5 + sin(t * 2.4) * 4, 18 - t * 38 + t * 2))
				poli(pts, cor.darkened(0.45), 1.5)
				draw_line(P.call(k - 2, 14), P.call(k + 6, -16), Color(1, 0.75, 0.7, 0.7), 1.5, true)
		"espinhos":
			var pts := []
			for j in 24:
				var a := j / 24.0 * TAU
				var rr := 24.0 if j % 2 == 0 else 10.0
				pts.append(P.call(cos(a) * rr, sin(a) * rr))
			poli(pts, Color8(16, 12, 18), 1.0, Color(cor, 0.7))
			draw_circle(c, 7 * e, cor.darkened(0.3))
			draw_circle(c + Vector2(-2, -2) * e, 3 * e, Color(1, 0.6, 0.6, 0.8))
		"raio":
			var pts := [P.call(-3, -26), P.call(11, -26), P.call(3, -6), P.call(12, -6), P.call(-9, 26), P.call(-2, 3), P.call(-11, 3)]
			poli(pts, cor.darkened(0.2), 1.5)
			draw_polyline(PackedVector2Array([P.call(5, -22), P.call(-1, -2), P.call(6, -3), P.call(-4, 16)]), Color(1, 0.92, 1, 0.9), 1.5, true)
		"esmagamento":
			draw_arc(P.call(0, 10), 26 * e, PI * 1.1, PI * 1.9, 20, Color(cor, 0.8), 2, true)
			poli([P.call(-16, 4), P.call(-8, -12), P.call(8, -14), P.call(17, 0), P.call(10, 12), P.call(-10, 12)], Color8(70, 58, 52), 1.5)
			draw_polyline(PackedVector2Array([P.call(-4, -10), P.call(0, -2), P.call(-6, 6)]), Color(0, 0, 0, 0.8), 1.5, true)
			draw_polyline(PackedVector2Array([P.call(0, -2), P.call(9, 3)]), Color(0, 0, 0, 0.8), 1.5, true)
			for k in [-1.0, 1.0]:
				draw_line(P.call(k * 20, 16), P.call(k * 28, 22), Color(cor, 0.8), 2, true)
		"rasgo":
			draw_set_transform(c, 0.35, Vector2(0.34, 1.0))
			draw_circle(Vector2.ZERO, 27 * e, Color(cor, 0.5))
			draw_circle(Vector2.ZERO, 22 * e, cor)
			draw_circle(Vector2.ZERO, 15 * e, Color8(20, 4, 10))
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		"cristal":
			for d in [[-10.0, 6.0, 12.0], [10.0, 8.0, 10.0], [0.0, -2.0, 20.0]]:
				var x: float = d[0]
				var y: float = d[1]
				var s: float = d[2]
				var pts := [P.call(x, y - s), P.call(x + s * 0.45, y), P.call(x, y + s * 0.6), P.call(x - s * 0.45, y)]
				poli(pts, cor.darkened(0.25), 1.2)
				poli([P.call(x, y - s), P.call(x + s * 0.45, y), P.call(x, y + s * 0.1)], Color(cor.lightened(0.4), 0.9))
		"passo":
			# salto: um arco com a ponta de seta
			draw_arc(P.call(0, 14), 20 * e, PI * 1.05, PI * 1.95, 18, Color(0, 0, 0, 0.8), 6, true)
			draw_arc(P.call(0, 14), 20 * e, PI * 1.05, PI * 1.95, 18, cor, 3.5, true)
			poli([P.call(14, 2), P.call(24, 4), P.call(19, 14)], cor, 1.2)
			draw_circle(P.call(-19, 16), 3.5 * e, cor)
			draw_circle(P.call(19, 16), 3.5 * e, Color(cor, 0.5))
		"corrida":
			for k in [-9.0, 5.0]:
				poli([P.call(k - 9, -15), P.call(k + 7, 0), P.call(k - 9, 15), P.call(k - 3, 0)], cor.darkened(0.2), 1.5)
			for y in [-8.0, 0.0, 8.0]:
				draw_line(P.call(-26, y), P.call(-16, y), Color(cor, 0.55), 2)
		"escudo":
			var pts := [P.call(0, -24), P.call(18, -16), P.call(16, 6), P.call(0, 24), P.call(-16, 6), P.call(-18, -16)]
			poli(pts, cor.darkened(0.35), 1.5)
			poli([P.call(0, -18), P.call(12, -12), P.call(10, 4), P.call(0, 16)], Color(cor.lightened(0.3), 0.9))
			for k in [-1.0, 1.0]:
				poli([P.call(k * 18, -16), P.call(k * 26, -24), P.call(k * 14, -20)], Color8(20, 16, 24))
		"fonte":
			cristal(c, 22 * e, cor)
			for k in 3:
				var a := tempo * 1.5 + k * TAU / 3
				draw_circle(c + Vector2(cos(a), sin(a) * 0.6) * 22 * e, 2 * e, Color(1, 0.9, 1, 0.8))


func desenhar_mundo() -> void:
	var k := k_vis
	var itens := []
	for m in monstros:
		itens.append([m["pos"].y, m])
	itens.append([k.y, null])
	if bonus_ativo() or (estado == "vitoria" and bonus_res != ""):
		itens.append([CENTRO.y + 20, "torre"])
	itens.sort_custom(func(a, b): return a[0] < b[0])
	for it in itens:
		var m = it[1]
		if m == null:
			desenhar_kravenox(k)
		elif m is String:
			desenhar_torre()
		else:
			desenhar_monstro(m, k)
	# tiros: orbes com brilho
	for t in tiros:
		brilho_suave(t["p"], t["r"] * 3, t["cor"], 1.2)
		draw_circle(t["p"], t["r"], t["cor"])
		draw_circle(t["p"], t["r"] * 0.5, Color(1, 0.9, 0.9, 0.9))
	for e in efeitos:
		match e["t"]:
			"part":
				var a := clampf(e["vida"] / 0.6, 0, 1)
				draw_circle(e["p"], 2.5, Color(ROXO.lightened(0.3), a))
				draw_circle(e["p"], 6, Color(ROXO, a * 0.2))
			"anel":
				var f := clampf(1.0 - e["vida"] / e["max"], 0, 1)
				var rr := lerpf(e["r0"], e["r1"], f)
				draw_arc(e["p"], rr, 0, TAU, 48, Color(e["cor"], (1.0 - f) * 0.35), 9, true)
				draw_arc(e["p"], rr, 0, TAU, 48, Color(e["cor"], 1.0 - f), 2.5, true)
			"garra":
				# uma varrida rápida em volta dele, que some no fim
				var f: float = 1.0 - e["vida"] / 0.3
				var a0 := -PI / 2 + f * TAU * 0.9
				var alfa := 1.0 - f * f
				var rr: float = e["r"] * (0.75 + 0.25 * f)
				draw_arc(e["p"], rr, a0 - 1.6, a0, 24, Color(0.9, 0.1, 0.1, 0.25 * alfa), 16, true)
				draw_arc(e["p"], rr, a0 - 1.2, a0, 20, Color(1, 0.35, 0.3, 0.7 * alfa), 5, true)
				draw_arc(e["p"], rr, a0 - 0.7, a0, 14, Color(1, 0.9, 0.85, alfa), 2, true)
			"arranhao":
				# três riscos de garra em cima do monstro
				var f: float = clampf(1.0 - e["vida"] / 0.28, 0, 1)
				var dir := Vector2.from_angle(e["a"])
				var lado := dir.orthogonal()
				var alfa := 1.0 if f < 0.6 else (1.0 - f) / 0.4
				var cresce := minf(1.0, f * 3.0)
				for j in 3:
					var o: Vector2 = e["p"] + lado * (j - 1) * 8 - dir * 16
					var fim := o + dir * 32 * cresce
					draw_line(o, fim, Color(0.7, 0.05, 0.08, 0.6 * alfa), 6, true)
					draw_line(o, fim, Color(1, 0.85, 0.8, alfa), 2, true)
			"raio":
				var a: Vector2 = e["a"]
				var b: Vector2 = e["b"]
				var pts := PackedVector2Array([a])
				for j in range(1, 7):
					pts.append(a.lerp(b, j / 7.0) + Vector2(randf_range(-9, 9), randf_range(-9, 9)))
				pts.append(b)
				draw_polyline(pts, Color(ROXO, 0.35), 8, true)
				draw_polyline(pts, Color8(235, 215, 255), 2, true)
	var chefe = null
	for m in monstros:
		if m["chefe"]:
			chefe = m
			break
	if chefe != null:
		var w := LARG - 60
		caixa(Rect2(28, 134, w + 4, 14), Color(0.05, 0.04, 0.07, 0.9), 4, 1, Color(ROXO, 0.6))
		degrade(Rect2(31, 137, (w - 2) * chefe["hp"] / chefe["hp_max"], 8), Color8(170, 90, 255), Color8(80, 30, 140))
		escrever(MONSTROS[chefe["tipo"]]["nome"].to_upper(), Vector2(LARG / 2, 160), 13, Color8(210, 180, 255), true, fonte_titulo)
	for t in textos:
		var cor: Color = t["cor"]
		cor.a = minf(1.0, t["vida"] * 2)
		escrever(t["txt"], t["p"], 18, cor)


func desenhar_kravenox(k: Vector2) -> void:
	# Mesmo andar da primeira versão: troca de quadro de passo, sem balanço.
	var n := (int(k_anim) % 4) if k_andando else 0
	var nome := "kravenox-passo-%d" % n
	var base := k + Vector2(0, 30)
	sombra_chao(base, 30)
	if k_salto > 0:
		# rastro verde do salto
		for j in 3:
			draw_circle(k + Vector2(-k_dir * (12 + j * 12), -4), 14 - j * 3, Color(VERDE, 0.25 - j * 0.07))
	if k_rapido > 0:
		# riscos de velocidade laranja atrás dele
		var laranja := Color8(255, 150, 60)
		for j in 4:
			var y := -20.0 + j * 11
			var tam := 18.0 + 6 * minf(k_mult, 6.0) + (j % 2) * 8
			var ini := k + Vector2(-k_dir * 18, y)
			draw_line(ini, ini + Vector2(-k_dir * tam, 0), Color(laranja, 0.55), 3, true)
	brilho_suave(k + Vector2(0, -4), 48, cor_forma(), 0.4)
	desenhar_arte(nome, base, 68, k_dir < 0)
	if k_flash > 0:
		desenhar_arte(nome, base, 68, k_dir < 0, Color(1, 0.3, 0.3, k_flash * 4), true)
	if escudo > 0:
		# bolha de escudo: mais forte quanto mais escudo
		var a := clampf(escudo / 60.0, 0.25, 0.8) + escudo_flash * 2
		draw_circle(k + Vector2(0, -6), 42, Color(AZUL, 0.08 * a))
		draw_arc(k + Vector2(0, -6), 42, 0, TAU, 40, Color(Color8(150, 200, 255), a), 2, true)
		draw_arc(k + Vector2(0, -6), 42, -2.4, -1.6, 10, Color(1, 1, 1, a), 2, true)


func desenhar_monstro(m: Dictionary, k: Vector2) -> void:
	var info: Dictionary = MONSTROS[m["tipo"]]
	var alt: float = info["alt"]
	var p: Vector2 = m["pos"]
	var t: float = m["anim"]
	var base := p + Vector2(0, alt * 0.4)
	var giro := 0.0
	var esmaga := Vector2.ONE
	var sobe := 0.0
	match info["anda"]:
		"rasteja":
			var s := sin(t * 5)
			esmaga = Vector2(1.0 + 0.07 * s, 1.0 - 0.07 * s)
		"flutua":
			sobe = 10 + sin(t * 3) * 5
			giro = sin(t * 2) * 0.08
		"morde":
			var s := maxf(0.0, sin(t * 6))
			esmaga = Vector2(1.0 + 0.08 * s, 1.0 - 0.05 * s)
			giro = -0.08 * s
		"marcha":
			giro = sin(t * 4) * 0.05
			sobe = absf(sin(t * 4)) * 3
	var virar := p.x > k.x   # as artes olham para a direita
	if info["img"] == "larva" or info["img"] == "verme":
		virar = p.x < k.x     # estas pinturas olham para a esquerda
	sombra_chao(base, alt * 0.42, 0.6)
	if m["chefe"]:
		brilho_suave(p, alt * 0.9, ROXO if m["tipo"] != "thornox" else AZUL, 0.6 + 0.2 * sin(tempo * 2))
	var mod: Color = info.get("tinta", Color.WHITE)
	var luz := AZUL if m["tipo"] == "thornox" else ROXO
	contorno(info["img"], base - Vector2(0, sobe), alt, virar, Color(luz, 0.75 if m["chefe"] else 0.5), giro, esmaga)
	var r := desenhar_arte(info["img"], base - Vector2(0, sobe), alt, virar, mod, false, giro, esmaga)
	if m["flash"] > 0:
		desenhar_arte(info["img"], base - Vector2(0, sobe), alt, virar, Color(1, 1, 1, 0.85), true, giro, esmaga)
	if m["hp"] < m["hp_max"] and not m["chefe"]:
		var w := 34.0
		var y := r.position.y - 8
		draw_rect(Rect2(p.x - w / 2 - 1, y - 1, w + 2, 5), Color(0, 0, 0, 0.8))
		draw_rect(Rect2(p.x - w / 2, y, w * m["hp"] / m["hp_max"], 3), VERMELHO)


func desenhar_loja() -> void:
	var b := botoes()
	var painel := Rect2(6, LOJA_Y, LARG - 12, ALT - LOJA_Y - 4)
	caixa(painel, Color(0.04, 0.03, 0.06, 0.94), 10, 2, OURO_ESC, true, 10)
	caixa(painel.grow(-5), Color(0, 0, 0, 0), 7, 1, Color(OURO, 0.18), false)
	# placa do título
	var placa := Rect2(LARG / 2 - 70, LOJA_Y - 15, 140, 32)
	caixa(placa, Color8(26, 20, 34), 6, 2, OURO, true, 6)
	escrever("LOJA", placa.get_center(), 17, OURO, false, fonte_titulo)
	for lado in [-1.0, 1.0]:
		var p := Vector2(LARG / 2 + lado * 92, LOJA_Y + 1)
		draw_line(p, p + Vector2(lado * 120, 0), Color(OURO, 0.4), 1)
		cristal(p, 4, OURO)
	var ativa := estado == "loja"
	for i in 3:
		var r: Rect2 = b["loja%d" % i]
		var iid = loja[i]
		caixa(r, Color8(22, 18, 28), 8, 1, PEDRA_BORDA, true, 4)
		if iid == null:
			escrever("vendido", r.get_center(), 15, Color(CINZA, 0.5), false)
			continue
		var custo := preco(iid)
		var pode := essencia >= custo and ativa
		if selec == ["loja", i]:
			caixa(r.grow(2), Color(0, 0, 0, 0), 9, 3, OURO, false)
		var cx := r.get_center().x
		var area := Rect2(cx - 40, r.position.y + 21, 80, 42)
		degrade(area, Color(0.12, 0.09, 0.16), Color(0.05, 0.04, 0.07))
		icone(iid, area.get_center(), 0.62)
		escrever(ITENS[iid]["nome"], Vector2(cx, r.position.y + 12), 14, BRANCO, false)
		escrever(ITENS[iid]["curta"], Vector2(cx, r.position.y + 71), 12, Color8(200, 190, 210), false)
		cristal(Vector2(cx - 16, r.end.y - 14), 7)
		escrever_esq(str(custo), Vector2(cx - 5, r.end.y - 6), 20, BRANCO if pode else Color8(200, 80, 80))
		if not ativa:
			draw_rect(r, Color(0, 0, 0, 0.45))
	var t_trocar := "Trocar grátis" if trocas_gratis > 0 else "Trocar (2)"
	botao(b["trocar"], t_trocar if ativa else "Trocar", AZUL, ativa)
	botao(b["lixo"], "Vender", VERMELHO, ativa, vender)
	var t_onda_b := ("Fase bônus" if bonus_pendente else "Iniciar onda %d" % (onda + 1)) if ativa else "Onda em andamento"
	botao(b["onda"], t_onda_b, OURO, ativa, ativa)
	var dica := "Arraste o item até um quadro"
	if estado == "onda":
		dica = "Monstros: %d  ·  na fila: %d" % [monstros.size(), fila.size()]
	elif vender:
		dica = "Toque num quadro para vender o item"
	elif not selec.is_empty() and selec[0] == "loja":
		var it: Dictionary = ITENS[loja[selec[1]]]
		dica = "%s: %s. Toque num quadro." % [it["nome"], it["desc"]]
	elif not selec.is_empty() and selec[0] == "quadro" and quadros[selec[1]] != null:
		var q: Dictionary = quadros[selec[1]]
		dica = "%s nível %d: %s. Toque em outro quadro para mover." % [ITENS[q["id"]]["nome"], q["nv"], ITENS[q["id"]]["desc"]]
	desenhar_dica(dica, Vector2(LARG / 2, LOJA_Y + 32), LARG - 36)


# ============================================================ telas de menu
const MSG_ABERTURA := ["Despertando no Reino Quebrado...", "Ouvindo os ecos do Cisma...", "Juntando a Essência...", "Toque para começar"]
const DURA_ABERTURA := 1.8
const ORDEM_BESTIARIO := ["larva", "esfera", "verme", "sentinela", "larvamae", "semrosto", "thornox"]
const CARD_MUNDO := 168.0
const TOPO_MUNDOS := 118.0


func encurtar(t: String, f: Font, tam: int, largura: float) -> String:
	if f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x <= largura:
		return t
	while t.length() > 4 and f.get_string_size(t + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > largura:
		t = t.substr(0, t.length() - 1)
	return t.strip_edges() + "…"


func total_mundos() -> int:
	return (TOTAL_CAPITULOS + CAPS_POR_MUNDO - 1) / CAPS_POR_MUNDO


func rolagem_max() -> float:
	return maxf(0.0, TOPO_MUNDOS + total_mundos() * CARD_ALTO + 100 - ALT)



const MUNDO_NOMES := [
	"A Cratera do Cisma", "A Floresta das Raízes", "O Abismo dos Sinos", "Valdora em Cinzas", "O Olho do Primeiro",
	"A Sala da Fonte", "Além das Montanhas", "O Exército das Sombras", "O Trono do Vazio", "A Guerra dos Mundos",
	"O Primeiro Mundo", "A Porta entre Mundos", "A Cidade dos Espinhos", "A Biblioteca do Fim", "O Livro de Thornox",
	"A Estrada entre as Estrelas", "O Começo Depois do Fim", "A Estrela Azul", "O Mundo Verde",
]
const MISSOES := [
	{"id": "mortes", "nome": "Espante 150 monstros", "meta": 150, "premio": 6},
	{"id": "caps", "nome": "Vença 2 capítulos", "meta": 2, "premio": 8},
	{"id": "bonus", "nome": "Defenda a torre na fase bônus", "meta": 1, "premio": 6},
]
var tex_mundo := {}
var cap_sel := 0          # capítulo escolhido na tela inicial (0 = o próximo)
var popup := {}           # {"titulo", "texto", "valor", "acao"}
var apagar_confirma := 0.0


func arte_mundo(w: int) -> Texture2D:
	if not tex_mundo.has(w):
		tex_mundo[w] = load("res://assets/mundos/mundo-%02d.png" % w)
	return tex_mundo[w]


# ------------------------------------------------------------ recompensas da tela inicial
func hoje() -> String:
	return Time.get_date_string_from_system()


func agora() -> float:
	return Time.get_unix_time_from_system()


func missoes_do_dia() -> Dictionary:
	var m = prog.get("missoes", null)
	if not (m is Dictionary) or m.get("dia", "") != hoje():
		m = {"dia": hoje(), "mortes": 0, "caps": 0, "bonus": 0, "pegas": []}
		prog["missoes"] = m
	return m


func contar_missao(id: String, n := 1) -> void:
	if robo:
		return
	var m := missoes_do_dia()
	m[id] = int(m.get(id, 0)) + n


func missoes_prontas() -> int:
	var m := missoes_do_dia()
	var n := 0
	for ms in MISSOES:
		if int(m.get(ms["id"], 0)) >= int(ms["meta"]) and not m["pegas"].has(ms["id"]):
			n += 1
	return n


func presente_disponivel() -> bool:
	return prog.get("presente", "") != hoje()


func valor_presente() -> int:
	return 5 + mundo_de(int(prog["liberado"]))


func valor_fora() -> int:
	# enquanto você está fora, o Kravenox junta fragmentos (até 12 horas)
	var ultimo := float(prog.get("coleta_fora", 0.0))
	if ultimo <= 0:
		prog["coleta_fora"] = agora()
		return 0
	var horas := clampf((agora() - ultimo) / 3600.0, 0.0, 12.0)
	return int(horas * (1.0 + mundo_de(int(prog["liberado"])) / 5.0))


func baus_prontos() -> Array:
	var v := []
	var pegos: Dictionary = prog.get("baus", {})
	for w in range(1, total_mundos() + 1):
		var c1 := mini(w * CAPS_POR_MUNDO, TOTAL_CAPITULOS)
		var completo := true
		for c in range((w - 1) * CAPS_POR_MUNDO + 1, c1 + 1):
			if not feito(c):
				completo = false
		if completo and not pegos.has(str(w)):
			v.append(w)
	return v


func ganhar(n: int, titulo: String) -> void:
	prog["fragmentos"] = int(prog["fragmentos"]) + n
	salvar()
	som("nivel")
	popup = {"titulo": titulo, "texto": "+%d fragmentos" % n, "valor": n, "t": 0.0}


func poder() -> int:
	var p := 100
	for m in MELHORIAS:
		p += nivel_melhoria(m["id"]) * 35
	p += prog["feitos"].size() * 12 + prog.get("feitos_p", {}).size() * 20
	return p


# ------------------------------------------------------------ modo pesadelo
func pesadelo_liberado() -> bool:
	return feito(CAPS_POR_MUNDO)   # depois de vencer o mundo 1


func liberado_modo() -> int:
	if modo == "pesadelo":
		var c := int(prog.get("liberado_p", 1))
		while c > 1 and not feito(c):
			c -= 1
		return c
	return int(prog["liberado"])


func capitulo_disponivel(c: int) -> bool:
	if modo == "pesadelo":
		return feito(c) and c <= int(prog.get("liberado_p", 1))
	return c <= int(prog["liberado"])


# ------------------------------------------------------------ botões dos menus
func botoes_menu() -> Dictionary:
	var b := {}
	b["voltar"] = Rect2(12, 16, 40, 36)
	b["ajustes"] = Rect2(14, 92, 40, 40)
	b["avatar"] = Rect2(10, 10, 80, 70)
	b["kx_formas"] = Rect2(12, 128, 74, 74)
	b["kx_conquistas"] = Rect2(12, 210, 74, 74)
	b["kx_bestiario"] = Rect2(12, 292, 74, 74)
	for i in 4:
		b["kx_carta%d" % i] = Rect2(14 + i * 114, 532, 110, 196)
	for i in CONQUISTAS.size():
		b["conquista%d" % i] = Rect2(370, TOPO_MUNDOS + 6 + i * 51 + 8, 94, 32)
	b["normal"] = Rect2(110, 150, 128, 40)
	b["pesadelo"] = Rect2(242, 150, 128, 40)
	b["ant"] = Rect2(30, 440, 48, 64)
	b["prox"] = Rect2(402, 440, 48, 64)
	b["jogar"] = Rect2(110, 612, 260, 62)
	b["presente"] = Rect2(LARG - 84, 214, 72, 74)
	b["missoes"] = Rect2(LARG - 84, 296, 72, 74)
	b["baus"] = Rect2(LARG - 84, 378, 72, 74)
	b["fora"] = Rect2(12, 520, 84, 74)
	var nomes := ["melhorias", "bestiario", "inicio", "mundos", "ajustes_aba"]
	for i in 5:
		b["aba_" + nomes[i]] = Rect2(i * 96, ALT - 82, 96, 82)
	for i in MELHORIAS.size():
		b["melhoria%d" % i] = Rect2(338, 146 + i * 84 + 16, 112, 44)
	for i in MISSOES.size():
		b["missao%d" % i] = Rect2(338, 160 + i * 110 + 30, 112, 44)
	b["musica"] = Rect2(330, 150, 120, 44)
	b["efeitos"] = Rect2(330, 210, 120, 44)
	b["apagar"] = Rect2(40, 330, 400, 50)
	b["popup_ok"] = Rect2(LARG / 2 - 90, ALT / 2 + 30, 180, 50)
	return b


func cap_atual() -> int:
	var lib := liberado_modo()
	if cap_sel <= 0 or not capitulo_disponivel(cap_sel):
		return lib
	return cap_sel


func abas(p: Vector2, b: Dictionary) -> bool:
	if p.y < ALT - 82:
		return false
	if b["aba_melhorias"].has_point(p):
		ir_para("melhorias")
	elif b["aba_bestiario"].has_point(p):
		ir_para("bestiario")
	elif b["aba_inicio"].has_point(p):
		ir_para("inicio")
	elif b["aba_mundos"].has_point(p):
		destaque_cap = 0
		ir_para("mundos")
	elif b["aba_ajustes_aba"].has_point(p):
		ir_para("ajustes")
	return true


func clique_menu(p: Vector2) -> void:
	var b := botoes_menu()
	if not popup.is_empty():
		popup = {}
		return
	match tela:
		"abertura":
			if t_tela >= DURA_ABERTURA:
				som("gema")
				ir_para("inicio")
			return
		"mundos", "melhorias", "bestiario", "missoes", "ajustes", "kravenox":
			if b["voltar"].has_point(p):
				ir_para("inicio")
				return
		"formas", "conquistas":
			if b["voltar"].has_point(p):
				ir_para("kravenox")
				return
	if tela != "abertura" and abas(p, b):
		return
	match tela:
		"inicio":
			var c := cap_atual()
			if b["avatar"].has_point(p):
				ir_para("kravenox")
				return
			if b["jogar"].has_point(p):
				som("gema")
				comecar_capitulo(c)
			elif b["ajustes"].has_point(p):
				ir_para("ajustes")
			elif b["normal"].has_point(p):
				modo = "normal"
				cap_sel = 0
				prog["modo"] = modo
				salvar()
			elif b["pesadelo"].has_point(p):
				if pesadelo_liberado():
					modo = "pesadelo"
					cap_sel = 0
					prog["modo"] = modo
					salvar()
				else:
					popup = {"titulo": "PESADELO", "texto": "Vença o Mundo 1 para liberar"}
			elif b["ant"].has_point(p):
				var n := c - 1
				while n >= 1 and not capitulo_disponivel(n):
					n -= 1
				if n >= 1:
					cap_sel = n
			elif b["prox"].has_point(p):
				if c + 1 <= TOTAL_CAPITULOS and capitulo_disponivel(c + 1):
					cap_sel = c + 1
			elif b["presente"].has_point(p):
				if presente_disponivel():
					prog["presente"] = hoje()
					ganhar(valor_presente(), "PRESENTE DO DIA")
				else:
					popup = {"titulo": "PRESENTE DO DIA", "texto": "Volte amanhã para outro presente"}
			elif b["missoes"].has_point(p):
				ir_para("missoes")
			elif b["baus"].has_point(p):
				var bs := baus_prontos()
				if bs.is_empty():
					popup = {"titulo": "BAÚS DOS MUNDOS", "texto": "Vença os 4 capítulos de um mundo para abrir o baú dele"}
				else:
					var w: int = bs[0]
					if not prog.has("baus"):
						prog["baus"] = {}
					prog["baus"][str(w)] = true
					ganhar(10 + 2 * w, "BAÚ DO MUNDO %d" % w)
			elif b["fora"].has_point(p):
				var v := valor_fora()
				if v > 0:
					prog["coleta_fora"] = agora()
					ganhar(v, "ENQUANTO VOCÊ ESTAVA FORA")
				else:
					popup = {"titulo": "ENQUANTO VOCÊ ESTAVA FORA", "texto": "O Kravenox junta fragmentos enquanto você está fora (até 12 horas)"}
		"mundos":
			if p.y < TOPO_MUNDOS:
				return
			for c in range(1, TOTAL_CAPITULOS + 1):
				if no_capitulo_card(c).distance_to(p) < 32:
					if capitulo_disponivel(c):
						som("gema")
						comecar_capitulo(c)
					else:
						som("dano")
					return
		"melhorias":
			for i in MELHORIAS.size():
				if b["melhoria%d" % i].has_point(p):
					if not comprar_melhoria(i):
						som("dano")
					return
		"kravenox":
			if b["kx_formas"].has_point(p):
				ir_para("formas")
			elif b["kx_conquistas"].has_point(p):
				ir_para("conquistas")
			elif b["kx_bestiario"].has_point(p):
				ir_para("bestiario")
			else:
				for i in 4:
					if b["kx_carta%d" % i].has_point(p):
						var idx := indice_melhoria(CARTAS_KX[i])
						if not comprar_melhoria(idx):
							som("dano")
						return
		"conquistas":
			for i in CONQUISTAS.size():
				if b["conquista%d" % i].has_point(p):
					var c: Dictionary = CONQUISTAS[i]
					var pegas: Dictionary = prog.get("conquistas", {})
					if progresso_conquista(c) >= int(c["meta"]) and not pegas.has(c["id"]):
						pegas[c["id"]] = true
						prog["conquistas"] = pegas
						ganhar(int(c["premio"]), "CONQUISTA!")
					return
		"missoes":
			var m := missoes_do_dia()
			for i in MISSOES.size():
				var ms: Dictionary = MISSOES[i]
				if b["missao%d" % i].has_point(p) and int(m.get(ms["id"], 0)) >= int(ms["meta"]) and not m["pegas"].has(ms["id"]):
					m["pegas"].append(ms["id"])
					ganhar(int(ms["premio"]) + mundo_de(int(prog["liberado"])) / 2, "MISSÃO CUMPRIDA")
					return
		"ajustes":
			if b["musica"].has_point(p):
				ligar_som(not som_ligado)
			elif b["efeitos"].has_point(p):
				efeitos_ligados = not efeitos_ligados
			elif b["apagar"].has_point(p):
				if apagar_confirma > 0:
					DirAccess.remove_absolute(ProjectSettings.globalize_path(ARQUIVO))
					carregar_progresso()
					apagar_confirma = 0.0
					cap_sel = 0
					modo = "normal"
					popup = {"titulo": "PROGRESSO APAGADO", "texto": "O jogo começa do capítulo 1"}
				else:
					apagar_confirma = 3.0


# ------------------------------------------------------------ desenho da tela inicial
func botao_icone(r: Rect2, tipo: String, rotulo: String, alerta := false) -> void:
	caixa(r, Color(0.05, 0.04, 0.07, 0.82), 12, 2, Color(OURO, 0.75), true, 6)
	var c := r.get_center() + Vector2(0, -9)
	match tipo:
		"presente":
			brilho_suave(c, 30, OURO, 0.8)
			caixa(Rect2(c + Vector2(-16, -6), Vector2(32, 22)), Color8(150, 30, 40), 3, 1, TINTA)
			caixa(Rect2(c + Vector2(-19, -12), Vector2(38, 8)), Color8(190, 40, 50), 2, 1, TINTA)
			draw_rect(Rect2(c + Vector2(-3, -12), Vector2(6, 28)), OURO)
		"missoes":
			brilho_suave(c, 30, AZUL, 0.7)
			caixa(Rect2(c + Vector2(-14, -16), Vector2(28, 32)), PAPEL_C, 3, 1, TINTA)
			for k in 3:
				draw_line(c + Vector2(-8, -8 + k * 8), c + Vector2(9, -8 + k * 8), Color8(90, 70, 50), 2)
		"baus":
			brilho_suave(c, 30, OURO, 0.8)
			caixa(Rect2(c + Vector2(-17, -6), Vector2(34, 20)), Color8(110, 70, 36), 3, 1, TINTA)
			caixa(Rect2(c + Vector2(-17, -15), Vector2(34, 11)), Color8(140, 90, 46), 5, 1, TINTA)
			draw_rect(Rect2(c + Vector2(-3, -7), Vector2(6, 8)), OURO)
		"fora":
			brilho_suave(c, 30, ROXO, 0.8)
			draw_circle(c, 15, Color8(30, 24, 44))
			draw_arc(c, 15, 0, TAU, 24, OURO, 2, true)
			draw_line(c, c + Vector2(0, -10), OURO, 2)
			draw_line(c, c + Vector2(7, 3), OURO, 2)
		"formas":
			brilho_suave(c, 30, cor_forma(), 0.9)
			for k in 5:
				var a := -PI / 2 + (k - 2) * 0.45
				draw_colored_polygon(PackedVector2Array([c + Vector2.from_angle(a) * 18, c + Vector2.from_angle(a - 0.2) * 7, c + Vector2.from_angle(a + 0.2) * 7]), OURO)
			draw_circle(c + Vector2(0, 4), 9, Color8(20, 16, 26))
			draw_circle(c + Vector2(-3, 3), 2, VERMELHO)
			draw_circle(c + Vector2(3, 3), 2, VERMELHO)
		"conquistas":
			brilho_suave(c, 30, OURO, 0.8)
			poli([c + Vector2(-12, -14), c + Vector2(12, -14), c + Vector2(9, 2), c + Vector2(0, 7), c + Vector2(-9, 2)], OURO, 1.2)
			draw_rect(Rect2(c + Vector2(-2, 6), Vector2(4, 6)), OURO)
			draw_rect(Rect2(c + Vector2(-8, 12), Vector2(16, 4)), OURO)
		"bestiario":
			brilho_suave(c, 30, ROXO, 0.7)
			poli([c + Vector2(-14, -11), c + Vector2(-1, -8), c + Vector2(-1, 13), c + Vector2(-14, 10)], Color8(90, 58, 140), 1.2)
			poli([c + Vector2(14, -11), c + Vector2(1, -8), c + Vector2(1, 13), c + Vector2(14, 10)], Color8(110, 70, 160), 1.2)
		"engrenagem":
			for k in 8:
				var a := k * TAU / 8
				draw_line(c + Vector2.from_angle(a) * 8, c + Vector2.from_angle(a) * 15, OURO, 5)
			draw_circle(c, 10, OURO)
			draw_circle(c, 4, Color8(20, 16, 26))
	if rotulo != "":
		escrever(rotulo, Vector2(r.get_center().x, r.end.y - 11), 12, BRANCO, true)
	if alerta:
		var d := r.position + Vector2(r.size.x - 8, 8)
		draw_circle(d, 8 + sin(tempo * 5), VERMELHO)
		escrever("!", d, 13, BRANCO, false)


func desenhar_abas() -> void:
	draw_rect(Rect2(0, ALT - 82, LARG, 82), Color(0.03, 0.02, 0.05, 0.96))
	draw_line(Vector2(0, ALT - 82), Vector2(LARG, ALT - 82), Color(OURO, 0.5), 2)
	var b := botoes_menu()
	var itens := [["aba_melhorias", "Melhorias", "melhorias"], ["aba_bestiario", "Bestiário", "bestiario"],
		["aba_inicio", "Batalha", "inicio"], ["aba_mundos", "Mundos", "mundos"], ["aba_ajustes_aba", "Ajustes", "ajustes"]]
	for it in itens:
		var r: Rect2 = b[it[0]]
		var ativo: bool = tela == it[2]
		if ativo:
			degrade(r.grow(-4), Color(VERMELHO, 0.35), Color(VERMELHO, 0.05))
			draw_line(Vector2(r.position.x + 10, r.position.y + 3), Vector2(r.end.x - 10, r.position.y + 3), OURO, 3)
		var c := r.get_center() + Vector2(0, -10)
		var cor := OURO if ativo else CINZA
		match it[2]:
			"melhorias":
				poli([c + Vector2(0, -14), c + Vector2(12, 0), c + Vector2(5, 0), c + Vector2(5, 13), c + Vector2(-5, 13), c + Vector2(-5, 0), c + Vector2(-12, 0)], Color(VERMELHO, 0.9 if ativo else 0.6), 1.2)
			"bestiario":
				poli([c + Vector2(-14, -11), c + Vector2(-1, -8), c + Vector2(-1, 13), c + Vector2(-14, 10)], Color8(90, 58, 140) if ativo else Color8(60, 50, 80), 1.2)
				poli([c + Vector2(14, -11), c + Vector2(1, -8), c + Vector2(1, 13), c + Vector2(14, 10)], Color8(110, 70, 160) if ativo else Color8(70, 58, 90), 1.2)
			"inicio":
				for k in [-1.0, 1.0]:
					draw_line(c + Vector2(-13 * k, 12), c + Vector2(12 * k, -13), cor, 4, true)
					draw_line(c + Vector2(-9 * k, 3), c + Vector2(-3 * k, 9), cor, 3, true)
			"mundos":
				draw_circle(c, 13, Color(ROXO, 0.5 if ativo else 0.3))
				draw_arc(c, 13, 0, TAU, 24, cor, 2, true)
				draw_line(c + Vector2(-13, 0), c + Vector2(13, 0), cor, 1.5)
				draw_arc(c, 6, -PI / 2, PI / 2, 10, cor, 1.5)
			"ajustes":
				for k in 8:
					var a := k * TAU / 8
					draw_line(c + Vector2.from_angle(a) * 6, c + Vector2.from_angle(a) * 12, cor, 4)
				draw_circle(c, 7, cor)
				draw_circle(c, 3, Color8(20, 16, 26))
		escrever(it[1], Vector2(r.get_center().x, r.end.y - 16), 13, BRANCO if ativo else CINZA, false)
		if it[2] == "melhorias" and pode_melhorar():
			draw_circle(r.position + Vector2(r.size.x - 22, 12), 6, VERMELHO)


func desenhar_popup() -> void:
	if popup.is_empty():
		return
	popup["t"] = float(popup.get("t", 0.0)) + 0.016
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0, 0, 0, 0.6))
	var r := Rect2(40, ALT / 2 - 110, LARG - 80, 220)
	caixa(r, Color8(20, 16, 28), 12, 2, OURO, true, 10)
	escrever(popup["titulo"], Vector2(LARG / 2, r.position.y + 34), 18, OURO, true, fonte_titulo)
	if popup.has("valor"):
		var a := clampf(float(popup["t"]) * 3, 0, 1)
		brilho_suave(Vector2(LARG / 2, r.position.y + 96), 70 * a, VERMELHO, 1.2)
		cristal(Vector2(LARG / 2 - 50, r.position.y + 96), 16 * a, VERMELHO)
		escrever("+%d" % int(popup["valor"]), Vector2(LARG / 2 + 14, r.position.y + 96), 34, BRANCO)
		escrever("fragmentos", Vector2(LARG / 2, r.position.y + 132), 15, CINZA, false)
	else:
		desenhar_dica(popup["texto"], Vector2(LARG / 2, r.position.y + 100), r.size.x - 40)
	escrever("Toque para continuar", Vector2(LARG / 2, r.end.y - 26), 14, Color(CINZA, 0.6 + 0.4 * sin(tempo * 4)), false)


func desenhar_inicio() -> void:
	var c := cap_atual()
	var w := mundo_de(c)
	# fundo: a ilustração do mundo do capítulo, cobrindo a tela
	var t := arte_mundo(w)
	var alt := ALT * 0.78
	var larg := alt * t.get_width() / t.get_height()
	draw_texture_rect(t, Rect2(LARG / 2 - larg / 2 + sin(tempo * 0.15) * 20, 0, larg, alt), false)
	degrade(Rect2(0, 0, LARG, 200), Color(0.02, 0.01, 0.04, 0.85), Color(0.02, 0.01, 0.04, 0.0))
	degrade(Rect2(0, alt * 0.55, LARG, alt * 0.45 + 2), Color(0.02, 0.01, 0.04, 0.0), Color(0.03, 0.02, 0.05, 1.0))
	draw_rect(Rect2(0, alt, LARG, ALT - alt), Color(0.03, 0.02, 0.05, 1.0))
	if modo == "pesadelo":
		draw_rect(Rect2(0, 0, LARG, ALT), Color(0.35, 0.0, 0.02, 0.22))
	# barra do alto: o Kravenox, o poder e os fragmentos
	var av := Rect2(12, 12, 66, 66)
	brilho_suave(av.get_center(), 50, cor_forma(), 0.6)
	caixa(av, Color8(28, 20, 30), 10, 2, OURO, true, 6)
	var tk: Texture2D = tex["kravenox"]
	draw_texture_rect_region(tk, av.grow(-5), Rect2(0, 0, tk.get_width(), tk.get_width() * 0.92))
	caixa(Rect2(60, 6, 34, 22), VERMELHO, 11, 1, TINTA)
	escrever(str(prog["feitos"].size()), Vector2(77, 17), 13, BRANCO, false)
	caixa(Rect2(84, 24, 130, 30), Color(0.05, 0.04, 0.07, 0.85), 8, 1, Color(VERMELHO, 0.6))
	escrever_esq("PODER", Vector2(92, 44), 11, Color8(255, 170, 120), fonte_titulo)
	escrever_esq(str(poder()), Vector2(148, 46), 18, OURO)
	pilula_fragmentos(LARG - 14, 16)
	var b := botoes_menu()
	botao_icone(b["ajustes"], "engrenagem", "")
	# Normal / Pesadelo
	var mp := pesadelo_liberado()
	botao(b["normal"], "Normal", AZUL, true, modo == "normal")
	botao(b["pesadelo"], "Pesadelo", VERMELHO, mp, modo == "pesadelo")
	if not mp:
		draw_rect(Rect2(b["pesadelo"].end.x - 26, b["pesadelo"].position.y + 14, 12, 10), CINZA)
		draw_arc(Vector2(b["pesadelo"].end.x - 20, b["pesadelo"].position.y + 14), 4, PI, TAU, 8, CINZA, 2)
	# capítulo escolhido, com setas
	escrever("CAPÍTULO %d" % c, Vector2(LARG / 2, 226), 34, BRANCO, true, fonte_titulo)
	escrever(CAPITULOS[c - 1], Vector2(LARG / 2, 262), 18, OURO)
	escrever("Mundo %d · %s" % [w, MUNDO_NOMES[w - 1]], Vector2(LARG / 2, 286), 14, CINZA)
	if feito(c) and modo == "normal" or modo == "pesadelo" and prog.get("feitos_p", {}).has(str(c)):
		escrever("✓ vencido", Vector2(LARG / 2, 306), 13, Color8(120, 230, 140), false)
	var pode_ant := c > 1
	var pode_prox := c + 1 <= TOTAL_CAPITULOS and capitulo_disponivel(c + 1)
	for lado in [["ant", -1.0, pode_ant], ["prox", 1.0, pode_prox]]:
		var r: Rect2 = b[lado[0]]
		var cc := r.get_center()
		var cor := Color(OURO, 0.95 if lado[2] else 0.25)
		var s: float = lado[1]
		draw_polyline(PackedVector2Array([cc + Vector2(-8 * s, -20), cc + Vector2(10 * s, 0), cc + Vector2(-8 * s, 20)]), Color(TINTA, cor.a), 10, true)
		draw_polyline(PackedVector2Array([cc + Vector2(-8 * s, -20), cc + Vector2(10 * s, 0), cc + Vector2(-8 * s, 20)]), cor, 5, true)
	# o Kravenox no centro, sobre o chão do mundo
	var base := Vector2(LARG / 2, 560)
	brilho_suave(base + Vector2(0, -90), 120, VERMELHO, 0.45 + 0.1 * sin(tempo * 1.5))
	sombra_chao(base, 60)
	desenhar_arte("kravenox", base + Vector2(0, -sin(tempo * 1.4) * 3), 200, false)
	# botões laterais
	botao_icone(b["presente"], "presente", "Presente", presente_disponivel())
	botao_icone(b["missoes"], "missoes", "Missões", missoes_prontas() > 0)
	botao_icone(b["baus"], "baus", "Baús", not baus_prontos().is_empty())
	var vf := valor_fora()
	botao_icone(b["fora"], "fora", "+%d fora" % vf if vf > 0 else "Fora", vf >= 1)
	# começar / continuar
	var pt := partida_guardada()
	var continua := not pt.is_empty() and int(pt["capitulo"]) == c and str(pt.get("modo", "normal")) == modo
	botao(b["jogar"], "", VERMELHO, true, true)
	escrever("CONTINUAR" if continua else "COMEÇAR", b["jogar"].get_center() + Vector2(0, -6 if continua else 0), 24, BRANCO, false, fonte_titulo)
	if continua:
		var fase_txt := "bônus" if pt.get("bonus_pendente", false) else "fase %d" % (int(pt["onda"]) + 1)
		escrever(fase_txt, b["jogar"].get_center() + Vector2(0, 17), 13, Color8(255, 210, 200), false)
	if modo == "pesadelo":
		escrever("Monstros mais fortes · fragmentos em dobro", Vector2(LARG / 2, 692), 13, Color8(255, 140, 130), false)
	desenhar_abas()
	desenhar_popup()


const CARD_ALTO := 262.0


func no_capitulo_card(c: int) -> Vector2:
	var w := mundo_de(c) - 1
	var j := (c - 1) % CAPS_POR_MUNDO
	return Vector2(84 + j * 104, TOPO_MUNDOS + w * CARD_ALTO - rolagem + 200)


func desenhar_mundos() -> void:
	desenhar_fundo(0.7)
	var lib := liberado_modo()
	for w in total_mundos():
		var y := TOPO_MUNDOS + w * CARD_ALTO - rolagem
		if y > ALT or y + CARD_ALTO < TOPO_MUNDOS - 10:
			continue
		var c0 := w * CAPS_POR_MUNDO + 1
		var c1 := mini(c0 + CAPS_POR_MUNDO - 1, TOTAL_CAPITULOS)
		var aberto := capitulo_disponivel(c0)
		var atual := lib >= c0 and lib <= c1
		var r := Rect2(14, y, LARG - 28, CARD_ALTO - 14)
		caixa(r, Color(0.06, 0.05, 0.08, 0.95), 12, 2 if atual else 1, OURO if atual else Color(PEDRA_BORDA, 0.9), true, 6)
		# a ilustração do mundo
		var ri := Rect2(r.position + Vector2(6, 6), Vector2(r.size.x - 12, 150))
		var tm := arte_mundo(w + 1)
		var fonte_r := Rect2(0, (tm.get_height() - tm.get_width() * ri.size.y / ri.size.x) / 2.0, tm.get_width(), tm.get_width() * ri.size.y / ri.size.x)
		draw_texture_rect_region(tm, ri, fonte_r, Color.WHITE if aberto else Color(0.35, 0.32, 0.4))
		degrade(Rect2(ri.position, Vector2(ri.size.x, 56)), Color(0, 0, 0, 0.75), Color(0, 0, 0, 0))
		degrade(Rect2(ri.position + Vector2(0, ri.size.y - 40), Vector2(ri.size.x, 40)), Color(0, 0, 0, 0), Color(0.06, 0.05, 0.08, 0.9))
		escrever_esq("MUNDO %d" % (w + 1), ri.position + Vector2(12, 24), 14, OURO if aberto else CINZA, fonte_titulo)
		escrever_esq(MUNDO_NOMES[w], ri.position + Vector2(12, 46), 18, BRANCO if aberto else CINZA)
		var livro := "Livro I" if c1 <= 35 else ("Livro II" if c0 > 35 else "Livro I e II")
		var wi := fonte.get_string_size(livro, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		escrever_esq(livro, Vector2(ri.end.x - 12 - wi, ri.position.y + 22), 13, CINZA)
		if not aberto:
			var cc := ri.get_center()
			draw_rect(Rect2(cc + Vector2(-13, -4), Vector2(26, 20)), CINZA)
			draw_arc(cc + Vector2(0, -5), 9, PI, TAU, 12, CINZA, 3)
		if prog.get("baus", {}).has(str(w + 1)):
			escrever("baú aberto", Vector2(ri.end.x - 44, ri.end.y - 14), 12, OURO, true)
		# os 4 capítulos embaixo
		draw_line(no_capitulo_card(c0), no_capitulo_card(c1), Color(0, 0, 0, 0.7), 6)
		for c in range(c0, c1 + 1):
			var p := no_capitulo_card(c)
			var venceu: bool = prog.get("feitos_p", {}).has(str(c)) if modo == "pesadelo" else feito(c)
			if c < c1 and venceu:
				draw_line(p, no_capitulo_card(c + 1), SANGUE, 3)
			if venceu:
				if c == destaque_cap and t_tela < 3.0:
					brilho_suave(p, 60, OURO, 1.6 * (1.0 - t_tela / 3.0) + 0.3 * sin(tempo * 6))
				draw_circle(p, 24, TINTA)
				draw_circle(p, 21, Color8(120, 94, 52))
				draw_arc(p, 21, 0, TAU, 32, OURO, 2, true)
				escrever(str(c), p + Vector2(0, -3), 16, BRANCO, false)
				draw_polyline(PackedVector2Array([p + Vector2(-6, 9), p + Vector2(-2, 13), p + Vector2(6, 5)]), Color8(120, 230, 140), 2.5, true)
				if prog.get("bonus", {}).has(str(c)):
					var e := []
					var pe := p + Vector2(17, -17)
					for k in 10:
						e.append(pe + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (8.0 if k % 2 == 0 else 3.5))
					poli(e, OURO, 1.2)
			elif capitulo_disponivel(c):
				brilho_suave(p, 44, VERMELHO, 1.0 + 0.4 * sin(tempo * 4))
				draw_circle(p, 24, TINTA)
				draw_circle(p, 21, Color8(150, 26, 30))
				draw_arc(p, 21, 0, TAU, 32, Color8(255, 120, 100), 2, true)
				escrever(str(c), p, 17, BRANCO, false)
			else:
				draw_circle(p, 24, TINTA)
				draw_circle(p, 21, PEDRA_ESC)
				draw_arc(p, 21, 0, TAU, 32, PEDRA_BORDA, 1.5, true)
				draw_rect(Rect2(p + Vector2(-7, -2), Vector2(14, 11)), CINZA)
				draw_arc(p + Vector2(0, -3), 5, PI, TAU, 10, CINZA, 2)
		if atual:
			escrever(encurtar("Próximo: %d · %s" % [lib, CAPITULOS[lib - 1]], fonte, 14, r.size.x - 30), Vector2(LARG / 2, r.end.y - 14), 14, BRANCO, false)
	cabecalho("MUNDOS · PESADELO" if modo == "pesadelo" else "MUNDOS")
	desenhar_abas()


func desenhar_missoes() -> void:
	desenhar_fundo(0.65)
	cabecalho("MISSÕES DO DIA")
	escrever("Renovam todo dia. Cumpra e pegue os fragmentos.", Vector2(LARG / 2, 136), 14, CINZA)
	var m := missoes_do_dia()
	var b := botoes_menu()
	for i in MISSOES.size():
		var ms: Dictionary = MISSOES[i]
		var r := Rect2(16, 160 + i * 110, LARG - 32, 96)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(PEDRA_BORDA, 0.9), true, 6)
		var feito_n := mini(int(m.get(ms["id"], 0)), int(ms["meta"]))
		escrever_esq(ms["nome"], r.position + Vector2(16, 30), 16, OURO, fonte_titulo)
		var barra := Rect2(r.position + Vector2(16, 48), Vector2(290, 12))
		caixa(barra, Color8(20, 16, 26), 6, 1, PEDRA_BORDA)
		if feito_n > 0:
			degrade(Rect2(barra.position + Vector2(2, 2), Vector2((barra.size.x - 4) * feito_n / float(ms["meta"]), 8)), Color8(236, 80, 60), Color8(140, 20, 26))
		escrever_esq("%d / %d" % [feito_n, int(ms["meta"])], r.position + Vector2(16, 82), 14, CINZA)
		var pego: bool = m["pegas"].has(ms["id"])
		var pronto := feito_n >= int(ms["meta"])
		var bb: Rect2 = b["missao%d" % i]
		if pego:
			botao(bb, "Pego ✓", CINZA, false)
		else:
			botao(bb, "", OURO if pronto else CINZA, pronto, pronto)
			cristal(bb.position + Vector2(34, 22), 8, VERMELHO)
			escrever_esq(str(int(ms["premio"]) + mundo_de(int(prog["liberado"])) / 2), bb.position + Vector2(48, 30), 20, BRANCO if pronto else CINZA)
	desenhar_abas()
	desenhar_popup()


func desenhar_ajustes() -> void:
	desenhar_fundo(0.7)
	cabecalho("AJUSTES")
	var b := botoes_menu()
	apagar_confirma = maxf(0.0, apagar_confirma - 0.016)
	for it in [["Música", b["musica"], som_ligado], ["Efeitos sonoros", b["efeitos"], efeitos_ligados]]:
		var r: Rect2 = it[1]
		escrever_esq(it[0], Vector2(40, r.get_center().y + 7), 20, BRANCO)
		botao(r, "Ligado" if it[2] else "Desligado", VERDE if it[2] else CINZA, true, it[2])
	draw_line(Vector2(30, 290), Vector2(LARG - 30, 290), Color(PEDRA_BORDA, 0.7), 1)
	botao(b["apagar"], "Toque de novo para apagar tudo" if apagar_confirma > 0 else "Apagar progresso", VERMELHO, true, apagar_confirma > 0)
	escrever("Apaga capítulos, melhorias e fragmentos deste aparelho.", Vector2(LARG / 2, 400), 13, CINZA)
	escrever("O jogo funciona sem internet depois de aberto uma vez.", Vector2(LARG / 2, 470), 14, Color8(150, 220, 170))
	escrever("Kravenox: Quadros do Cisma", Vector2(LARG / 2, 640), 15, OURO, true, fonte_titulo)
	escrever("versão " + VERSAO, Vector2(LARG / 2, 664), 13, CINZA, false)
	desenhar_abas()
	desenhar_popup()


func logo(centro: Vector2, tam := 56) -> void:
	brilho_suave(centro + Vector2(0, -6), 170, VERMELHO, 0.55 + 0.1 * sin(tempo * 2))
	escrever("KRAVENOX", centro, tam, Color8(236, 60, 54), true, fonte_titulo)
	escrever("QUADROS DO CISMA", centro + Vector2(0, tam * 0.72), int(tam * 0.36), OURO, true, fonte_titulo)


func pilula_fragmentos(direita: float, y: float) -> void:
	var t := str(int(prog["fragmentos"]))
	var w := fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x + 52
	var r := Rect2(direita - w, y, w, 36)
	caixa(r, Color(0.05, 0.04, 0.07, 0.88), 18, 1, Color(VERMELHO, 0.6))
	cristal(r.position + Vector2(20, 18), 9, VERMELHO)
	escrever_esq(t, r.position + Vector2(36, 26), 22, BRANCO)


func cabecalho(titulo: String) -> void:
	draw_rect(Rect2(0, 0, LARG, TOPO_MUNDOS - 8), Color(0.03, 0.02, 0.05, 0.96))
	draw_line(Vector2(0, TOPO_MUNDOS - 8), Vector2(LARG, TOPO_MUNDOS - 8), Color(OURO, 0.4), 1)
	var bv: Rect2 = botoes_menu()["voltar"]
	botao(bv, "", OURO)
	draw_polyline(PackedVector2Array([bv.get_center() + Vector2(4, -8), bv.get_center() + Vector2(-4, 0), bv.get_center() + Vector2(4, 8)]), OURO, 2.5, true)
	escrever_esq(titulo, Vector2(66, 44), 22, OURO, fonte_titulo)
	pilula_fragmentos(LARG - 14, 16)


func desenhar_abertura() -> void:
	desenhar_fundo(0.55)
	logo(Vector2(LARG / 2, 190), 58)
	var base := Vector2(LARG / 2, 560)
	brilho_suave(base + Vector2(0, -110), 150, VERMELHO, 0.5)
	sombra_chao(base, 70)
	desenhar_arte("kravenox", base, 250, false)
	var fr := clampf(t_tela / DURA_ABERTURA, 0, 1)
	var barra := Rect2(LARG / 2 - 150, 640, 300, 14)
	caixa(barra.grow(3), Color(0.04, 0.03, 0.06, 0.9), 9, 1, Color(OURO, 0.5))
	if fr > 0:
		degrade(Rect2(barra.position, Vector2(barra.size.x * fr, barra.size.y)), Color8(236, 80, 60), Color8(140, 20, 26))
	var i := mini(int(fr * 3), 2) if fr < 1 else 3
	var a := 1.0 if fr < 1 else 0.55 + 0.45 * sin(tempo * 4)
	escrever(MSG_ABERTURA[i], Vector2(LARG / 2, 684), 19, Color(BRANCO, a))


func desenhar_melhorias() -> void:
	desenhar_fundo(0.62)
	cabecalho("MELHORIAS")
	escrever("Cada capítulo dá fragmentos. Gaste aqui para ficar mais forte.", Vector2(LARG / 2, 132), 14, CINZA)
	var b := botoes_menu()
	for i in MELHORIAS.size():
		var m: Dictionary = MELHORIAS[i]
		var r := Rect2(16, 146 + i * 84, LARG - 32, 78)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(PEDRA_BORDA, 0.9), true, 6)
		var lv := nivel_melhoria(m["id"])
		var mx := int(m["max"])
		escrever_esq(m["nome"], r.position + Vector2(16, 26), 15, OURO, fonte_titulo)
		escrever_esq(m["desc"], r.position + Vector2(16, 47), 14, CINZA)
		for k in mx:
			var p := r.position + Vector2(22 + k * (15 if mx <= 10 else 14), 63)
			var d := PackedVector2Array([p + Vector2(0, -5), p + Vector2(4.5, 0), p + Vector2(0, 5), p + Vector2(-4.5, 0)])
			draw_colored_polygon(d, VERMELHO if k < lv else PEDRA_CLARA)
		var bb: Rect2 = b["melhoria%d" % i]
		if lv >= mx:
			botao(bb, "MÁXIMO", CINZA, false)
		else:
			var custo := custo_melhoria(m)
			var pode := int(prog["fragmentos"]) >= custo
			botao(bb, "", OURO if pode else CINZA, pode, pode)
			cristal(bb.position + Vector2(36, 22), 8, VERMELHO)
			escrever_esq(str(custo), bb.position + Vector2(50, 30), 20, BRANCO if pode else CINZA)
	desenhar_abas()
	desenhar_popup()


func desenhar_bestiario() -> void:
	desenhar_fundo(0.62)
	for i in ORDEM_BESTIARIO.size():
		var tipo: String = ORDEM_BESTIARIO[i]
		var info: Dictionary = MONSTROS[tipo]
		var r := Rect2(16 + (i % 2) * 228, TOPO_MUNDOS + 2 + (i / 2) * 154, 220, 146)
		var visto: bool = prog["vistos"].has(tipo)
		var chefe: bool = info.get("chefe", false)
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 1, Color(ROXO if chefe else PEDRA_BORDA, 0.8), true, 6)
		var base := r.position + Vector2(r.size.x / 2, 100)
		brilho_suave(base + Vector2(0, -40), 60, AZUL if tipo == "thornox" else ROXO, 0.5 if visto else 0.15)
		sombra_chao(base, 36)
		var mod: Color = info.get("tinta", Color.WHITE) if visto else Color(0, 0, 0, 0.92)
		desenhar_arte(info["img"], base, 82, false, mod)
		escrever(info["nome"] if visto else "???", r.position + Vector2(r.size.x / 2, 118), 16, BRANCO if visto else CINZA, false)
		var nota := "Chefe" if chefe else "Desde o capítulo %d" % MONSTRO_DESDE[tipo]
		escrever(nota, r.position + Vector2(r.size.x / 2, 136), 13, Color8(200, 160, 255) if chefe else CINZA, false)
	cabecalho("BESTIÁRIO")
	desenhar_abas()


# Dica da loja: cabe em até duas linhas pequenas.
func desenhar_dica(t: String, c: Vector2, largura: float) -> void:
	if fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x <= largura:
		escrever(t, c, 14, CINZA, false)
		return
	var palavras := t.split(" ")
	var l1 := ""
	var i := 0
	while i < palavras.size() and fonte.get_string_size((l1 + " " + palavras[i]).strip_edges(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x <= largura:
		l1 = (l1 + " " + palavras[i]).strip_edges()
		i += 1
	var l2 := " ".join(palavras.slice(i))
	escrever(l1, c + Vector2(0, -6), 13, Color8(220, 210, 230), false)
	escrever(encurtar(l2, fonte, 13, largura), c + Vector2(0, 9), 13, Color8(220, 210, 230), false)


# ------------------------------------------------------------ arrastar com o dedo
# Segurar um item da loja (ou de um quadro) e soltar num quadro. Um toque
# rápido, sem arrastar, continua valendo como antes: toca no item e depois no
# quadro.
func comecar_arrasto(p: Vector2) -> bool:
	if estado != "loja" or vender:
		return false
	var b := botoes()
	for i in 3:
		if b["loja%d" % i].has_point(p) and loja[i] != null and essencia >= preco(loja[i]):
			arrasto = {"de": "loja", "i": i, "p": p, "moveu": false}
			toque_ini = p
			return true
	for i in ANEL.size():
		if ret_quadro(i).has_point(p) and quadros[i] != null:
			arrasto = {"de": "quadro", "i": i, "p": p, "moveu": false}
			toque_ini = p
			return true
	return false


func soltar_arrasto(p: Vector2) -> void:
	var a := arrasto
	arrasto = {}
	if not a["moveu"]:
		clique(toque_ini)   # foi só um toque
		return
	var alvo := quadro_em(p)
	if alvo < 0:
		selec = []
		return
	selec = [a["de"], a["i"]]
	clique_quadro(alvo)
	salvar_partida()


func quadro_em(p: Vector2) -> int:
	for i in ANEL.size():
		if ret_quadro(i).grow(6).has_point(p):
			return i
	return -1


func item_arrastado():
	if arrasto.is_empty():
		return null
	if arrasto["de"] == "loja":
		return {"id": loja[arrasto["i"]], "nv": 1}
	return quadros[arrasto["i"]]


func desenhar_arrasto() -> void:
	if arrasto.is_empty() or not arrasto["moveu"]:
		return
	var item = item_arrastado()
	if item == null:
		return
	var alvo := quadro_em(arrasto["p"])
	if alvo >= 0 and not (arrasto["de"] == "quadro" and alvo == arrasto["i"]):
		var q = quadros[alvo]
		var funde: bool = q != null and q["id"] == item["id"] and q["nv"] == item["nv"] and q["nv"] < NIVEL_MAX
		var ok: bool = q == null or funde or arrasto["de"] == "quadro"
		var cor := OURO if ok else VERMELHO
		caixa(ret_quadro(alvo).grow(4), Color(0, 0, 0, 0), 9, 3, cor, false)
		brilho_suave(ret_quadro(alvo).get_center(), 60, cor, 0.8)
		if funde:
			escrever("Fundir!", ret_quadro(alvo).get_center() + Vector2(0, 30), 15, OURO)
	var c: Vector2 = arrasto["p"] + Vector2(0, -36)   # um pouco acima do dedo, para dar para ver
	caixa(Rect2(c - Vector2(40, 40), Vector2(80, 80)), Color(0.08, 0.06, 0.1, 0.85), 10, 2, OURO, true, 8)
	icone(item["id"], c, 0.95)


# A torre da fase bônus, no meio do caminho: pedra escura com o cristal roxo.
func desenhar_torre() -> void:
	var base := CENTRO + Vector2(0, 30)
	var caiu := torre_hp <= 0
	sombra_chao(base, 40)
	var alt := 30.0 if caiu else 92.0
	var w := 46.0
	var corpo := [base + Vector2(-w / 2, 0), base + Vector2(w / 2, 0), base + Vector2(w / 2 - 6, -alt), base + Vector2(-w / 2 + 6, -alt)]
	poli(corpo, Color8(52, 46, 62) if torre_flash <= 0 else Color8(140, 60, 70), 2)
	for k in int(alt / 14):
		var y := base.y - 10 - k * 14
		draw_line(Vector2(base.x - w / 2 + 4, y), Vector2(base.x + w / 2 - 4, y), Color(0, 0, 0, 0.45), 1)
	if caiu:
		return
	var topo := base + Vector2(0, -alt)
	for k in 3:
		draw_rect(Rect2(topo + Vector2(-20 + k * 15, -10), Vector2(10, 10)), Color8(52, 46, 62))
	brilho_suave(topo + Vector2(0, -24), 40, ROXO, 1.0 + 0.3 * sin(tempo * 3))
	cristal(topo + Vector2(0, -24), 13)
	var wb := 60.0
	var y0 := topo.y - 52
	draw_rect(Rect2(base.x - wb / 2 - 1, y0 - 1, wb + 2, 7), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(base.x - wb / 2, y0, wb * clampf(torre_hp / maxf(1.0, torre_max), 0, 1), 5), ROXO)


# ============================================================ a tela do Kravenox
const CARTAS_KX := ["vida", "forca", "defesa", "critico"]
const CORES_FORMA := [Color8(180, 40, 40), Color8(210, 40, 44), Color8(230, 50, 40), Color8(220, 30, 80),
	Color8(190, 40, 150), Color8(150, 60, 220), Color8(120, 70, 255), Color8(90, 140, 255),
	Color8(255, 120, 60), Color8(255, 200, 80)]


func contar_total(id: String, n := 1) -> void:
	if robo:
		return
	var t: Dictionary = prog.get("total", {})
	t[id] = int(t.get(id, 0)) + n
	prog["total"] = t


func indice_melhoria(id: String) -> int:
	for i in MELHORIAS.size():
		if MELHORIAS[i]["id"] == id:
			return i
	return 0


func nivel_kravenox() -> int:
	var n := 1
	for m in MELHORIAS:
		n += nivel_melhoria(m["id"])
	return n


func forma_atual() -> int:
	var nv := nivel_kravenox()
	var f := 0
	for i in FORMAS_KX.size():
		if nv >= int(FORMAS_KX[i][0]):
			f = i
	return f


func cor_forma() -> Color:
	return CORES_FORMA[forma_atual()]


func progresso_conquista(c: Dictionary) -> int:
	match c["tipo"]:
		"feitos":
			return prog["feitos"].size()
		"feitos_p":
			return prog.get("feitos_p", {}).size()
		"nivel":
			return nivel_kravenox()
	return int(prog.get("total", {}).get(c["tipo"], 0))


func conquistas_prontas() -> int:
	var n := 0
	var pegas: Dictionary = prog.get("conquistas", {})
	for c in CONQUISTAS:
		if progresso_conquista(c) >= int(c["meta"]) and not pegas.has(c["id"]):
			n += 1
	return n


func icone_pequeno(tipo: String, c: Vector2, cor: Color) -> void:
	match tipo:
		"vida":
			draw_circle(c + Vector2(-7, -4), 9, cor)
			draw_circle(c + Vector2(7, -4), 9, cor)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-15, 0), c + Vector2(15, 0), c + Vector2(0, 16)]), cor)
			draw_circle(c + Vector2(-9, -7), 3, Color(1, 1, 1, 0.6))
		"forca":
			for k in [-1.0, 1.0]:
				draw_line(c + Vector2(-14 * k, 14), c + Vector2(13 * k, -14), Color8(220, 220, 230), 5, true)
				draw_line(c + Vector2(-10 * k, 4), c + Vector2(-3 * k, 11), cor, 4, true)
		"defesa":
			poli([c + Vector2(0, -17), c + Vector2(14, -11), c + Vector2(12, 5), c + Vector2(0, 17), c + Vector2(-12, 5), c + Vector2(-14, -11)], cor, 1.5)
			poli([c + Vector2(0, -12), c + Vector2(8, -8), c + Vector2(7, 3), c + Vector2(0, 11)], Color(1, 1, 1, 0.25))
		"critico":
			var e := []
			for k in 10:
				e.append(c + Vector2.from_angle(-PI / 2 + k * TAU / 10) * (17.0 if k % 2 == 0 else 7.0))
			poli(e, cor, 1.5)


func desenhar_kravenox_tela() -> void:
	desenhar_fundo(0.55)
	var cf := cor_forma()
	var f := forma_atual()
	var nv := nivel_kravenox()
	# poder e forma
	escrever("PODER", Vector2(LARG / 2, 136), 13, Color8(255, 170, 120), true, fonte_titulo)
	escrever(str(poder()), Vector2(LARG / 2, 166), 34, OURO, true)
	escrever(FORMAS_KX[f][1].to_upper(), Vector2(LARG / 2, 202), 16, cf.lightened(0.3), true, fonte_titulo)
	# o Kravenox com a aura da forma
	var base := Vector2(LARG / 2, 418)
	brilho_suave(base + Vector2(0, -95), 150, cf, 0.7 + 0.15 * sin(tempo * 2))
	sombra_chao(base, 64)
	desenhar_arte("kravenox", base + Vector2(0, -sin(tempo * 1.4) * 3), 196, false)
	var b := botoes_menu()
	botao_icone(b["kx_formas"], "formas", "Formas")
	botao_icone(b["kx_conquistas"], "conquistas", "Conquistas", conquistas_prontas() > 0)
	botao_icone(b["kx_bestiario"], "bestiario", "Bestiário")
	# barra até a próxima forma
	var ini := int(FORMAS_KX[f][0])
	var prox := int(FORMAS_KX[f + 1][0]) if f + 1 < FORMAS_KX.size() else ini
	var fr := 1.0 if prox == ini else clampf(float(nv - ini) / float(prox - ini), 0, 1)
	var barra := Rect2(30, 442, LARG - 60, 14)
	caixa(barra.grow(2), Color8(20, 16, 26), 8, 1, Color(OURO, 0.6))
	if fr > 0:
		degrade(Rect2(barra.position, Vector2(barra.size.x * fr, barra.size.y)), cf.lightened(0.2), cf.darkened(0.3))
	escrever("Nível %d" % nv, Vector2(LARG / 2, 472), 16, BRANCO)
	if f + 1 < FORMAS_KX.size():
		escrever("Próxima forma: %s (nível %d)" % [FORMAS_KX[f + 1][1], prox], Vector2(LARG / 2, 492), 13, CINZA, false)
	else:
		escrever("Forma final alcançada", Vector2(LARG / 2, 492), 13, OURO, false)
	# atributos
	var atr := [["vida", "%d" % int(150 + 20 * nivel_melhoria("vida")), Color8(230, 60, 70)],
		["forca", "+%d%%" % (10 * nivel_melhoria("forca")), Color8(240, 160, 60)],
		["defesa", "-%d%%" % (3 * nivel_melhoria("defesa")), Color8(110, 170, 255)],
		["critico", "%d%%" % (3 * nivel_melhoria("critico")), Color8(200, 120, 255)]]
	for i in 4:
		var r := Rect2(14 + i * 114, 502, 110, 26)
		caixa(r, Color(0.05, 0.04, 0.07, 0.9), 13, 1, Color(atr[i][2], 0.6))
		draw_set_transform(r.position + Vector2(16, 13), 0, Vector2(0.55, 0.55))
		icone_pequeno(atr[i][0], Vector2.ZERO, atr[i][2])
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		escrever(atr[i][1], r.get_center() + Vector2(8, 0), 15, BRANCO, false)
	# as quatro cartas de evolução
	var nomes := {"vida": "Vida", "forca": "Ataque", "defesa": "Defesa", "critico": "Crítico"}
	var fundos := {"vida": Color8(40, 110, 60), "forca": Color8(140, 90, 30), "defesa": Color8(40, 80, 150), "critico": Color8(100, 50, 150)}
	for i in 4:
		var id: String = CARTAS_KX[i]
		var m: Dictionary = MELHORIAS[indice_melhoria(id)]
		var r: Rect2 = b["kx_carta%d" % i]
		var lv := nivel_melhoria(id)
		var mx := int(m["max"])
		caixa(r, Color(fundos[id], 0.95), 10, 2, Color(fundos[id].lightened(0.4), 0.9), true, 6)
		degrade(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6, 60)), Color(1, 1, 1, 0.12), Color(1, 1, 1, 0))
		escrever(nomes[id], Vector2(r.get_center().x, r.position.y + 18), 16, BRANCO, true)
		brilho_suave(Vector2(r.get_center().x, r.position.y + 66), 40, Color.WHITE, 0.4)
		icone_pequeno(id, Vector2(r.get_center().x, r.position.y + 66), atr[i][2].lightened(0.15))
		escrever("Nv %d/%d" % [lv, mx], Vector2(r.get_center().x, r.position.y + 104), 14, BRANCO, true)
		var curto := {"vida": "+20 de vida", "forca": "+10% de dano", "defesa": "-3% de dano sofrido", "critico": "+3% de crítico"}
		escrever(curto[id], Vector2(r.get_center().x, r.position.y + 124), 12, Color(1, 1, 1, 0.85), false)
		var bb := Rect2(r.position.x + 8, r.end.y - 50, r.size.x - 16, 40)
		if lv >= mx:
			botao(bb, "MÁX", CINZA, false)
		else:
			var custo := custo_melhoria(m)
			var pode := int(prog["fragmentos"]) >= custo
			botao(bb, "", OURO if pode else CINZA, pode, pode)
			cristal(bb.position + Vector2(24, 20), 7, VERMELHO)
			escrever_esq(str(custo), bb.position + Vector2(36, 27), 18, BRANCO if pode else CINZA)
	cabecalho("KRAVENOX")
	desenhar_abas()
	desenhar_popup()


func desenhar_formas() -> void:
	desenhar_fundo(0.65)
	cabecalho("FORMAS")
	var f := forma_atual()
	var nv := nivel_kravenox()
	for i in FORMAS_KX.size():
		var r := Rect2(16, TOPO_MUNDOS + 4 + i * 61, LARG - 32, 56)
		var tem := nv >= int(FORMAS_KX[i][0])
		var cor: Color = CORES_FORMA[i]
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 10, 2 if i == f else 1, OURO if i == f else Color(PEDRA_BORDA, 0.8), true, 4)
		var c := r.position + Vector2(32, 28)
		brilho_suave(c, 30, cor, 1.0 if tem else 0.2)
		draw_circle(c, 13, cor if tem else PEDRA_ESC)
		draw_arc(c, 13, 0, TAU, 20, Color(OURO, 0.8 if tem else 0.3), 1.5, true)
		escrever_esq(FORMAS_KX[i][1], r.position + Vector2(60, 25), 16, BRANCO if tem else CINZA, fonte_titulo)
		escrever_esq("Nível %d" % int(FORMAS_KX[i][0]), r.position + Vector2(60, 45), 13, CINZA)
		if i == f:
			escrever("ATUAL", Vector2(r.end.x - 44, r.get_center().y), 13, OURO, false, fonte_titulo)
		elif not tem:
			draw_rect(Rect2(Vector2(r.end.x - 50, r.get_center().y - 4), Vector2(14, 11)), CINZA)
			draw_arc(Vector2(r.end.x - 43, r.get_center().y - 5), 5, PI, TAU, 10, CINZA, 2)
	desenhar_abas()


func desenhar_conquistas() -> void:
	desenhar_fundo(0.65)
	cabecalho("CONQUISTAS")
	var b := botoes_menu()
	var pegas: Dictionary = prog.get("conquistas", {})
	for i in CONQUISTAS.size():
		var c: Dictionary = CONQUISTAS[i]
		var r := Rect2(12, TOPO_MUNDOS + 6 + i * 51, LARG - 24, 47)
		var feito_n := mini(progresso_conquista(c), int(c["meta"]))
		var pronta := feito_n >= int(c["meta"])
		var pega: bool = pegas.has(c["id"])
		caixa(r, Color(0.06, 0.05, 0.08, 0.93), 8, 1, Color(OURO if pronta and not pega else PEDRA_BORDA, 0.9))
		escrever_esq(c["nome"], r.position + Vector2(12, 20), 14, OURO if pronta else BRANCO)
		var barra := Rect2(r.position + Vector2(12, 30), Vector2(220, 7))
		draw_rect(barra, Color8(20, 16, 26))
		draw_rect(Rect2(barra.position, Vector2(barra.size.x * feito_n / float(c["meta"]), barra.size.y)), Color8(200, 60, 50))
		escrever_esq("%d/%d" % [feito_n, int(c["meta"])], r.position + Vector2(242, 39), 12, CINZA)
		var bb: Rect2 = b["conquista%d" % i]
		if pega:
			botao(bb, "Pega ✓", CINZA, false)
		else:
			botao(bb, "", OURO if pronta else CINZA, pronta, pronta)
			cristal(bb.position + Vector2(24, 16), 6, VERMELHO)
			escrever_esq(str(int(c["premio"])), bb.position + Vector2(36, 23), 16, BRANCO if pronta else CINZA)
	desenhar_abas()
	desenhar_popup()
