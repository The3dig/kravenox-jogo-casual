# Kravenox: Quadros do Cisma. Todo o jogo num nó só.
#
# O Kravenox anda sem parar por um anel de 12 quadros. Cada quadro guarda um
# poder comprado na loja; quando ele pisa no quadro, o poder dispara. Os
# monstros do livro chegam em ondas: 15 ondas, chefe na 5, na 10 e na 15.
#
# Tudo é desenhado em _draw() a partir de dados simples (dicionários), como
# na versão em Python (kravenox_quadros.py), para as duas ficarem iguais.
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
const CHEFES := {5: "larvamae", 10: "coisa", 15: "devorador"}

# vermelho é do Kravenox, roxo é do Vazio
var FUNDO := Color8(92, 40, 38)
var PEDRA := Color8(96, 96, 102)
var PEDRA_CLARA := Color8(130, 130, 138)
var PEDRA_ESC := Color8(46, 44, 50)
var TINTA := Color8(20, 14, 18)
var BRANCO := Color8(240, 232, 220)
var OURO := Color8(255, 210, 90)
var ROXO := Color8(170, 100, 255)
var VERMELHO := Color8(220, 50, 50)
var VERDE := Color8(80, 190, 90)
var MADEIRA := Color8(90, 62, 40)
var PAPEL := Color8(214, 196, 160)

# Poderes do Kravenox (os cinco primeiros vêm do Cratera do Cisma)
var ITENS := {
	"garras": {"nome": "Garras", "custo": 8, "cor": Color8(230, 70, 60)},
	"espinhos": {"nome": "Espinhos", "custo": 10, "cor": Color8(40, 40, 50)},
	"raio": {"nome": "Raio Essência", "custo": 12, "cor": Color8(170, 100, 255)},
	"esmagamento": {"nome": "Esmagamento", "custo": 14, "cor": Color8(150, 110, 70)},
	"rasgo": {"nome": "Rasgo Abismo", "custo": 12, "cor": Color8(200, 30, 90)},
	"cristal": {"nome": "Cristal Vida", "custo": 9, "cor": Color8(90, 220, 160)},
	"passo": {"nome": "Passo Predador", "custo": 7, "cor": Color8(80, 190, 90)},
	"fonte": {"nome": "Fonte Essência", "custo": 10, "cor": Color8(255, 210, 90)},
}

# Monstros do livro e do gibi (universo/inimigos, biblia/personagens)
var MONSTROS := {
	"larva": {"nome": "Larva da Essência", "hp": 22.0, "vel": 34.0, "dano": 5.0, "premio": 2, "img": ["larva-0", "larva-1"], "esc": 1.7},
	"olho": {"nome": "Sentinela Esférica", "hp": 14.0, "vel": 70.0, "dano": 4.0, "premio": 2, "img": ["olho-0", "olho-1"], "esc": 1.5},
	"sentinela": {"nome": "Sentinela do Vazio", "hp": 55.0, "vel": 30.0, "dano": 10.0, "premio": 4, "img": ["sentinela-0", "sentinela-1"], "esc": 1.5},
	"sombra": {"nome": "Sombra", "hp": 34.0, "vel": 58.0, "dano": 7.0, "premio": 3, "img": ["sombra"], "esc": 0.85},
	"devmenor": {"nome": "Devorador Menor", "hp": 80.0, "vel": 40.0, "dano": 12.0, "premio": 6, "img": ["devorador-menor"], "esc": 0.45},
	"larvamae": {"nome": "Larva-Mãe", "hp": 420.0, "vel": 18.0, "dano": 20.0, "premio": 40, "img": ["larva-0", "larva-1"], "esc": 4.0, "chefe": true},
	"coisa": {"nome": "A Coisa que Dormia", "hp": 1100.0, "vel": 14.0, "dano": 28.0, "premio": 80, "img": ["coisa-que-dormia"], "esc": 1.0, "chefe": true},
	"devorador": {"nome": "O Devorador", "hp": 2300.0, "vel": 16.0, "dano": 35.0, "premio": 0, "img": ["devorador"], "esc": 1.15, "chefe": true},
}

