"""Pinta as ilustrações dos 19 mundos (assets/mundos/mundo-NN.png, 480x200).

Cada mundo é um trecho de 4 capítulos do livro; a ilustração mostra o lugar
daquele trecho. Três mundos usam as pinturas conceituais oficiais
(kravenox/arte/conceitos); os outros são pintados aqui em camadas (céu,
montanhas, silhuetas, névoa e brilho), na paleta de cada lugar.

Uso: python3 ferramentas/pintar_mundos.py [pasta das artes conceituais]
"""
import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

W, H = 480, 200
AQUI = Path(__file__).resolve().parents[1]
SAIDA = AQUI / "assets" / "mundos"
CONCEITOS = Path(sys.argv[1]) if len(sys.argv) > 1 else AQUI.parents[1] / "kravenox" / "arte" / "conceitos"


def grad(c1, c2):
    im = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(im)
    for y in range(H):
        t = y / (H - 1)
        d.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(c1, c2)))
    return im.convert("RGBA")


def camada():
    return Image.new("RGBA", (W, H), (0, 0, 0, 0))


def colar(base, lay, blur=0):
    if blur:
        lay = lay.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(lay)


def brilho(base, x, y, r, cor, forca=160):
    lay = camada()
    ImageDraw.Draw(lay).ellipse((x - r, y - r, x + r, y + r), fill=cor + (forca,))
    colar(base, lay, r * 0.6)


def serra(rnd, y0, amp, passo, aspero=0.6):
    """Linha de montanha: lista de pontos de x=0 a x=W."""
    pts, y = [], y0
    for x in range(-10, W + 20, passo):
        y += rnd.uniform(-amp, amp) * aspero
        y = max(y0 - amp * 2, min(y0 + amp, y))
        pts.append((x, y))
    return pts


def montanhas(base, rnd, y0, amp, cor, blur=0, passo=14):
    lay = camada()
    pts = serra(rnd, y0, amp, passo)
    ImageDraw.Draw(lay).polygon(pts + [(W + 20, H), (-10, H)], fill=cor)
    colar(base, lay, blur)


def nevoa(base, y, cor, alfa=90, alt=40):
    lay = camada()
    d = ImageDraw.Draw(lay)
    for k in range(alt):
        a = int(alfa * (1 - abs(k - alt / 2) / (alt / 2)))
        d.line([(0, y + k - alt / 2), (W, y + k - alt / 2)], fill=cor + (a,))
    colar(base, lay, 6)


