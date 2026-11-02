"""Kravenox: Quadros do Cisma.

O Kravenox anda sem parar por um anel de quadros. Cada quadro pode guardar um
poder comprado na loja; quando ele pisa no quadro, o poder dispara. Os
monstros do Reino Quebrado chegam em ondas. Sobreviva às 15 ondas.

Como rodar:
    pip install pygame-ce
    python kravenox_quadros.py

Controles (mouse ou toque):
    - Toque num item da loja e depois num quadro para colocar.
    - Item igual e do mesmo nível no mesmo quadro: os dois se fundem (nível +1).
    - Toque num quadro com item para pegá-lo e levar para outro quadro.
    - Lixeira: toque nela e depois num quadro para vender o item.
    - "Iniciar onda" começa a onda. "x1/x2" muda a velocidade.
    - Tecla M liga e desliga a música e os efeitos.
"""
import math
import os
import random
import sys

import pygame

LARG, ALT = 480, 820
PASTA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")

# Cores (vermelho é do Kravenox, roxo é do Vazio)
FUNDO = (12, 10, 18)
FUNDO_ESC = (8, 6, 12)
PEDRA = (44, 40, 54)
PEDRA_CLARA = (70, 62, 86)
PEDRA_ESC = (22, 20, 28)
TINTA = (8, 6, 10)
BRANCO = (232, 226, 236)
CINZA = (150, 142, 160)
OURO = (214, 178, 106)
ROXO = (160, 100, 255)
VERMELHO = (214, 40, 44)
VERDE = (90, 200, 120)
MADEIRA = (30, 24, 38)
PAPEL = (14, 11, 18)

# ------------------------------------------------------------------ poderes
# Os nomes vêm dos poderes do Kravenox no jogo Cratera do Cisma.
ITENS = {
    "garras":      {"nome": "Garras",        "custo": 8,  "cor": (230, 70, 60),  "desc": "Golpe em volta"},
    "espinhos":    {"nome": "Espinhos",      "custo": 10, "cor": (40, 40, 50),   "desc": "8 espinhos"},
    "raio":        {"nome": "Raio Essência", "custo": 12, "cor": (170, 100, 255), "desc": "Raio em cadeia"},
    "esmagamento": {"nome": "Esmagamento",   "custo": 14, "cor": (150, 110, 70), "desc": "Área grande"},
    "rasgo":       {"nome": "Rasgo Abismo",  "custo": 12, "cor": (200, 30, 90),  "desc": "Atravessa"},
    "cristal":     {"nome": "Cristal Vida",  "custo": 9,  "cor": (90, 220, 160), "desc": "Cura"},
    "passo":       {"nome": "Passo Predador", "custo": 7, "cor": (80, 190, 90),  "desc": "Corre mais"},
    "fonte":       {"nome": "Fonte Essência", "custo": 10, "cor": (255, 210, 90), "desc": "+essência"},
}
NIVEL_MAX = 5

# ---------------------------------------------------------------- monstros
# Os monstros são os do livro e do gibi (universo/inimigos, biblia/personagens).
# As artes são recortes das pinturas conceituais e das estátuas 3D.
# "alt" é a altura na tela; "esq" diz que a pintura olha para a esquerda.
MONSTROS = {
    "larva":     {"nome": "Larva da Essência",   "hp": 22,   "vel": 34, "dano": 5,  "premio": 2,  "img": "larva", "alt": 44, "esq": True},
    "esfera":    {"nome": "Sentinela Esférica",  "hp": 14,   "vel": 70, "dano": 4,  "premio": 2,  "img": "esfera", "alt": 46},
    "verme":     {"nome": "Verme de Dentes",     "hp": 34,   "vel": 58, "dano": 7,  "premio": 3,  "img": "verme", "alt": 50, "esq": True},
    "sentinela": {"nome": "Sentinela do Vazio",  "hp": 55,   "vel": 30, "dano": 10, "premio": 4,  "img": "sentinela", "alt": 82},
    # chefes
    "larvamae":  {"nome": "Larva-Mãe",           "hp": 420,  "vel": 18, "dano": 20, "premio": 40, "img": "larva", "alt": 118, "esq": True, "chefe": True, "tinta": (255, 185, 240)},
    "semrosto":  {"nome": "Sentinela sem Rosto", "hp": 1100, "vel": 14, "dano": 28, "premio": 80, "img": "sentinela", "alt": 150, "chefe": True, "tinta": (205, 180, 255)},
    "thornox":   {"nome": "Thornox",             "hp": 2300, "vel": 16, "dano": 35, "premio": 0,  "img": "thornox", "alt": 130, "chefe": True},
}
FILHOTES = {"larvamae": "larva", "semrosto": "esfera", "thornox": "verme"}
TOTAL_ONDAS = 15
CHEFES = {5: "larvamae", 10: "semrosto", 15: "thornox"}