var fonte: Font
var tex := {}          # nome -> Texture2D
var tex_branca := {}   # nome -> silhueta branca (piscar ao levar dano)
var chao: Texture2D
var robo := false      # modo de teste automático (--robo)

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


func _ready() -> void:
	randomize()
	robo = "--robo" in OS.get_cmdline_user_args() or "--robo" in OS.get_cmdline_args()
	fonte = ThemeDB.fallback_font
	for m in MONSTROS.values():
		for nome in m["img"]:
			carregar(nome)
	for k in 4:
		carregar("kravenox-passo-%d" % k)
	chao = gerar_chao()
	novo_jogo()


func carregar(nome: String) -> void:
	if tex.has(nome):
		return
	var t: Texture2D = load("res://assets/%s.png" % nome)
	tex[nome] = t
	var img := t.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var a := img.get_pixel(x, y).a
			img.set_pixel(x, y, Color(1, 1, 1, a))
	tex_branca[nome] = ImageTexture.create_from_image(img)


func gerar_chao() -> Texture2D:
	var img := Image.create(int(LARG), int(ALT), false, Image.FORMAT_RGBA8)
	img.fill(FUNDO)
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 7
	var cores := [Color8(70, 28, 28), Color8(110, 50, 46), Color8(80, 34, 34)]
	for _i in 2600:
		var x := rnd.randi_range(0, int(LARG) - 1)
		var y := rnd.randi_range(0, int(ALT) - 1)
		var c: Color = cores[rnd.randi_range(0, 2)]
		var dx := rnd.randi_range(-6, 6)
		var dy := rnd.randi_range(2, 8)
		for s in dy:
			var px := x + int(dx * float(s) / dy)
			var py := y + s
			if px >= 0 and px < LARG and py < ALT:
				img.set_pixel(px, py, c)
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
		tipos += ["olho", "olho", "olho"]
	if onda >= 4:
		tipos += ["sentinela", "sentinela"]
	if onda >= 6:
		tipos += ["sombra", "sombra", "sombra"]
	if onda >= 9:
		tipos += ["devmenor", "devmenor"]
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
			var r := 95.0 + nv * 8
			efeitos.append({"t": "garra", "p": k, "r": r, "vida": 0.25})
			for m in monstros:
				if m["pos"].distance_to(k) < r:
					ferir(m, 12 * mult)
		"espinhos":
			var n := 8 + (nv - 1) * 2
			for j in n:
				var a := float(j) / n * TAU
				tiros.append({"p": k, "v": Vector2.from_angle(a) * 330, "dano": 9 * mult, "fura": 0,
					"vida": 1.0, "cor": Color8(30, 30, 40), "r": 5.0, "acertos": []})
		"raio":
			var alvos := monstros.duplicate()
			alvos.sort_custom(func(x, y): return x["pos"].distance_to(k) < y["pos"].distance_to(k))
			var de := k
			for m in alvos.slice(0, 2 + nv):
				efeitos.append({"t": "raio", "a": de, "b": m["pos"], "vida": 0.2})
				ferir(m, 15 * mult)
				de = m["pos"]
		"esmagamento":
			var r := 150.0 + nv * 12
			anel(k + Vector2(0, 18), 20, r, 0.35, Color8(200, 150, 90))
			for m in monstros:
				if m["pos"].distance_to(k) < r:
					ferir(m, 16 * mult)
		"rasgo":
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
			var cura := 4 + 3 * nv
			hp = minf(hp_max, hp + cura)
			texto_voa(k + Vector2(0, -40), "+%d" % cura, Color8(90, 220, 160))
			anel(k, 10, 50, 0.3, Color8(90, 220, 160))
		"passo":
			k_rapido = 1.6 + 0.5 * nv
			anel(k + Vector2(0, 18), 10, 40, 0.25, VERDE)
		"fonte":
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
	queue_redraw()