def estrelas(base, rnd, n, cor=(230, 220, 255), ate=None):
    d = ImageDraw.Draw(base)
    for _ in range(n):
        x, y = rnd.randrange(W), rnd.randrange(ate or H)
        a = rnd.randint(80, 255)
        d.point((x, y), fill=cor + (a,))
        if rnd.random() < 0.08:
            d.line([(x - 2, y), (x + 2, y)], fill=cor + (a // 2,))
            d.line([(x, y - 2), (x, y + 2)], fill=cor + (a // 2,))


def arvore_morta(d, x, chao, alt, cor, rnd):
    def galho(x0, y0, ang, comp, larg):
        if comp < 4:
            return
        x1, y1 = x0 + math.cos(ang) * comp, y0 - math.sin(ang) * comp
        d.line([(x0, y0), (x1, y1)], fill=cor, width=max(1, int(larg)))
        for _ in range(2):
            galho(x1, y1, ang + rnd.uniform(-0.7, 0.7), comp * rnd.uniform(0.55, 0.75), larg * 0.65)
    galho(x, chao, math.pi / 2 + rnd.uniform(-0.1, 0.1), alt * 0.4, alt / 14)


def torre(d, x, chao, larg, alt, cor, ameias=True, janela=None):
    d.rectangle((x - larg / 2, chao - alt, x + larg / 2, chao), fill=cor)
    if ameias:
        for k in range(3):
            d.rectangle((x - larg / 2 + k * larg / 3 + 1, chao - alt - larg / 4, x - larg / 2 + k * larg / 3 + larg / 6, chao - alt), fill=cor)
    if janela:
        d.rectangle((x - 2, chao - alt * 0.7, x + 2, chao - alt * 0.7 + 6), fill=janela)


def cristal(d, x, y, t, cor, luz):
    d.polygon([(x, y - t), (x + t * 0.35, y), (x, y + t * 0.5), (x - t * 0.35, y)], fill=cor)
    d.polygon([(x, y - t), (x + t * 0.35, y), (x, y)], fill=luz)


def grao(base, rnd, forca=10):
    ruido = Image.effect_noise((W, H), 40).convert("L")
    lay = Image.merge("RGBA", (ruido, ruido, ruido, Image.new("L", (W, H), forca)))
    base.alpha_composite(lay)


def vinheta(base):
    m = Image.new("L", (W, H), 0)
    ImageDraw.Draw(m).ellipse((-W * 0.25, -H * 0.6, W * 1.25, H * 1.5), fill=255)
    m = m.filter(ImageFilter.GaussianBlur(40))
    escuro = Image.new("RGBA", (W, H), (6, 4, 10, 255))
    escuro.putalpha(Image.eval(m, lambda v: 200 - int(v * 0.78)))
    base.alpha_composite(escuro)


def da_pintura(nome, caixa, brilho_k=1.0):
    im = Image.open(CONCEITOS / nome).convert("RGB").crop(caixa).resize((W, H), Image.LANCZOS)
    return ImageEnhance.Brightness(im).enhance(brilho_k).convert("RGBA")


# ------------------------------------------------------------------ os mundos
def m1(r):   # A Cratera do Cisma
    return da_pintura("cratera-do-cisma.jpg", (0, 330, 1024, 757), 1.15)


def m2(r):   # A Floresta das Raízes (A Primeira Raiz, A Coisa que Dormia)
    return da_pintura("kravenox-e-os-vermes.jpg", (0, 150, 1024, 577), 1.25)


def m3(r):   # O Abismo dos Sinos
    b = grad((22, 8, 14), (70, 14, 20))
    brilho(b, 240, 175, 90, (230, 40, 30), 150)
    montanhas(b, r, 120, 18, (30, 10, 16, 255), 2)
    d = ImageDraw.Draw(b)
    d.polygon([(0, 200), (0, 140), (170, 150), (205, 200)], fill=(12, 6, 10, 255))
    d.polygon([(480, 200), (480, 135), (300, 150), (275, 200)], fill=(12, 6, 10, 255))
    torre(d, 360, 150, 22, 88, (12, 6, 10, 255), True)
    d.polygon([(349, 62), (371, 62), (360, 40)], fill=(12, 6, 10, 255))
    d.ellipse((354, 74, 366, 86), fill=(255, 190, 90, 255))
    for k in range(7):
        x = 60 + k * 18
        d.line([(x, 150 - k * 3), (x, 120 - k * 3)], fill=(12, 6, 10, 255), width=2)
        d.ellipse((x - 5, 118 - k * 3, x + 5, 128 - k * 3), fill=(40, 16, 20, 255))
    nevoa(b, 165, (120, 30, 30), 70)
    return b


def m4(r):   # Valdora em Cinzas
    b = grad((40, 18, 16), (150, 70, 30))
    brilho(b, 120, 150, 120, (255, 140, 40), 140)
    lay = camada()
    d = ImageDraw.Draw(lay)
    for k in range(9):
        x = 30 + k * 54 + r.randint(-10, 10)
        torre(d, x, 165, r.randint(16, 30), r.randint(40, 95), (28, 14, 14, 255), r.random() < 0.6, (255, 170, 60, 255))
    colar(b, lay)
    for _ in range(14):
        x = r.randrange(W)
        brilho(b, x, r.randint(40, 130), r.randint(14, 30), (70, 50, 50), 120)
    d = ImageDraw.Draw(b)
    d.rectangle((0, 165, W, H), fill=(18, 10, 10, 255))
    for _ in range(80):
        x, y = r.randrange(W), r.randrange(H)
        d.point((x, y), fill=(255, 180, 90, r.randint(120, 255)))
    return b


def m5(r):   # O Olho do Primeiro (O Gigante do Vazio, O Coração do Primeiro)
    b = grad((14, 12, 30), (60, 40, 30))
    brilho(b, 240, 60, 70, (255, 200, 80), 170)
    d = ImageDraw.Draw(b)
    d.ellipse((205, 42, 275, 78), fill=(255, 220, 120, 255))
    d.ellipse((228, 46, 252, 74), fill=(120, 60, 10, 255))
    d.ellipse((236, 54, 244, 66), fill=(10, 6, 4, 255))
    montanhas(b, r, 140, 14, (40, 30, 34, 255), 1)
    lay = camada()
    d = ImageDraw.Draw(lay)
    for k in range(6):
        x = 40 + k * 80
        d.rectangle((x, 130, x + 10, 175), fill=(20, 16, 22, 255))
        d.rectangle((x - 4, 126, x + 14, 132), fill=(20, 16, 22, 255))
    colar(b, lay)
    ImageDraw.Draw(b).rectangle((0, 172, W, H), fill=(14, 12, 18, 255))
    return b


def m6(r):   # A Sala da Fonte (a árvore de cristal branco)
    b = grad((200, 210, 230), (90, 100, 130))
    brilho(b, 240, 90, 120, (255, 255, 255), 200)
    d = ImageDraw.Draw(b)
    arvore_morta(d, 240, 180, 190, (250, 250, 255, 255), r)
    for _ in range(18):
        cristal(d, r.randrange(W), r.randint(150, 195), r.randint(8, 18), (170, 190, 230, 255), (240, 250, 255, 255))
    nevoa(b, 180, (255, 255, 255), 90)
    return b


def m7(r):   # Além das Montanhas / A Primeira Cidade
    b = grad((60, 70, 110), (190, 130, 110))
    brilho(b, 380, 120, 50, (255, 210, 150), 160)
    montanhas(b, r, 90, 26, (90, 90, 130, 255), 3, 10)
    montanhas(b, r, 120, 22, (60, 56, 90, 255), 1, 12)
    lay = camada()
    d = ImageDraw.Draw(lay)
    for k in range(14):
        x = 150 + k * 14
        torre(d, x, 160, 12, r.randint(20, 55), (40, 34, 56, 255), False, (255, 220, 150, 255))
    colar(b, lay)
    montanhas(b, r, 165, 10, (30, 26, 40, 255), 0, 16)
    return b


def m8(r):   # O Exército das Sombras (as Sentinelas)
    return da_pintura("sentinelas-do-vazio.jpg", (0, 330, 1024, 757), 1.6)


def m9(r):   # O Trono do Vazio (O Rei do Vazio, A Nova Essência)
    b = grad((6, 4, 14), (30, 16, 50))
    estrelas(b, r, 120)
    brilho(b, 240, 110, 100, (120, 60, 220), 150)
    d = ImageDraw.Draw(b)
    for k in range(5):
        a = -math.pi / 2 + (k - 2) * 0.35
        d.line([(240, 120), (240 + math.cos(a) * 160, 120 + math.sin(a) * 120)], fill=(170, 120, 255, 110), width=2)
    d.polygon([(205, 175), (275, 175), (262, 95), (250, 80), (240, 60), (230, 80), (218, 95)], fill=(8, 4, 14, 255))
    for k in range(-3, 4):
        d.polygon([(240 + k * 9, 64 + abs(k) * 6), (236 + k * 9, 82), (244 + k * 9, 82)], fill=(8, 4, 14, 255))
    d.rectangle((0, 175, W, H), fill=(8, 4, 14, 255))
    for _ in range(12):
        cristal(d, r.randrange(W), r.randint(165, 195), r.randint(6, 14), (60, 30, 110, 255), (170, 120, 255, 255))
    return b


def m10(r):  # A Guerra dos Mundos
    b = grad((30, 14, 30), (120, 40, 40))
    estrelas(b, r, 60, ate=90)
    d = ImageDraw.Draw(b)
    for k in range(6):
        x, y, t = r.randint(30, 450), r.randint(30, 120), r.randint(16, 40)
        d.polygon([(x - t, y), (x + t, y), (x + t * 0.4, y + t * 1.1), (x - t * 0.3, y + t * 0.9)], fill=(40, 26, 36, 255))
        d.ellipse((x - t, y - t * 0.25, x + t, y + t * 0.25), fill=(70, 60, 60, 255))
        brilho(b, x, y + t, 10, (255, 90, 50), 120)
    montanhas(b, r, 170, 8, (20, 10, 16, 255), 0, 18)
    return b


def m11(r):  # O Primeiro Mundo (Aveline escreveu o primeiro mundo)
    b = grad((90, 140, 120), (30, 60, 50))
    brilho(b, 120, 60, 60, (230, 255, 220), 150)
    montanhas(b, r, 110, 20, (50, 90, 70, 255), 3)
    d = ImageDraw.Draw(b)
    for k in range(9):
        x = 20 + k * 55 + r.randint(-8, 8)
        h = r.randint(50, 90)
        d.rectangle((x - 3, 180 - h, x + 3, 180), fill=(26, 40, 30, 255))
        d.ellipse((x - 22, 180 - h - 26, x + 22, 180 - h + 10), fill=(30, 70, 46, 255))
    nevoa(b, 175, (200, 240, 210), 70)
    return b


def m12(r):  # A Porta entre Mundos (A Prisão entre Mundos, A Porta)
    b = grad((10, 10, 20), (40, 30, 60))
    estrelas(b, r, 90)
    brilho(b, 240, 110, 70, (255, 230, 170), 190)
    d = ImageDraw.Draw(b)
    d.rectangle((205, 50, 275, 180), fill=(20, 16, 26, 255))
    d.rectangle((217, 62, 263, 180), fill=(255, 230, 170, 255))
    d.polygon([(205, 50), (275, 50), (240, 22)], fill=(20, 16, 26, 255))
    for k in range(10):
        d.line([(240, 120), (240 + (k - 4.5) * 50, 200)], fill=(255, 230, 170, 60), width=3)
    d.rectangle((0, 180, W, H), fill=(14, 12, 20, 255))
    return b


def m13(r):  # A Cidade dos Espinhos
    b = grad((40, 10, 16), (110, 30, 30))
    brilho(b, 240, 150, 120, (220, 50, 40), 130)
    d = ImageDraw.Draw(b)
    for k in range(16):
        x = k * 32 + r.randint(-6, 6)
        h = r.randint(50, 130)
        d.polygon([(x - 12, 180), (x + 12, 180), (x, 180 - h)], fill=(16, 6, 10, 255))
        for j in range(3):
            y = 180 - h * (0.3 + j * 0.2)
            d.polygon([(x, y), (x + 10, y - 6), (x + 2, y + 4)], fill=(16, 6, 10, 255))
    d.rectangle((0, 178, W, H), fill=(12, 4, 8, 255))
    nevoa(b, 172, (150, 30, 30), 70)
    return b


def m14(r):  # A Biblioteca do Fim
    b = grad((30, 22, 16), (80, 56, 34))
    brilho(b, 240, 70, 90, (255, 210, 140), 150)
    d = ImageDraw.Draw(b)
    for x in (40, 120, 360, 440):
        d.rectangle((x - 28, 20, x + 28, 190), fill=(36, 24, 16, 255))
        for y in range(30, 190, 16):
            for k in range(8):
                d.rectangle((x - 25 + k * 7, y, x - 20 + k * 7, y + 12), fill=r.choice([(120, 40, 30, 255), (40, 70, 90, 255), (140, 110, 50, 255), (70, 40, 80, 255)]))
            d.line([(x - 28, y + 13), (x + 28, y + 13)], fill=(20, 14, 10, 255), width=2)
    for _ in range(10):
        x, y = r.randint(170, 310), r.randint(40, 150)
        d.polygon([(x - 8, y), (x, y - 3), (x + 8, y), (x, y + 4)], fill=(240, 220, 180, 255))
    return b


def m15(r):  # O Livro de Thornox (azul, o irmão)
    b = grad((60, 90, 150), (20, 30, 60))
    brilho(b, 240, 110, 80, (150, 200, 255), 170)
    d = ImageDraw.Draw(b)
    d.polygon([(160, 150), (240, 132), (320, 150), (320, 162), (240, 146), (160, 162)], fill=(230, 225, 210, 255))
    d.line([(240, 132), (240, 146)], fill=(120, 110, 90, 255), width=2)
    for _ in range(30):
        x, y = r.randint(160, 320), r.randint(40, 130)
        d.point((x, y), fill=(200, 230, 255, 255))
    montanhas(b, r, 175, 10, (14, 20, 40, 255), 0, 16)
    return b


def m16(r):  # A Estrada entre as Estrelas
    b = grad((6, 6, 22), (24, 16, 50))
    estrelas(b, r, 260)
    d = ImageDraw.Draw(b)
    for k in range(40):
        t = k / 40
        x = 240 + math.sin(t * 6) * 60 * (1 - t)
        y = 200 - t * 150
        rr = 18 * (1 - t) + 2
        d.ellipse((x - rr, y - rr * 0.35, x + rr, y + rr * 0.35), fill=(200, 190, 255, int(200 * (1 - t))))
    brilho(b, 240, 50, 30, (230, 220, 255), 200)
    return b


def m17(r):  # O Começo Depois do Fim (amanhecer)
    b = grad((240, 170, 120), (110, 80, 110))
    brilho(b, 240, 150, 70, (255, 240, 200), 200)
    montanhas(b, r, 130, 18, (130, 90, 110, 255), 3)
    montanhas(b, r, 160, 12, (70, 50, 70, 255), 1, 16)
    d = ImageDraw.Draw(b)
    for _ in range(40):
        x = r.randrange(W)
        d.line([(x, 200), (x + r.randint(-3, 3), 188)], fill=(40, 30, 40, 255), width=1)
    return b


def m18(r):  # A Estrela Azul (Aveline)
    b = grad((8, 14, 40), (20, 30, 70))
    estrelas(b, r, 180)
    brilho(b, 330, 60, 40, (120, 180, 255), 220)
    d = ImageDraw.Draw(b)
    d.ellipse((322, 52, 338, 68), fill=(220, 240, 255, 255))
    montanhas(b, r, 160, 14, (10, 14, 30, 255), 0, 14)
    d = ImageDraw.Draw(b)
    d.polygon([(150, 165), (156, 140), (162, 165)], fill=(10, 14, 30, 255))   # uma figura de capa
    d.ellipse((151, 133, 161, 143), fill=(10, 14, 30, 255))
    d.polygon([(149, 150), (163, 150), (167, 168), (145, 168)], fill=(120, 20, 30, 255))
    return b


def m19(r):  # O Mundo Verde (O que Fica Depois do Fim)
    b = grad((150, 200, 230), (120, 180, 120))
    brilho(b, 120, 50, 50, (255, 255, 230), 200)
    montanhas(b, r, 120, 16, (90, 150, 110, 255), 3)
    montanhas(b, r, 150, 12, (60, 120, 70, 255), 1, 14)
    d = ImageDraw.Draw(b)
    for _ in range(60):
        x, y = r.randrange(W), r.randint(160, 200)
        d.ellipse((x - 2, y - 2, x + 2, y + 2), fill=r.choice([(255, 240, 120, 255), (255, 255, 255, 255), (240, 150, 170, 255)]))
    return b


MUNDOS = [m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19]

SAIDA.mkdir(parents=True, exist_ok=True)
for i, f in enumerate(MUNDOS, 1):
    r = random.Random(i * 101)
    im = f(r)
    grao(im, r, 8)
    vinheta(im)
    im.convert("RGB").save(SAIDA / ("mundo-%02d.png" % i))
    print("mundo", i)
