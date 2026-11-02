# Kravenox: Quadros do Cisma. Todo o jogo num nó só.
#
# O Kravenox anda sem parar por um anel de 12 quadros. Cada quadro guarda um
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
const TAM := 84.0
const PASSO_GRADE := 94.0
const OX := 57.0
const OY := 200.0
const LOJA_Y := 600.0
const NIVEL_MAX := 5
const TOTAL_ONDAS := 15
const ANEL := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(3, 1), Vector2i(3, 2),
	Vector2i(3, 3), Vector2i(2, 3), Vector2i(1, 3), Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1)]
const CHEFES := {5: "larvamae", 10: "semrosto", 15: "thornox"}

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
	"garras": {"nome": "Garras", "custo": 8, "cor": Color8(230, 60, 50)},
	"espinhos": {"nome": "Espinhos Vorazes", "custo": 10, "cor": Color8(200, 40, 60)},
	"raio": {"nome": "Raio da Essência", "custo": 12, "cor": Color8(170, 110, 255)},
	"esmagamento": {"nome": "Esmagamento", "custo": 14, "cor": Color8(200, 140, 80)},
	"rasgo": {"nome": "Rasgo do Abismo", "custo": 12, "cor": Color8(230, 30, 90)},
	"cristal": {"nome": "Cristal de Vida", "custo": 9, "cor": Color8(90, 220, 170)},
	"passo": {"nome": "Passo Predador", "custo": 7, "cor": Color8(110, 210, 120)},
	"fonte": {"nome": "Fonte de Essência", "custo": 10, "cor": Color8(190, 130, 255)},
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
var k_rapido := 0.0
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

# som: trilhas do RPG 2D (kravenox-jogar/rpg/music) e efeitos do Cratera do Cisma
const TRILHAS_EM_LACO := ["abismo", "batalha", "chefe", "espinhos"]
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
	fundo = load("res://assets/arte/cratera.png")
	vinheta = gerar_vinheta()
	preparar_som()
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


func tocar_musica(nome: String) -> void:
	if nome == faixa or robo:
		return
	faixa = nome
	var st: AudioStreamOggVorbis = load("res://musica/%s.ogg" % nome)
	st.loop = nome in TRILHAS_EM_LACO
	st.loop_offset = 0.5   # o mesmo ponto de volta que o RPG usa (music/index.json)
	musica.stream = st
	if som_ligado:
		musica.play()


func som(nome: String) -> void:
	if robo or not som_ligado:
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
	match estado:
		"onda":
			if onda == TOTAL_ONDAS:
				return "espinhos"
			return "chefe" if CHEFES.has(onda) else "batalha"
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
func carregar(nome: String) -> void:
	var t: Texture2D = load("res://assets/arte/%s.png" % nome)
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


func novo_jogo() -> void:
	onda = 0
	essencia = 25
	hp_max = 150.0
	hp = hp_max
	quadros = []
	quadros.resize(12)
	brilho = []
	brilho.resize(12)
	brilho.fill(0.0)
	k_pos = 0.0
	k_rapido = 0.0
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
	trocas_gratis = 1
	mortes = 0
	aviso("Compre um poder e toque num quadro", 6.0)
	sortear_loja()


# ------------------------------------------------------------ tabuleiro
func centro_quadro(i: int) -> Vector2:
	var g: Vector2i = ANEL[i]
	return Vector2(OX + g.x * PASSO_GRADE + TAM / 2, OY + g.y * PASSO_GRADE + TAM / 2)


func ret_quadro(i: int) -> Rect2:
	var g: Vector2i = ANEL[i]
	return Rect2(OX + g.x * PASSO_GRADE, OY + g.y * PASSO_GRADE, TAM, TAM)


func pos_kravenox() -> Vector2:
	var a := int(k_pos) % 12
	var b := (a + 1) % 12
	var f := k_pos - floorf(k_pos)
	return centro_quadro(a).lerp(centro_quadro(b), f) + Vector2(0, -18)


# ------------------------------------------------------------ loja
func sortear_loja() -> void:
	loja = []
	var ids := ITENS.keys()
	for _i in 3:
		loja.append(ids.pick_random())


func preco(iid: String) -> int:
	return ITENS[iid]["custo"] + onda / 3


func valor_venda(q: Dictionary) -> int:
	return (ITENS[q["id"]]["custo"] * int(pow(2, q["nv"] - 1))) / 2