# ------------------------------------------------------------------ tabuleiro
TAM = 84
PASSO_GRADE = 94
OX = (LARG - 3 * PASSO_GRADE - TAM) // 2
OY = 200
# anel 4x4 (12 quadros) no sentido horário
ANEL = [(0, 0), (1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (3, 3), (2, 3), (1, 3), (0, 3), (0, 2), (0, 1)]
LOJA_Y = 600


def centro_quadro(i):
    gx, gy = ANEL[i]
    return OX + gx * PASSO_GRADE + TAM // 2, OY + gy * PASSO_GRADE + TAM // 2


def ret_quadro(i):
    gx, gy = ANEL[i]
    return pygame.Rect(OX + gx * PASSO_GRADE, OY + gy * PASSO_GRADE, TAM, TAM)


# ------------------------------------------------------------------ imagens
def carregar(nome):
    caminho = os.path.join(PASTA, "arte", nome + ".png")
    try:
        return pygame.image.load(caminho).convert_alpha()
    except (pygame.error, FileNotFoundError):
        s = pygame.Surface((40, 40), pygame.SRCALPHA)
        pygame.draw.circle(s, (60, 30, 80), (20, 20), 18)
        pygame.draw.circle(s, ROXO, (20, 18), 5)
        return s


def escalar(img, f):
    return pygame.transform.scale(img, (max(1, int(img.get_width() * f)), max(1, int(img.get_height() * f))))


def silhueta_branca(img):
    m = pygame.mask.from_surface(img)
    return m.to_surface(setcolor=(255, 255, 255, 255), unsetcolor=(0, 0, 0, 0))


# ------------------------------------------------------------------ jogo
class Jogo:
    def __init__(self):
        texto = os.path.join(PASTA, "fontes", "alegreya-sans-bold.ttf")
        titulo = os.path.join(PASTA, "fontes", "cinzel.ttf")
        self.fonte = pygame.font.Font(texto, 21)
        self.fonte_p = pygame.font.Font(texto, 16)
        self.fonte_g = pygame.font.Font(titulo, 30)
        self.fonte_n = pygame.font.Font(texto, 18)
        self.img = {}
        self.arte("kravenox", 94, tinta_borda=(214, 40, 44, 140))
        for tipo, m in MONSTROS.items():
            cor = (120, 160, 205, 190) if tipo == "thornox" else ((160, 100, 255, 190) if m.get("chefe") else (160, 100, 255, 130))
            self.arte(tipo, m["alt"], m["img"], m.get("tinta"), cor, m.get("esq", False))
        self.chao = self.gerar_chao()
        self.preparar_som()
        self.novo_jogo()

    # ------------------------------------------------------------ som
    # Trilhas do RPG 2D (kravenox-jogar/rpg/music) e efeitos do Cratera do Cisma.
    def preparar_som(self):
        self.som_ligado = True
        self.faixa = ""
        self.efeitos_som = {}
        self.ultimo_som = {}
        try:
            for n in ["acerto", "corte", "raio", "esmagamento", "dano", "gema", "chefe", "nivel", "thornox"]:
                self.efeitos_som[n] = pygame.mixer.Sound(os.path.join(PASTA, "sons", n + ".wav"))
                self.efeitos_som[n].set_volume(0.35)
            pygame.mixer.music.set_volume(0.45)
            self.tem_som = True
        except (pygame.error, FileNotFoundError):
            self.tem_som = False

    def musica_certa(self):
        if self.estado == "onda":
            if self.onda == TOTAL_ONDAS:
                return "espinhos"
            return "chefe" if self.onda in CHEFES else "batalha"
        return {"vitoria": "vitoria", "derrota": "gameover"}.get(self.estado, "abismo")

    def tocar_musica(self, nome):
        if not self.tem_som or nome == self.faixa:
            return
        self.faixa = nome
        if not self.som_ligado:
            return
        try:
            pygame.mixer.music.load(os.path.join(PASTA, "musica", nome + ".ogg"))
            pygame.mixer.music.play(-1 if nome in ("abismo", "batalha", "chefe", "espinhos") else 0)
        except pygame.error:
            pass

    def ligar_som(self, sim):
        self.som_ligado = sim
        if not self.tem_som:
            return
        if sim:
            self.faixa = ""
            self.tocar_musica(self.musica_certa())
        else:
            pygame.mixer.music.stop()

    def som(self, nome):
        if not self.tem_som or not self.som_ligado:
            return
        agora = pygame.time.get_ticks()
        if agora - self.ultimo_som.get(nome, -1000) < 70:
            return
        self.ultimo_som[nome] = agora
        self.efeitos_som[nome].play()

    def arte(self, chave, alt, nome=None, tinta=None, tinta_borda=(160, 100, 255, 130), olha_esq=False):
        """Guarda (normal, virada, branca, contorno) de uma arte já na altura da tela.
        A versão normal sempre olha para a direita."""
        im = carregar(nome or chave)
        im = pygame.transform.smoothscale(im, (max(1, int(im.get_width() * alt / im.get_height())), int(alt)))
        if tinta:
            im = im.copy()
            im.fill((*tinta, 255), special_flags=pygame.BLEND_RGBA_MULT)
        if olha_esq:
            im = pygame.transform.flip(im, True, False)
        borda = pygame.mask.from_surface(im).to_surface(setcolor=tinta_borda, unsetcolor=(0, 0, 0, 0))
        self.img[chave] = (im, pygame.transform.flip(im, True, False), silhueta_branca(im), borda)

    def gerar_chao(self):
        try:
            fundo = pygame.image.load(os.path.join(PASTA, "arte", "cratera.png")).convert()
            fundo = pygame.transform.smoothscale(fundo, (LARG, ALT))
        except (pygame.error, FileNotFoundError):
            fundo = pygame.Surface((LARG, ALT))
            fundo.fill(FUNDO)
        veu = pygame.Surface((LARG, ALT), pygame.SRCALPHA)
        veu.fill((6, 4, 12, 110))
        fundo.blit(veu, (0, 0))
        return fundo

    def blit_arte(self, tela, chave, midbottom, virar, branco=False):
        im, im_v, br, borda = self.img[chave]
        img = im_v if virar else im
        if branco:
            img = pygame.transform.flip(br, True, False) if virar else br
        b = pygame.transform.flip(borda, True, False) if virar else borda
        r = img.get_rect(midbottom=midbottom)
        for dx, dy in ((-2, 0), (2, 0), (0, -2), (0, 2)):
            tela.blit(b, r.move(dx, dy))
        tela.blit(img, r)
        return r

    def novo_jogo(self):
        self.onda = 0
        self.essencia = 25
        self.hp_max = 150
        self.hp = 150
        self.quadros = [None] * 12   # cada um: {"id":..., "nv":...}
        self.k_pos = 0.0             # posição no anel (0..12)
        self.k_vel = 1.4             # quadros por segundo
        self.k_rapido = 0.0
        self.k_ultimo = 0
        self.k_dir = 1
        self.k_anim = 0.0
        self.k_flash = 0.0
        self.monstros = []
        self.tiros = []
        self.efeitos = []
        self.textos = []
        self.fila = []
        self.t_spawn = 0
        self.estado = "loja"        # loja / onda / derrota / vitoria
        self.selec = None            # ("loja", i) ou ("quadro", i)
        self.vender = False
        self.vel_jogo = 1
        self.trocas_gratis = 1
        self.brilho = [0.0] * 12
        self.mortes = 0
        self.msg = "Compre um poder e toque num quadro"
        self.msg_t = 6
        self.loja = []
        self.sortear_loja()

    # ------------------------------------------------------------ loja
    def sortear_loja(self):
        ids = list(ITENS)
        self.loja = [random.choice(ids) for _ in range(3)]

    def preco(self, item_id):
        return ITENS[item_id]["custo"] + self.onda // 3

    def valor_venda(self, q):
        return (ITENS[q["id"]]["custo"] * (2 ** (q["nv"] - 1))) // 2

    def colocar(self, i, item):
        q = self.quadros[i]
        if q is None:
            self.quadros[i] = item
            return True
        if q["id"] == item["id"] and q["nv"] == item["nv"] and q["nv"] < NIVEL_MAX:
            q["nv"] += 1
            self.som("nivel")
            self.efeitos.append(["anel", *centro_quadro(i), 10, 60, 0.4, OURO])
            self.aviso("Fundiu! " + ITENS[q["id"]]["nome"] + " nível " + str(q["nv"]))
            return True
        return False

    def aviso(self, txt, t=2.5):
        self.msg, self.msg_t = txt, t

    # ------------------------------------------------------------ ondas
    def iniciar_onda(self):
        if all(q is None for q in self.quadros):
            self.aviso("Coloque pelo menos um poder num quadro!")
            return
        self.onda += 1
        self.estado = "onda"
        self.selec = None
        self.vender = False
        w = self.onda
        tipos = ["larva"] * 5
        if w >= 2:
            tipos += ["esfera"] * 3
        if w >= 3:
            tipos += ["verme"] * 2
        if w >= 5:
            tipos += ["sentinela"] * 2
        if w >= 8:
            tipos += ["verme", "sentinela", "sentinela"]
        n = 6 + w * 2
        self.fila = [random.choice(tipos) for _ in range(n)]
        if w in CHEFES:
            self.fila.insert(3, CHEFES[w])
            self.aviso("Chefe: " + MONSTROS[CHEFES[w]]["nome"] + "!", 3)
        else:
            self.aviso("Onda " + str(w), 1.5)
        self.t_spawn = 0.8
        self.t_onda = 0.0   # depois de 20 s de onda os monstros ficam mais rápidos
        self.gap = max(0.35, 1.3 - w * 0.06)

    def criar_monstro(self, tipo, x=None, y=None):
        m = MONSTROS[tipo]
        if x is None:
            lado = random.choice(["esq", "dir", "cima"])
            if lado == "esq":
                x, y = -40, random.uniform(80, LOJA_Y - 40)
            elif lado == "dir":
                x, y = LARG + 40, random.uniform(80, LOJA_Y - 40)
            else:
                x, y = random.uniform(0, LARG), -40
        esc = 1 + 0.18 * (self.onda - 1)
        hp = m["hp"] * (esc if not m.get("chefe") else 1 + 0.1 * (self.onda - 1))
        if m.get("chefe"):
            self.som("thornox" if tipo == "thornox" else "chefe")
        self.monstros.append({"tipo": tipo, "x": x, "y": y, "hp": hp, "hp_max": hp,
                              "vel": m["vel"], "dano": m["dano"] * 0.7 * (1 + 0.05 * self.onda),
                              "premio": m["premio"], "t_ataque": 0, "flash": 0, "anim": random.random() * 2,
                              "chefe": m.get("chefe", False), "t_poder": 4.0})

    # ------------------------------------------------------------ Kravenox
    def pos_kravenox(self):
        a = int(self.k_pos) % 12
        b = (a + 1) % 12
        f = self.k_pos - int(self.k_pos)
        ax, ay = centro_quadro(a)
        bx, by = centro_quadro(b)
        return ax + (bx - ax) * f, ay + (by - ay) * f - 18

    def ativar(self, i):
        q = self.quadros[i]
        self.brilho[i] = 0.35
        # mordida básica: sempre acerta quem está colado nele (evita empate eterno)
        bx, by = self.pos_kravenox()
        for m in self.monstros:
            if math.hypot(m["x"] - bx, m["y"] - by) < 60:
                self.ferir(m, 5 + self.onda)
        if not q:
            return
        nv = q["nv"]
        mult = 1 + 0.8 * (nv - 1)
        kx, ky = self.pos_kravenox()
        cor = ITENS[q["id"]]["cor"]
        iid = q["id"]
        if iid == "garras":
            self.som("corte")
            r = 95 + nv * 8
            self.efeitos.append(["garra", kx, ky, r, 0.25])
            for m in self.monstros:
                if math.hypot(m["x"] - kx, m["y"] - ky) < r:
                    self.ferir(m, 12 * mult)
        elif iid == "espinhos":
            self.som("corte")
            n = 8 + (nv - 1) * 2
            for k in range(n):
                a = k / n * math.tau
                self.tiros.append({"x": kx, "y": ky, "vx": math.cos(a) * 330, "vy": math.sin(a) * 330,
                                   "dano": 9 * mult, "fura": 0, "vida": 1.0, "cor": (30, 30, 40), "r": 5, "acertos": set()})
        elif iid == "raio":
            self.som("raio")
            alvos = sorted(self.monstros, key=lambda m: math.hypot(m["x"] - kx, m["y"] - ky))[:2 + nv]
            px, py = kx, ky
            for m in alvos:
                self.efeitos.append(["raio", px, py, m["x"], m["y"], 0.2])
                self.ferir(m, 15 * mult)
                px, py = m["x"], m["y"]
        elif iid == "esmagamento":
            self.som("esmagamento")
            r = 150 + nv * 12
            self.efeitos.append(["anel", kx, ky + 18, 20, r, 0.35, (200, 150, 90)])
            for m in self.monstros:
                if math.hypot(m["x"] - kx, m["y"] - ky) < r:
                    self.ferir(m, 16 * mult)
        elif iid == "rasgo":
            self.som("corte")
            alvo = self.mais_perto(kx, ky)
            a = math.atan2(alvo["y"] - ky, alvo["x"] - kx) if alvo else random.uniform(0, math.tau)
            for d in ([0] if nv < 3 else [-0.2, 0.2]) if nv < 5 else [-0.3, 0, 0.3]:
                self.tiros.append({"x": kx, "y": ky, "vx": math.cos(a + d) * 480, "vy": math.sin(a + d) * 480,
                                   "dano": 24 * mult, "fura": 99, "vida": 1.4, "cor": (220, 30, 90), "r": 9, "acertos": set()})
        elif iid == "cristal":
            self.som("gema")
            cura = 4 + 3 * nv
            self.hp = min(self.hp_max, self.hp + cura)
            self.texto(kx, ky - 40, "+" + str(cura), (90, 220, 160))
            self.efeitos.append(["anel", kx, ky, 10, 50, 0.3, (90, 220, 160)])
        elif iid == "passo":
            self.k_rapido = 1.6 + 0.5 * nv
            self.efeitos.append(["anel", kx, ky + 18, 10, 40, 0.25, VERDE])
        elif iid == "fonte":
            self.som("gema")
            ganho = nv
            self.essencia += ganho
            self.texto(kx, ky - 40, "+" + str(ganho), OURO)
        self.efeitos.append(["anel", *centro_quadro(i), 20, 50, 0.25, cor])

    def mais_perto(self, x, y):
        if not self.monstros:
            return None
        return min(self.monstros, key=lambda m: math.hypot(m["x"] - x, m["y"] - y))

    def texto(self, x, y, txt, cor):
        self.textos.append([x, y, txt, cor, 0.8])

    def ferir(self, m, dano):
        if m["hp"] <= 0:
            return
        m["hp"] -= dano
        m["flash"] = 0.1
        self.texto(m["x"] + random.uniform(-8, 8), m["y"] - 30, str(int(dano)), BRANCO)
        if m["hp"] <= 0:
            self.som("acerto")
            self.mortes += 1
            self.essencia += m["premio"]
            for _ in range(10 if not m["chefe"] else 40):
                a = random.uniform(0, math.tau)
                v = random.uniform(40, 160)
                self.efeitos.append(["part", m["x"], m["y"], math.cos(a) * v, math.sin(a) * v, 0.6, ROXO])
            if m["premio"]:
                self.texto(m["x"], m["y"] - 10, "+" + str(m["premio"]), OURO)

    # ------------------------------------------------------------ atualizar
    def atualizar(self, dt):
        dt *= self.vel_jogo
        self.msg_t -= dt
        for i in range(12):
            self.brilho[i] = max(0, self.brilho[i] - dt)
        self.efeitos = [e for e in self.efeitos if self.passo_efeito(e, dt)]
        for t in self.textos:
            t[1] -= 40 * dt
            t[4] -= dt
        self.textos = [t for t in self.textos if t[4] > 0]
        if self.estado != "onda":
            return

        # Kravenox anda sem parar
        vel = self.k_vel * (1.7 if self.k_rapido > 0 else 1)
        self.k_rapido = max(0, self.k_rapido - dt)
        antes = self.pos_kravenox()[0]
        self.k_pos = (self.k_pos + vel * dt) % 12
        self.k_anim += dt * vel * 6
        self.k_flash = max(0, self.k_flash - dt)
        depois = self.pos_kravenox()[0]
        if abs(depois - antes) > 0.01:
            self.k_dir = 1 if depois > antes else -1
        atual = int(self.k_pos + 0.5) % 12   # quadro em que ele está pisando
        if atual != self.k_ultimo:
            self.k_ultimo = atual
            self.ativar(atual)

        # ondas
        if self.fila:
            self.t_spawn -= dt
            if self.t_spawn <= 0:
                self.criar_monstro(self.fila.pop(0))
                self.t_spawn = self.gap * random.uniform(0.6, 1.3)

        self.t_onda += dt
        pressa = 1 + max(0, self.t_onda - 20) * 0.05
        kx, ky = self.pos_kravenox()
        for m in self.monstros:
            m["anim"] += dt
            m["flash"] -= dt
            dx, dy = kx - m["x"], ky - m["y"]
            d = math.hypot(dx, dy) or 1
            alcance = 34 if not m["chefe"] else 70
            if d > alcance:
                m["x"] += dx / d * m["vel"] * pressa * dt
                m["y"] += dy / d * m["vel"] * pressa * dt
            else:
                m["t_ataque"] -= dt
                if m["t_ataque"] <= 0:
                    m["t_ataque"] = 1.0
                    self.hp -= m["dano"]
                    self.som("dano")
                    self.k_flash = 0.15
                    self.texto(kx, ky - 50, "-" + str(int(m["dano"])), VERMELHO)
            if m["chefe"]:
                m["t_poder"] -= dt
                if m["t_poder"] <= 0:
                    m["t_poder"] = 5.0
                    filhote = FILHOTES[m["tipo"]]
                    for _ in range(2):
                        self.criar_monstro(filhote, m["x"] + random.uniform(-40, 40), m["y"] + random.uniform(-40, 40))

        for t in self.tiros:
            t["x"] += t["vx"] * dt
            t["y"] += t["vy"] * dt
            t["vida"] -= dt
            for m in self.monstros:
                if id(m) in t["acertos"] or m["hp"] <= 0:
                    continue
                raio = 18 if not m["chefe"] else 50
                if math.hypot(m["x"] - t["x"], m["y"] - t["y"]) < raio + t["r"]:
                    self.ferir(m, t["dano"])
                    t["acertos"].add(id(m))
                    if t["fura"] <= 0:
                        t["vida"] = 0
                        break
                    t["fura"] -= 1
        self.tiros = [t for t in self.tiros if t["vida"] > 0]
        self.monstros = [m for m in self.monstros if m["hp"] > 0]

        if self.hp <= 0:
            self.hp = 0
            self.estado = "derrota"
        elif not self.fila and not self.monstros:
            if self.onda >= TOTAL_ONDAS:
                self.estado = "vitoria"
            else:
                self.estado = "loja"
                self.essencia += 5 + self.onda
                self.hp = min(self.hp_max, self.hp + 30)
                self.trocas_gratis = 1
                self.sortear_loja()
                self.tiros.clear()
                self.aviso("Onda vencida! +" + str(5 + self.onda) + " de essência, +30 vida", 3)

    def passo_efeito(self, e, dt):
        tipo = e[0]
        if tipo == "part":
            e[1] += e[3] * dt
            e[2] += e[4] * dt
            e[5] -= dt
            return e[5] > 0
        if tipo == "anel":
            e[5] -= dt
            return e[5] > 0
        if tipo in ("garra",):
            e[4] -= dt
            return e[4] > 0
        if tipo == "raio":
            e[5] -= dt
            return e[5] > 0
        return False

    # ------------------------------------------------------------ toque
    def botoes(self):
        b = {}
        y = LOJA_Y + 18
        for i in range(3):
            b["loja%d" % i] = pygame.Rect(26 + i * 148, y + 34, 132, 104)
        b["trocar"] = pygame.Rect(24, ALT - 62, 130, 46)
        b["lixo"] = pygame.Rect(170, ALT - 62, 60, 46)
        b["onda"] = pygame.Rect(246, ALT - 62, 210, 46)
        b["vel"] = pygame.Rect(LARG - 78, 92, 62, 36)
        b["denovo"] = pygame.Rect(LARG // 2 - 110, ALT // 2 + 40, 220, 56)
        return b

    def clique(self, pos):
        b = self.botoes()
        if self.estado in ("derrota", "vitoria"):
            if b["denovo"].collidepoint(pos):
                self.novo_jogo()
            return
        if b["vel"].collidepoint(pos):
            self.vel_jogo = 2 if self.vel_jogo == 1 else 1
            return
        if self.estado != "loja":
            return
        for i in range(3):
            if b["loja%d" % i].collidepoint(pos) and self.loja[i]:
                if self.essencia < self.preco(self.loja[i]):
                    self.aviso("Essência insuficiente")
                    return
                self.vender = False
                self.selec = None if self.selec == ("loja", i) else ("loja", i)
                return
        if b["trocar"].collidepoint(pos):
            custo = 0 if self.trocas_gratis else 2
            if self.essencia >= custo:
                self.essencia -= custo
                self.trocas_gratis = 0
                self.sortear_loja()
                self.selec = None
            else:
                self.aviso("Essência insuficiente")
            return
        if b["lixo"].collidepoint(pos):
            self.vender = not self.vender
            self.selec = None
            self.aviso("Toque num quadro para vender" if self.vender else "", 2)
            return
        if b["onda"].collidepoint(pos):
            self.iniciar_onda()
            return
        for i in range(12):
            if ret_quadro(i).collidepoint(pos):
                self.clique_quadro(i)
                return
        self.selec = None

    def clique_quadro(self, i):
        q = self.quadros[i]
        if self.vender:
            if q:
                v = self.valor_venda(q)
                self.essencia += v
                self.quadros[i] = None
                self.aviso("Vendido por " + str(v))
            self.vender = False
            return
        if self.selec and self.selec[0] == "loja":
            li = self.selec[1]
            iid = self.loja[li]
            preco = self.preco(iid)
            if self.essencia >= preco and self.colocar(i, {"id": iid, "nv": 1}):
                self.essencia -= preco
                self.loja[li] = None
            elif self.essencia >= preco:
                self.aviso("Quadro ocupado (só funde item igual e de mesmo nível)")
            self.selec = None
            return
        if self.selec and self.selec[0] == "quadro":
            de = self.selec[1]
            self.selec = None
            if de == i:
                return
            item = self.quadros[de]
            if q is None:
                self.quadros[i], self.quadros[de] = item, None
            elif self.colocar(i, dict(item)):
                self.quadros[de] = None
            else:
                self.quadros[i], self.quadros[de] = item, q   # troca de lugar
            return
        if q:
            self.selec = ("quadro", i)

    # ------------------------------------------------------------ desenho
    def desenhar(self, tela):
        tela.blit(self.chao, (0, 0))
        self.desenhar_topo(tela)
        for i in range(12):
            self.desenhar_quadro(tela, i)
        self.desenhar_mundo(tela)
        self.desenhar_loja(tela)
        if self.msg_t > 0 and self.msg:
            s = self.fonte.render(self.msg, True, BRANCO)
            r = s.get_rect(center=(LARG // 2, 172))
            fundo = r.inflate(18, 10)
            pygame.draw.rect(tela, TINTA, fundo, border_radius=8)
            tela.blit(s, r)
        if self.estado in ("derrota", "vitoria"):
            v = pygame.Surface((LARG, ALT), pygame.SRCALPHA)
            v.fill((10, 5, 10, 200))
            tela.blit(v, (0, 0))
            t1 = "O Kravenox caiu" if self.estado == "derrota" else "O Reino é do Kravenox"
            t2 = ("Chegou à onda %d de %d" % (self.onda, TOTAL_ONDAS)) if self.estado == "derrota" else "As 15 ondas foram vencidas"
            s = self.fonte_g.render(t1, True, VERMELHO if self.estado == "derrota" else OURO)
            tela.blit(s, s.get_rect(center=(LARG // 2, ALT // 2 - 60)))
            s = self.fonte.render(t2 + "  ·  %d monstros" % self.mortes, True, BRANCO)
            tela.blit(s, s.get_rect(center=(LARG // 2, ALT // 2 - 15)))
            self.botao(tela, self.botoes()["denovo"], "Jogar de novo", OURO, TINTA)

    def desenhar_topo(self, tela):
        s = self.fonte.render("Capítulo 1 - Reino Quebrado", True, BRANCO)
        tela.blit(s, (16, 14))
        s = self.fonte.render("Onda %d/%d" % (self.onda, TOTAL_ONDAS), True, BRANCO)
        tela.blit(s, (LARG - s.get_width() - 16, 14))
        # trilha de ondas
        y = 54
        x0, x1 = 30, LARG - 30
        pygame.draw.line(tela, TINTA, (x0, y), (x1, y), 8)
        for w in range(1, TOTAL_ONDAS + 1):
            x = x0 + (x1 - x0) * (w - 1) / (TOTAL_ONDAS - 1)
            feita = w <= self.onda
            cor = VERMELHO if w == self.onda and self.estado == "onda" else ((150, 40, 40) if feita else PEDRA_ESC)
            r = 12 if w in CHEFES else 9
            pygame.draw.circle(tela, TINTA, (int(x), y), r + 2)
            pygame.draw.circle(tela, cor if w not in CHEFES or feita else (90, 50, 120), (int(x), y), r)
            if w in CHEFES:
                c = self.fonte_p.render("C", True, BRANCO)
                tela.blit(c, c.get_rect(center=(int(x), y)))
        # essência e vida
        pygame.draw.rect(tela, TINTA, (16, 86, 150, 38), border_radius=10)
        pygame.draw.polygon(tela, ROXO, [(36, 93), (46, 105), (36, 117), (26, 105)])
        s = self.fonte.render(str(self.essencia), True, BRANCO)
        tela.blit(s, (56, 95))
        bw = 180
        pygame.draw.rect(tela, TINTA, (LARG // 2 - bw // 2 - 3 + 20, 92, bw + 6, 26), border_radius=8)
        fr = max(0, self.hp / self.hp_max)
        pygame.draw.rect(tela, VERMELHO, (LARG // 2 - bw // 2 + 20, 95, int(bw * fr), 20), border_radius=6)
        s = self.fonte_p.render("Vida %d/%d" % (max(0, self.hp), self.hp_max), True, BRANCO)
        tela.blit(s, s.get_rect(center=(LARG // 2 + 20, 105)))
        self.botao(tela, self.botoes()["vel"], "x%d" % self.vel_jogo, MADEIRA, OURO)

    def desenhar_quadro(self, tela, i):
        r = ret_quadro(i)
        sel = self.selec == ("quadro", i)
        pygame.draw.rect(tela, TINTA, r.inflate(6, 6), border_radius=8)
        cor = PEDRA_CLARA if self.brilho[i] > 0 else PEDRA
        pygame.draw.rect(tela, cor, r, border_radius=6)
        pygame.draw.rect(tela, PEDRA_ESC, r.inflate(-12, -12), border_radius=4)
        pygame.draw.rect(tela, (78, 78, 84), r.inflate(-16, -16), border_radius=4)
        if sel or (self.vender and self.quadros[i]):
            pygame.draw.rect(tela, OURO if sel else VERMELHO, r.inflate(4, 4), 4, border_radius=8)
        q = self.quadros[i]
        if q is None:
            c = r.center
            pygame.draw.line(tela, (120, 120, 126), (c[0] - 14, c[1]), (c[0] + 14, c[1]), 6)
            pygame.draw.line(tela, (120, 120, 126), (c[0], c[1] - 14), (c[0], c[1] + 14), 6)
        else:
            self.icone(tela, q["id"], r.centerx, r.centery, 1.0)
            pygame.draw.rect(tela, VERDE, (r.x + 4, r.y + 4, 22, 22), border_radius=4)
            s = self.fonte_n.render(str(q["nv"]), True, TINTA)
            tela.blit(s, s.get_rect(center=(r.x + 15, r.y + 15)))

    def icone(self, tela, iid, x, y, e):
        cor = ITENS[iid]["cor"]
        def P(px, py):
            return (int(x + px * e), int(y + py * e))
        if iid == "garras":
            for k in (-12, 0, 12):
                pygame.draw.polygon(tela, TINTA, [P(k - 6, 18), P(k + 6, 18), P(k + 8, -20)])
                pygame.draw.polygon(tela, cor, [P(k - 3, 14), P(k + 3, 14), P(k + 6, -16)])
        elif iid == "espinhos":
            for k in range(8):
                a = k / 8 * math.tau
                pygame.draw.line(tela, TINTA, P(0, 0), P(math.cos(a) * 24, math.sin(a) * 24), 5)
            pygame.draw.circle(tela, (30, 30, 40), P(0, 0), int(11 * e))
            pygame.draw.circle(tela, VERMELHO, P(0, 0), int(4 * e))
        elif iid == "raio":
            pts = [P(-6, -24), P(8, -4), P(-2, -2), P(8, 24), P(-10, 0), P(0, -2)]
            pygame.draw.polygon(tela, TINTA, pts, 0)
            pygame.draw.polygon(tela, cor, pts, 3)
        elif iid == "esmagamento":
            pygame.draw.rect(tela, TINTA, (*P(-18, -10), int(36 * e), int(24 * e)), border_radius=6)
            pygame.draw.rect(tela, cor, (*P(-15, -7), int(30 * e), int(18 * e)), border_radius=4)
            pygame.draw.line(tela, TINTA, P(-22, 20), P(22, 20), 4)
        elif iid == "rasgo":
            pygame.draw.ellipse(tela, TINTA, (*P(-10, -24), int(20 * e), int(48 * e)))
            pygame.draw.ellipse(tela, cor, (*P(-5, -20), int(10 * e), int(40 * e)))
        elif iid == "cristal":
            pts = [P(0, -24), P(14, -4), P(0, 24), P(-14, -4)]
            pygame.draw.polygon(tela, cor, pts)
            pygame.draw.polygon(tela, TINTA, pts, 3)
        elif iid == "passo":
            for k in (-10, 6):
                pygame.draw.polygon(tela, cor, [P(k - 10, -16), P(k + 8, 0), P(k - 10, 16), P(k - 4, 0)])
                pygame.draw.polygon(tela, TINTA, [P(k - 10, -16), P(k + 8, 0), P(k - 10, 16), P(k - 4, 0)], 2)
        elif iid == "fonte":
            pts = [P(0, -20), P(16, 0), P(0, 20), P(-16, 0)]
            pygame.draw.polygon(tela, ROXO, pts)
            pygame.draw.polygon(tela, cor, pts, 3)

    def desenhar_mundo(self, tela):
        itens = []
        for m in self.monstros:
            itens.append((m["y"], "m", m))
        kx, ky = self.pos_kravenox()
        itens.append((ky, "k", None))
        itens.sort(key=lambda t: t[0])
        for _, tipo, m in itens:
            if tipo == "k":
                pulo = abs(math.sin(self.k_anim * 1.6)) * 4 if self.estado == "onda" else 0
                if self.k_rapido > 0:
                    pygame.draw.ellipse(tela, VERDE, (kx - 32, ky + 20, 64, 16), 2)
                pygame.draw.ellipse(tela, (0, 0, 0), (kx - 28, ky + 23, 56, 12))
                self.blit_arte(tela, "kravenox", (kx, ky + 30 - pulo), self.k_dir < 0)
                if self.k_flash > 0:
                    pygame.draw.circle(tela, VERMELHO, (int(kx), int(ky)), 36, 3)
            else:
                alt = MONSTROS[m["tipo"]]["alt"]
                virar = m["x"] > kx   # todas as artes guardadas olham para a direita
                sobe = abs(math.sin(m["anim"] * 4)) * 3
                largura = self.img[m["tipo"]][0].get_width()
                pygame.draw.ellipse(tela, (0, 0, 0), (m["x"] - largura * 0.35, m["y"] + alt * 0.33, largura * 0.7, 10))
                rr = self.blit_arte(tela, m["tipo"], (m["x"], m["y"] + alt * 0.4 - sobe), virar, m["flash"] > 0)
                if m["hp"] < m["hp_max"] and not m["chefe"]:
                    w = 34
                    pygame.draw.rect(tela, TINTA, (m["x"] - w / 2 - 1, rr.top - 8, w + 2, 6))
                    pygame.draw.rect(tela, VERMELHO, (m["x"] - w / 2, rr.top - 7, w * m["hp"] / m["hp_max"], 4))
        for t in self.tiros:
            pygame.draw.circle(tela, TINTA, (int(t["x"]), int(t["y"])), t["r"] + 2)
            pygame.draw.circle(tela, t["cor"], (int(t["x"]), int(t["y"])), t["r"])
        for e in self.efeitos:
            if e[0] == "part":
                pygame.draw.circle(tela, e[6], (int(e[1]), int(e[2])), 3)
            elif e[0] == "anel":
                _, x, y, r0, r1, vida, cor = e
                f = 1 - vida / 0.4
                pygame.draw.circle(tela, cor, (int(x), int(y)), int(r0 + (r1 - r0) * max(0, min(1, f))), 3)
            elif e[0] == "garra":
                _, x, y, r, vida = e
                for k in (-0.4, 0, 0.4):
                    a0 = (1 - vida / 0.25) * math.tau + k
                    pygame.draw.arc(tela, (255, 90, 70), (x - r, y - r, 2 * r, 2 * r), a0, a0 + 0.9, 4)
            elif e[0] == "raio":
                _, x0, y0, x1, y1, vida = e
                pts = [(x0, y0)]
                for k in range(1, 6):
                    f = k / 6
                    pts.append((x0 + (x1 - x0) * f + random.uniform(-8, 8), y0 + (y1 - y0) * f + random.uniform(-8, 8)))
                pts.append((x1, y1))
                pygame.draw.lines(tela, (230, 200, 255), False, pts, 3)
                pygame.draw.lines(tela, ROXO, False, pts, 1)
        chefe = next((m for m in self.monstros if m["chefe"]), None)
        if chefe:
            w = LARG - 60
            pygame.draw.rect(tela, TINTA, (27, 137, w + 6, 16))
            pygame.draw.rect(tela, (150, 40, 160), (30, 140, w * chefe["hp"] / chefe["hp_max"], 10))
            s = self.fonte_p.render(MONSTROS[chefe["tipo"]]["nome"], True, BRANCO)
            tela.blit(s, s.get_rect(center=(LARG // 2, 162)))
        for x, y, txt, cor, vida in self.textos:
            s = self.fonte.render(txt, True, cor)
            s.set_alpha(int(255 * min(1, vida * 2)))
            sombra = self.fonte.render(txt, True, TINTA)
            tela.blit(sombra, sombra.get_rect(center=(x + 1, y + 2)))
            tela.blit(s, s.get_rect(center=(x, y)))

    def botao(self, tela, r, txt, cor, cor_txt, ativo=True):
        pygame.draw.rect(tela, TINTA, r.inflate(6, 6), border_radius=10)
        pygame.draw.rect(tela, cor if ativo else PEDRA_ESC, r, border_radius=8)
        s = self.fonte.render(txt, True, cor_txt if ativo else (120, 120, 120))
        tela.blit(s, s.get_rect(center=r.center))

    def desenhar_loja(self, tela):
        b = self.botoes()
        painel = pygame.Rect(8, LOJA_Y, LARG - 16, ALT - LOJA_Y - 4)
        pygame.draw.rect(tela, TINTA, painel.inflate(6, 6), border_radius=10)
        pygame.draw.rect(tela, MADEIRA, painel, border_radius=8)
        pygame.draw.rect(tela, PAPEL, painel.inflate(-16, -16), border_radius=6)
        titulo = pygame.Rect(LARG // 2 - 80, LOJA_Y - 14, 160, 36)
        self.botao(tela, titulo, "Loja", (70, 60, 110), BRANCO)
        loja_ativa = self.estado == "loja"
        for i in range(3):
            r = b["loja%d" % i]
            iid = self.loja[i]
            pygame.draw.rect(tela, TINTA, r.inflate(6, 6), border_radius=8)
            pygame.draw.rect(tela, (60, 44, 34), r, border_radius=6)
            if not iid:
                s = self.fonte_p.render("comprado", True, (150, 130, 110))
                tela.blit(s, s.get_rect(center=r.center))
                continue
            sel = self.selec == ("loja", i)
            if sel:
                pygame.draw.rect(tela, OURO, r.inflate(6, 6), 4, border_radius=8)
            s = self.fonte_p.render(ITENS[iid]["nome"], True, BRANCO)
            tela.blit(s, s.get_rect(center=(r.centerx, r.y + 12)))
            caixa = pygame.Rect(r.centerx - 30, r.y + 24, 60, 50)
            pygame.draw.rect(tela, (60, 140, 70), caixa, border_radius=6)
            self.icone(tela, iid, caixa.centerx, caixa.centery, 0.8)
            preco = self.preco(iid)
            pode = self.essencia >= preco and loja_ativa
            pygame.draw.polygon(tela, ROXO, [(r.centerx - 22, r.bottom - 22), (r.centerx - 16, r.bottom - 15), (r.centerx - 22, r.bottom - 8), (r.centerx - 28, r.bottom - 15)])
            s = self.fonte.render(str(preco), True, BRANCO if pode else (200, 90, 90))
            tela.blit(s, (r.centerx - 10, r.bottom - 24))
        if loja_ativa:
            self.botao(tela, b["trocar"], "Trocar" + ("" if not self.trocas_gratis else " grátis") if self.trocas_gratis else "Trocar (2)", (60, 150, 210), BRANCO)
        else:
            self.botao(tela, b["trocar"], "Trocar", (60, 150, 210), BRANCO, False)
        self.botao(tela, b["lixo"], "Lixo", (170, 50, 50) if self.vender else (110, 70, 60), BRANCO, loja_ativa)
        txt = "Iniciar onda %d" % (self.onda + 1) if loja_ativa else "Onda em andamento"
        self.botao(tela, b["onda"], txt, (230, 190, 60), TINTA, loja_ativa)
        if self.estado == "onda":
            s = self.fonte_p.render("Monstros: %d  ·  na fila: %d" % (len(self.monstros), len(self.fila)), True, CINZA)
            tela.blit(s, s.get_rect(center=(LARG // 2, LOJA_Y + 30)))
        elif self.selec and self.selec[0] == "loja":
            s = self.fonte_p.render("Agora toque num quadro", True, CINZA)
            tela.blit(s, s.get_rect(center=(LARG // 2, LOJA_Y + 30)))
        else:
            s = self.fonte_p.render("Toque no item, depois no quadro", True, CINZA)
            tela.blit(s, s.get_rect(center=(LARG // 2, LOJA_Y + 30)))


def main():
    pygame.init()
    tela = pygame.display.set_mode((LARG, ALT), pygame.SCALED | pygame.RESIZABLE)
    pygame.display.set_caption("Kravenox: Quadros do Cisma")
    relogio = pygame.time.Clock()
    jogo = Jogo()
    while True:
        dt = min(0.05, relogio.tick(60) / 1000)
        for ev in pygame.event.get():
            if ev.type == pygame.QUIT or (ev.type == pygame.KEYDOWN and ev.key == pygame.K_ESCAPE):
                pygame.quit()
                sys.exit()
            if ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
                jogo.clique(ev.pos)
            if ev.type == pygame.KEYDOWN and ev.key == pygame.K_SPACE and jogo.estado == "loja":
                jogo.iniciar_onda()
            if ev.type == pygame.KEYDOWN and ev.key == pygame.K_m:
                jogo.ligar_som(not jogo.som_ligado)
        jogo.atualizar(dt)
        jogo.tocar_musica(jogo.musica_certa())
        jogo.desenhar(tela)
        pygame.display.flip()


if __name__ == "__main__":
    main()