func atualizar(dt: float) -> void:
	dt *= vel_jogo
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
				k_flash = 0.15
				texto_voa(k + Vector2(0, -50), "-%d" % int(m["dano"]), VERMELHO)
		if m["chefe"]:
			m["t_poder"] -= dt
			if m["t_poder"] <= 0:
				m["t_poder"] = 5.0
				novos.append(m)
	for m in novos:
		var filhote: String = {"larvamae": "larva", "coisa": "sombra", "devorador": "devmenor"}[m["tipo"]]
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
	b["vel"] = Rect2(LARG - 78, 92, 62, 36)
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
func caixa(r: Rect2, cor: Color, raio := 8, borda := 0, cor_borda := Color.BLACK, centro := true) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = cor
	sb.draw_center = centro
	sb.set_corner_radius_all(raio)
	if borda > 0:
		sb.set_border_width_all(borda)
		sb.border_color = cor_borda
	draw_style_box(sb, r)


func escrever(t: String, centro: Vector2, tam: int, cor: Color, contorno := true) -> void:
	var w := fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
	var p := Vector2(centro.x - w / 2, centro.y + tam * 0.35)
	if contorno:
		draw_string_outline(fonte, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 5, Color(TINTA, cor.a))
	draw_string(fonte, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func botao(r: Rect2, t: String, cor: Color, cor_txt: Color, ativo := true) -> void:
	caixa(r.grow(3), TINTA, 10)
	caixa(r, cor if ativo else PEDRA_ESC, 8)
	escrever(t, r.get_center(), 20, cor_txt if ativo else Color8(120, 120, 120), false)


func desenhar_tex(t: Texture2D, base: Vector2, esc: float, virar: bool, mod := Color.WHITE) -> Rect2:
	var tam := t.get_size() * esc
	draw_set_transform(base, 0, Vector2(-1 if virar else 1, 1))
	draw_texture_rect(t, Rect2(Vector2(-tam.x / 2, -tam.y), tam), false, mod)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	return Rect2(base.x - tam.x / 2, base.y - tam.y, tam.x, tam.y)


func _draw() -> void:
	draw_texture(chao, Vector2.ZERO)
	desenhar_topo()
	for i in 12:
		desenhar_quadro(i)
	desenhar_mundo()
	desenhar_loja()
	if msg_t > 0 and msg != "":
		var w := fonte.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
		caixa(Rect2(LARG / 2 - w / 2 - 10, 160, w + 20, 26), TINTA, 8)
		escrever(msg, Vector2(LARG / 2, 173), 19, BRANCO, false)
	if estado == "derrota" or estado == "vitoria":
		draw_rect(Rect2(0, 0, LARG, ALT), Color(0.04, 0.02, 0.04, 0.8))
		var venceu := estado == "vitoria"
		escrever("O Reino é do Kravenox" if venceu else "O Kravenox caiu", Vector2(LARG / 2, ALT / 2 - 60), 34, OURO if venceu else VERMELHO)
		var t2 := "As 15 ondas foram vencidas" if venceu else "Chegou à onda %d de %d" % [onda, TOTAL_ONDAS]
		escrever(t2 + "  ·  %d monstros" % mortes, Vector2(LARG / 2, ALT / 2 - 15), 19, BRANCO)
		botao(botoes()["denovo"], "Jogar de novo", OURO, TINTA)


func desenhar_topo() -> void:
	draw_string_outline(fonte, Vector2(16, 30), "Capítulo 1 - Reino Quebrado", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, 5, TINTA)
	draw_string(fonte, Vector2(16, 30), "Capítulo 1 - Reino Quebrado", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, BRANCO)
	var t := "Onda %d/%d" % [onda, TOTAL_ONDAS]
	var w := fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
	draw_string_outline(fonte, Vector2(LARG - 16 - w, 30), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, 5, TINTA)
	draw_string(fonte, Vector2(LARG - 16 - w, 30), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, BRANCO)
	# trilha das ondas
	var y := 54.0
	draw_line(Vector2(30, y), Vector2(LARG - 30, y), TINTA, 8)
	for o in range(1, TOTAL_ONDAS + 1):
		var x := 30 + (LARG - 60) * (o - 1) / (TOTAL_ONDAS - 1)
		var feita := o <= onda
		var chefe := CHEFES.has(o)
		var cor := Color8(150, 40, 40) if feita else PEDRA_ESC
		if o == onda and estado == "onda":
			cor = VERMELHO
		elif chefe and not feita:
			cor = Color8(90, 50, 120)
		var r := 12.0 if chefe else 9.0
		draw_circle(Vector2(x, y), r + 2, TINTA)
		draw_circle(Vector2(x, y), r, cor)
		if chefe:
			escrever("C", Vector2(x, y), 14, BRANCO, false)
	# essência e vida
	caixa(Rect2(16, 86, 150, 38), TINTA, 10)
	draw_colored_polygon(PackedVector2Array([Vector2(36, 93), Vector2(46, 105), Vector2(36, 117), Vector2(26, 105)]), ROXO)
	draw_string(fonte, Vector2(56, 113), str(essencia), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, BRANCO)
	var bw := 180.0
	var bx := LARG / 2 - bw / 2 + 20
	caixa(Rect2(bx - 3, 92, bw + 6, 26), TINTA, 8)
	caixa(Rect2(bx, 95, maxf(1.0, bw * clampf(hp / hp_max, 0, 1)), 20), VERMELHO, 6)
	escrever("Vida %d/%d" % [int(maxf(0, hp)), int(hp_max)], Vector2(LARG / 2 + 20, 105), 15, BRANCO)
	botao(botoes()["vel"], "x%d" % vel_jogo, MADEIRA, OURO)


func desenhar_quadro(i: int) -> void:
	var r := ret_quadro(i)
	var sel := selec == ["quadro", i]
	caixa(r.grow(3), TINTA, 8)
	caixa(r, PEDRA_CLARA if brilho[i] > 0 else PEDRA, 6)
	caixa(r.grow(-6), PEDRA_ESC, 4)
	caixa(r.grow(-8), Color8(78, 78, 84), 4)
	var q = quadros[i]
	if sel or (vender and q != null):
		caixa(r.grow(2), Color.TRANSPARENT, 8, 4, OURO if sel else VERMELHO, false)
	var c := r.get_center()
	if q == null:
		var cc := Color8(120, 120, 126)
		draw_line(c + Vector2(-14, 0), c + Vector2(14, 0), cc, 6)
		draw_line(c + Vector2(0, -14), c + Vector2(0, 14), cc, 6)
	else:
		icone(q["id"], c, 1.0)
		caixa(Rect2(r.position + Vector2(4, 4), Vector2(22, 22)), VERDE, 4)
		escrever(str(q["nv"]), r.position + Vector2(15, 15), 16, TINTA, false)


func poli(pts: Array, cor: Color, borda := 0.0) -> void:
	var p := PackedVector2Array(pts)
	draw_colored_polygon(p, cor)
	if borda > 0:
		p.append(p[0])
		draw_polyline(p, TINTA, borda)


func icone(iid: String, c: Vector2, e: float) -> void:
	var cor: Color = ITENS[iid]["cor"]
	var P := func(x: float, y: float) -> Vector2: return c + Vector2(x, y) * e
	match iid:
		"garras":
			for k in [-12.0, 0.0, 12.0]:
				poli([P.call(k - 6, 18), P.call(k + 6, 18), P.call(k + 8, -20)], TINTA)
				poli([P.call(k - 3, 14), P.call(k + 3, 14), P.call(k + 6, -16)], cor)
		"espinhos":
			for k in 8:
				draw_line(c, c + Vector2.from_angle(k / 8.0 * TAU) * 24 * e, TINTA, 5)
			draw_circle(c, 11 * e, Color8(30, 30, 40))
			draw_circle(c, 4 * e, VERMELHO)
		"raio":
			poli([P.call(-4, -24), P.call(10, -24), P.call(2, -4), P.call(10, -4), P.call(-8, 24), P.call(-2, 2), P.call(-10, 2)], cor, 2)
		"esmagamento":
			caixa(Rect2(P.call(-18, -10), Vector2(36, 24) * e), TINTA, 6)
			caixa(Rect2(P.call(-15, -7), Vector2(30, 18) * e), cor, 4)
			draw_line(P.call(-22, 20), P.call(22, 20), TINTA, 4)
		"rasgo":
			draw_set_transform(c, 0, Vector2(0.42, 1.0))
			draw_circle(Vector2.ZERO, 24 * e, TINTA)
			draw_circle(Vector2.ZERO, 19 * e, cor)
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		"cristal":
			poli([P.call(0, -24), P.call(14, -4), P.call(0, 24), P.call(-14, -4)], cor, 3)
		"passo":
			for k in [-10.0, 6.0]:
				poli([P.call(k - 10, -16), P.call(k + 8, 0), P.call(k - 10, 16), P.call(k - 4, 0)], cor, 2)
		"fonte":
			var pts := [P.call(0, -20), P.call(16, 0), P.call(0, 20), P.call(-16, 0)]
			poli(pts, ROXO)
			var pp := PackedVector2Array(pts)
			pp.append(pts[0])
			draw_polyline(pp, cor, 3)


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
			var n := (int(k_anim) % 4) if estado == "onda" else 0
			if k_rapido > 0:
				draw_set_transform(k + Vector2(0, 27), 0, Vector2(1, 0.25))
				draw_arc(Vector2.ZERO, 30, 0, TAU, 32, VERDE, 2)
				draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			draw_set_transform(k + Vector2(0, 28), 0, Vector2(1, 0.22))
			draw_circle(Vector2.ZERO, 28, Color8(40, 16, 16))
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			desenhar_tex(tex["kravenox-passo-%d" % n], k + Vector2(0, 30), 0.62, k_dir < 0)
			if k_flash > 0:
				draw_arc(k, 36, 0, TAU, 32, VERMELHO, 3)
		else:
			var info: Dictionary = MONSTROS[m["tipo"]]
			var nomes: Array = info["img"]
			var nome: String = nomes[int(m["anim"] * 4) % nomes.size()]
			var t: Texture2D = tex_branca[nome] if m["flash"] > 0 else tex[nome]
			var esc: float = info["esc"]
			var h := t.get_height() * esc
			var p: Vector2 = m["pos"]
			var mod := Color(1, 0.6, 0.82) if m["tipo"] == "larvamae" and m["flash"] <= 0 else Color.WHITE
			draw_set_transform(p + Vector2(0, h * 0.37), 0, Vector2(1, 0.2))
			draw_circle(Vector2.ZERO, t.get_width() * esc * 0.35, Color8(40, 16, 16))
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			var rr := desenhar_tex(t, p + Vector2(0, h * 0.4), esc, p.x > k.x, mod)
			if m["hp"] < m["hp_max"] and not m["chefe"]:
				draw_rect(Rect2(p.x - 18, rr.position.y - 8, 36, 6), TINTA)
				draw_rect(Rect2(p.x - 17, rr.position.y - 7, 34 * m["hp"] / m["hp_max"], 4), VERMELHO)
	for t in tiros:
		draw_circle(t["p"], t["r"] + 2, TINTA)
		draw_circle(t["p"], t["r"], t["cor"])
	for e in efeitos:
		match e["t"]:
			"part":
				draw_circle(e["p"], 3, ROXO)
			"anel":
				var f := clampf(1.0 - e["vida"] / e["max"], 0, 1)
				draw_arc(e["p"], lerpf(e["r0"], e["r1"], f), 0, TAU, 40, e["cor"], 3)
			"garra":
				for d in [-0.4, 0.0, 0.4]:
					var a0: float = (1.0 - e["vida"] / 0.25) * TAU + d
					draw_arc(e["p"], e["r"], a0, a0 + 0.9, 12, Color8(255, 90, 70), 4)
			"raio":
				var a: Vector2 = e["a"]
				var b: Vector2 = e["b"]
				var pts := PackedVector2Array([a])
				for j in range(1, 6):
					pts.append(a.lerp(b, j / 6.0) + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
				pts.append(b)
				draw_polyline(pts, Color8(230, 200, 255), 3)
				draw_polyline(pts, ROXO, 1)
	var chefe = null
	for m in monstros:
		if m["chefe"]:
			chefe = m
			break
	if chefe != null:
		var w := LARG - 60
		draw_rect(Rect2(27, 137, w + 6, 16), TINTA)
		draw_rect(Rect2(30, 140, w * chefe["hp"] / chefe["hp_max"], 10), Color8(150, 40, 160))
		escrever(MONSTROS[chefe["tipo"]]["nome"], Vector2(LARG / 2, 162), 15, BRANCO)
	for t in textos:
		var cor: Color = t["cor"]
		cor.a = minf(1.0, t["vida"] * 2)
		escrever(t["txt"], t["p"], 19, cor)


func desenhar_loja() -> void:
	var b := botoes()
	var painel := Rect2(8, LOJA_Y, LARG - 16, ALT - LOJA_Y - 4)
	caixa(painel.grow(3), TINTA, 10)
	caixa(painel, MADEIRA, 8)
	caixa(painel.grow(-8), PAPEL, 6)
	botao(Rect2(LARG / 2 - 80, LOJA_Y - 14, 160, 36), "Loja", Color8(70, 60, 110), BRANCO)
	var ativa := estado == "loja"
	for i in 3:
		var r: Rect2 = b["loja%d" % i]
		caixa(r.grow(3), TINTA, 8)
		caixa(r, Color8(60, 44, 34), 6)
		var iid = loja[i]
		if iid == null:
			escrever("comprado", r.get_center(), 15, Color8(150, 130, 110), false)
			continue
		if selec == ["loja", i]:
			caixa(r.grow(3), Color.TRANSPARENT, 8, 4, OURO, false)
		escrever(ITENS[iid]["nome"], Vector2(r.get_center().x, r.position.y + 13), 14, BRANCO, false)
		var cx := r.get_center().x
		caixa(Rect2(cx - 30, r.position.y + 24, 60, 50), Color8(60, 140, 70), 6)
		icone(iid, Vector2(cx, r.position.y + 49), 0.8)
		var custo := preco(iid)
		var pode := essencia >= custo and ativa
		var yb := r.end.y
		draw_colored_polygon(PackedVector2Array([Vector2(cx - 22, yb - 22), Vector2(cx - 16, yb - 15), Vector2(cx - 22, yb - 8), Vector2(cx - 28, yb - 15)]), ROXO)
		draw_string(fonte, Vector2(cx - 10, yb - 8), str(custo), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, BRANCO if pode else Color8(200, 90, 90))
	var t_trocar := "Trocar grátis" if trocas_gratis > 0 else "Trocar (2)"
	botao(b["trocar"], t_trocar if ativa else "Trocar", Color8(60, 150, 210), BRANCO, ativa)
	botao(b["lixo"], "Lixo", Color8(170, 50, 50) if vender else Color8(110, 70, 60), BRANCO, ativa)
	botao(b["onda"], "Iniciar onda %d" % (onda + 1) if ativa else "Onda em andamento", Color8(230, 190, 60), TINTA, ativa)
	var dica := "Toque no item, depois no quadro"
	if estado == "onda":
		dica = "Monstros: %d  ·  na fila: %d" % [monstros.size(), fila.size()]
	elif not selec.is_empty() and selec[0] == "loja":
		dica = "Agora toque num quadro"
	escrever(dica, Vector2(LARG / 2, LOJA_Y + 36), 15, TINTA, false)