func colocar(i: int, item: Dictionary) -> bool:
	var q = quadros[i]
	if q == null:
		quadros[i] = item
		return true
	if q["id"] == item["id"] and q["nv"] == item["nv"] and q["nv"] < NIVEL_MAX:
		q["nv"] += 1
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
	onda += 1
	estado = "onda"
	selec = []
	vender = false
	var tipos := ["larva", "larva", "larva", "larva", "larva"]
	if onda >= 2:
		tipos += ["esfera", "esfera", "esfera"]
	if onda >= 3:
		tipos += ["verme", "verme"]
	if onda >= 5:
		tipos += ["sentinela", "sentinela"]
	if onda >= 8:
		tipos += ["verme", "sentinela", "sentinela"]
	fila = []
	for _i in 6 + onda * 2:
		fila.append(tipos.pick_random())
	if CHEFES.has(onda):
		fila.insert(3, CHEFES[onda])
		aviso("Chefe: %s!" % MONSTROS[CHEFES[onda]]["nome"], 3.0)
	else:
		aviso("Onda %d" % onda, 1.5)
	t_spawn = 0.8
	t_onda = 0.0
	gap = maxf(0.35, 1.3 - onda * 0.06)


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
	var esc := 1.0 + 0.18 * (onda - 1)
	var vida: float = m["hp"] * (esc if not chefe else 1.0 + 0.1 * (onda - 1))
	monstros.append({"tipo": tipo, "pos": p, "hp": vida, "hp_max": vida, "vel": m["vel"],
		"dano": m["dano"] * 0.7 * (1.0 + 0.05 * onda), "premio": m["premio"], "t_ataque": 0.0,
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
	var mult := 1.0 + 0.8 * (nv - 1)
	var k := pos_kravenox()
	match q["id"]:
		"garras":
			som("corte")
			var r := 95.0 + nv * 8
			efeitos.append({"t": "garra", "p": k, "r": r, "vida": 0.25})
			for m in monstros:
				if m["pos"].distance_to(k) < r:
					ferir(m, 12 * mult)
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
			k_rapido = 1.6 + 0.5 * nv
			anel(k + Vector2(0, 18), 10, 40, 0.25, VERDE)
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
	m["hp"] -= dano
	m["flash"] = 0.1
	texto_voa(m["pos"] + Vector2(randf_range(-8, 8), -30), str(int(dano)), BRANCO)
	if m["hp"] <= 0:
		som("acerto")
		mortes += 1
		essencia += m["premio"]
		for _i in (40 if m["chefe"] else 10):
			efeitos.append({"t": "part", "p": m["pos"], "v": Vector2.from_angle(randf() * TAU) * randf_range(40, 160), "vida": 0.6})
		if m["premio"] > 0:
			texto_voa(m["pos"] + Vector2(0, -10), "+%d" % m["premio"], OURO)


# ------------------------------------------------------------ laço
func _process(delta: float) -> void:
	if robo:
		for _i in 30:
			passo_robo()
			atualizar(1.0 / 60.0)
			if estado == "derrota" or estado == "vitoria":
				print("ROBO fim: %s na onda %d, %d monstros" % [estado, onda, mortes])
				get_tree().quit()
				return
	else:
		atualizar(minf(delta, 0.05))
		tocar_musica(musica_certa())
	queue_redraw()


func atualizar(dt: float) -> void:
	dt *= vel_jogo
	tempo += dt
	msg_t -= dt
	for i in 12:
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
	if estado != "onda":
		return

	# o Kravenox anda sem parar
	var vel := k_vel * (1.7 if k_rapido > 0 else 1.0)
	k_rapido = maxf(0.0, k_rapido - dt)
	var antes := pos_kravenox().x
	k_pos = fmod(k_pos + vel * dt, 12.0)
	k_anim += dt * vel * 6
	k_flash = maxf(0.0, k_flash - dt)
	var depois := pos_kravenox().x
	if absf(depois - antes) > 0.01:
		k_dir = 1 if depois > antes else -1
	var atual := int(k_pos + 0.5) % 12   # o quadro em que ele está pisando
	if atual != k_ultimo:
		k_ultimo = atual
		ativar(atual)

	if not fila.is_empty():
		t_spawn -= dt
		if t_spawn <= 0:
			criar_monstro(fila.pop_front())
			t_spawn = gap * randf_range(0.6, 1.3)

	t_onda += dt
	var pressa := 1.0 + maxf(0.0, t_onda - 20.0) * 0.05
	var k := pos_kravenox()
	var novos := []
	for m in monstros:
		m["anim"] += dt
		m["flash"] -= dt
		var para: Vector2 = k - m["pos"]
		var alcance := 70.0 if m["chefe"] else 34.0
		if para.length() > alcance:
			m["pos"] += para.normalized() * m["vel"] * pressa * dt
		else:
			m["t_ataque"] -= dt
			if m["t_ataque"] <= 0:
				m["t_ataque"] = 1.0
				hp -= m["dano"]
				som("dano")
				k_flash = 0.15
				texto_voa(k + Vector2(0, -50), "-%d" % int(m["dano"]), VERMELHO)
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
	elif fila.is_empty() and monstros.is_empty():
		if onda >= TOTAL_ONDAS:
			estado = "vitoria"
		else:
			estado = "loja"
			var premio := 5 + onda
			essencia += premio
			hp = minf(hp_max, hp + 30)
			trocas_gratis = 1
			sortear_loja()
			tiros.clear()
			aviso("Onda vencida! +%d de essência, +30 vida" % premio, 3.0)


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
	b["denovo"] = Rect2(LARG / 2 - 110, ALT / 2 + 40, 220, 56)
	return b


func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		clique(make_input_local(ev).position)
	elif ev is InputEventKey and ev.pressed and ev.keycode == KEY_SPACE and estado == "loja":
		iniciar_onda()


func clique(p: Vector2) -> void:
	var b := botoes()
	if estado == "derrota" or estado == "vitoria":
		if b["denovo"].has_point(p):
			novo_jogo()
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
	for i in 12:
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
func passo_robo() -> void:
	if estado != "loja":
		return
	var b := botoes()
	for i in 3:
		if loja[i] != null and essencia >= preco(loja[i]):
			clique(b["loja%d" % i].get_center())
			var alvo := -1
			for k in 12:
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
		return
	print("ROBO onda %d: vida %d, essência %d" % [onda + 1, int(hp), essencia])
	clique(b["onda"].get_center())



# ------------------------------------------------------------ desenho
func caixa(r: Rect2, cor: Color, raio := 6, borda := 0, cor_borda := Color.BLACK, centro := true, sombra := 0) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = cor
	sb.draw_center = centro
	sb.set_corner_radius_all(raio)
	sb.anti_aliasing = true
	if borda > 0:
		sb.set_border_width_all(borda)
		sb.border_color = cor_borda
	if sombra > 0:
		sb.shadow_size = sombra
		sb.shadow_color = Color(0, 0, 0, 0.6)
		sb.shadow_offset = Vector2(0, 3)
	draw_style_box(sb, r)


# Retângulo com degradê vertical (pedra iluminada de cima)
func degrade(r: Rect2, cima: Color, baixo: Color) -> void:
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
		PackedColorArray([cima, cima, baixo, baixo]))


func brilho_suave(c: Vector2, r: float, cor: Color, forca := 1.0) -> void:
	for k in 6:
		var f := 1.0 - k / 6.0
		draw_circle(c, r * f, Color(cor, 0.07 * forca * (1.0 + k * 0.35)))


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


func _draw() -> void:
	# fundo: a pintura da Cratera do Cisma, escurecida para o tabuleiro aparecer
	draw_texture_rect(fundo, Rect2(0, 0, LARG, ALT), false)
	draw_rect(Rect2(0, 0, LARG, ALT), Color(0.03, 0.02, 0.06, 0.38))
	draw_texture_rect(vinheta, Rect2(0, 0, LARG, ALT), false)
	# névoa roxa lenta sobre a cratera
	for k in 3:
		var p := Vector2(LARG / 2 + sin(tempo * 0.2 + k * 2.1) * 120, 390 + cos(tempo * 0.17 + k) * 80)
		brilho_suave(p, 170, ROXO_ESC, 0.5)
	for i in 12:
		desenhar_quadro(i)
	desenhar_mundo()
	desenhar_topo()   # por cima dos monstros que entram pelo alto
	desenhar_loja()
	if msg_t > 0 and msg != "":
		var w := fonte.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		var a := clampf(msg_t * 2, 0, 1)
		caixa(Rect2(LARG / 2 - w / 2 - 14, 158, w + 28, 28), Color(0.05, 0.04, 0.07, 0.9 * a), 14, 1, Color(OURO, 0.7 * a))
		escrever(msg, Vector2(LARG / 2, 172), 18, Color(BRANCO, a), false)
	if estado == "derrota" or estado == "vitoria":
		draw_rect(Rect2(0, 0, LARG, ALT), Color(0.02, 0.01, 0.03, 0.82))
		var venceu := estado == "vitoria"
		if venceu:
			brilho_suave(Vector2(LARG / 2, ALT / 2 - 170), 120, OURO, 0.8)
			desenhar_arte("kravenox", Vector2(LARG / 2, ALT / 2 - 100), 140, false)
		else:
			brilho_suave(Vector2(LARG / 2, ALT / 2 - 170), 120, VERMELHO, 0.6)
			desenhar_arte("kravenox", Vector2(LARG / 2, ALT / 2 - 100), 140, false, Color(0.45, 0.4, 0.5))
		escrever("O REINO É DO KRAVENOX" if venceu else "O KRAVENOX CAIU", Vector2(LARG / 2, ALT / 2 - 55), 28,
			OURO if venceu else VERMELHO, true, fonte_titulo)
		var t2 := "As 15 ondas foram vencidas" if venceu else "Chegou à onda %d de %d" % [onda, TOTAL_ONDAS]
		escrever(t2 + "  ·  %d monstros" % mortes, Vector2(LARG / 2, ALT / 2 - 15), 18, CINZA)
		botao(botoes()["denovo"], "Jogar de novo", OURO, true, true)


func desenhar_topo() -> void:
	degrade(Rect2(0, 0, LARG, 150), Color(0.02, 0.01, 0.03, 0.85), Color(0.02, 0.01, 0.03, 0.0))
	escrever_esq("CAPÍTULO I · REINO QUEBRADO", Vector2(16, 28), 14, OURO, fonte_titulo)
	var t := "ONDA %d/%d" % [onda, TOTAL_ONDAS]
	var w := fonte_titulo.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	escrever_esq(t, Vector2(LARG - 16 - w, 28), 14, BRANCO, fonte_titulo)
	# trilha das ondas
	var y := 54.0
	draw_line(Vector2(30, y), Vector2(LARG - 30, y), Color(0, 0, 0, 0.7), 5)
	var feito_x := 30 + (LARG - 60) * clampf((onda - 1) / float(TOTAL_ONDAS - 1), 0, 1)
	if onda > 1:
		draw_line(Vector2(30, y), Vector2(feito_x, y), SANGUE, 3)
	for o in range(1, TOTAL_ONDAS + 1):
		var x := 30 + (LARG - 60) * (o - 1) / (TOTAL_ONDAS - 1)
		var p := Vector2(x, y)
		var feita := o < onda or (o == onda and estado != "onda")
		var atual := o == onda and estado == "onda"
		if CHEFES.has(o):
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
			draw_circle(p, 6.5, TINTA)
			draw_circle(p, 5, VERMELHO if atual else (SANGUE if feita else PEDRA_CLARA))
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
	escrever("%d / %d" % [int(maxf(0, hp)), int(hp_max)], Vector2(bx + bw / 2, 103), 16, BRANCO)
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


func desenhar_quadro(i: int) -> void:
	var r := ret_quadro(i)
	var q = quadros[i]
	var sel := selec == ["quadro", i]
	var luz: float = brilho[i] / 0.35
	# laje de pedra
	caixa(r.grow(2), Color(0, 0, 0, 0.6), 7, 0, Color.BLACK, true, 6)
	degrade(r, PEDRA_CLARA, PEDRA_ESC)
	caixa(r, Color(0, 0, 0, 0), 6, 2, PEDRA_BORDA, false)
	caixa(r.grow(-7), Color(0.05, 0.04, 0.07, 0.55), 4, 1, Color(0, 0, 0, 0.5))
	# rachaduras finas na pedra (fixas por quadro)
	var rnd := RandomNumberGenerator.new()
	rnd.seed = i * 977 + 13
	for k in 2:
		var a := r.position + Vector2(rnd.randf_range(8, TAM - 8), rnd.randf_range(8, TAM - 8))
		var b := a + Vector2(rnd.randf_range(-14, 14), rnd.randf_range(-14, 14))
		draw_line(a, b, Color(0, 0, 0, 0.35), 1)
	if luz > 0:
		caixa(r.grow(1), Color(0, 0, 0, 0), 7, 3, Color(ROXO, luz), false)
		brilho_suave(r.get_center(), 60, ROXO, luz)
	if sel or (vender and q != null):
		caixa(r.grow(3), Color(0, 0, 0, 0), 8, 3, OURO if sel else VERMELHO, false)
	var c := r.get_center()
	if q == null:
		var cc := Color(ROXO, 0.22 + 0.08 * sin(tempo * 2 + i))
		draw_line(c + Vector2(-10, 0), c + Vector2(10, 0), cc, 2, true)
		draw_line(c + Vector2(0, -10), c + Vector2(0, 10), cc, 2, true)
		draw_arc(c, 16, 0, TAU, 28, Color(cc, cc.a * 0.6), 1, true)
	else:
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
			for k in [-9.0, 5.0]:
				poli([P.call(k - 9, -15), P.call(k + 7, 0), P.call(k - 9, 15), P.call(k - 3, 0)], cor.darkened(0.2), 1.5)
			draw_line(P.call(-24, 0), P.call(-14, 0), Color(cor, 0.5), 2)
		"fonte":
			cristal(c, 22 * e, cor)
			for k in 3:
				var a := tempo * 1.5 + k * TAU / 3
				draw_circle(c + Vector2(cos(a), sin(a) * 0.6) * 22 * e, 2 * e, Color(1, 0.9, 1, 0.8))


func desenhar_mundo() -> void:
	var k := pos_kravenox()
	var itens := []
	for m in monstros:
		itens.append([m["pos"].y, m])
	itens.append([k.y, null])
	itens.sort_custom(func(a, b): return a[0] < b[0])
	for it in itens:
		var m = it[1]
		if m == null:
			desenhar_kravenox(k)
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
				var f: float = 1.0 - e["vida"] / 0.25
				for d in [-0.45, 0.0, 0.45]:
					var a0: float = f * TAU + d
					draw_arc(e["p"], e["r"], a0, a0 + 1.0, 14, Color(1, 0.3, 0.25, 0.35), 8, true)
					draw_arc(e["p"], e["r"], a0, a0 + 1.0, 14, Color(1, 0.75, 0.7, 0.9), 2, true)
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
	var andando := estado == "onda"
	var passo := sin(k_anim * 1.6) if andando else sin(tempo * 2) * 0.3
	var base := k + Vector2(0, 30)
	sombra_chao(base, 30)
	if k_rapido > 0:
		draw_set_transform(base, 0, Vector2(1, 0.3))
		draw_arc(Vector2.ZERO, 34, 0, TAU, 32, Color(VERDE, 0.6), 3, true)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	# aura vermelha da Essência Corrompida
	brilho_suave(k + Vector2(0, -6), 52, VERMELHO, 0.45 + 0.15 * sin(tempo * 3))
	var esmaga := Vector2(1.0 - 0.03 * absf(passo), 1.0 + 0.04 * absf(passo))
	contorno("kravenox", base + Vector2(0, -absf(passo) * 4), 94, k_dir < 0, Color(VERMELHO, 0.55), passo * 0.06, esmaga)
	desenhar_arte("kravenox", base + Vector2(0, -absf(passo) * 4), 94, k_dir < 0, Color.WHITE,
		false, passo * 0.06, esmaga)
	if k_flash > 0:
		desenhar_arte("kravenox", base + Vector2(0, -absf(passo) * 4), 94, k_dir < 0, Color(1, 0.3, 0.3, k_flash * 4),
			true, passo * 0.06, esmaga)


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
		var area := Rect2(cx - 40, r.position.y + 22, 80, 54)
		degrade(area, Color(0.12, 0.09, 0.16), Color(0.05, 0.04, 0.07))
		icone(iid, area.get_center(), 0.78)
		escrever(ITENS[iid]["nome"], Vector2(cx, r.position.y + 12), 14, BRANCO, false)
		cristal(Vector2(cx - 16, r.end.y - 14), 7)
		escrever_esq(str(custo), Vector2(cx - 5, r.end.y - 6), 20, BRANCO if pode else Color8(200, 80, 80))
		if not ativa:
			draw_rect(r, Color(0, 0, 0, 0.45))
	var t_trocar := "Trocar grátis" if trocas_gratis > 0 else "Trocar (2)"
	botao(b["trocar"], t_trocar if ativa else "Trocar", AZUL, ativa)
	botao(b["lixo"], "Vender", VERMELHO, ativa, vender)
	botao(b["onda"], "Iniciar onda %d" % (onda + 1) if ativa else "Onda em andamento", OURO, ativa, ativa)
	var dica := "Toque no item, depois no quadro"
	if estado == "onda":
		dica = "Monstros: %d  ·  na fila: %d" % [monstros.size(), fila.size()]
	elif vender:
		dica = "Toque num quadro para vender o item"
	elif not selec.is_empty() and selec[0] == "loja":
		dica = "Agora toque num quadro"
	escrever(dica, Vector2(LARG / 2, LOJA_Y + 32), 14, CINZA, false)
