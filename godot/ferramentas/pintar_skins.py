"""Pinta as skins do Kravenox a partir dos desenhos que o jogo já usa.

Cada pixel escuro do corpo vira um degradê da cor da skin (pela luminosidade);
os pixels vermelhos (olhos e contorno) viram a cor de destaque da skin.
Saída: assets/skins/<skin>/kravenox.png e kravenox-passo-0..3.png
Uso: python3 ferramentas/pintar_skins.py   (de dentro de godot/)
"""
from PIL import Image
import colorsys, os

SKINS = {
    # nome: (cor do escuro, cor do claro, cor de destaque)
    "gelo": ((18, 40, 70), (190, 235, 255), (120, 240, 255)),
    "ouro": ((60, 40, 10), (255, 220, 120), (255, 60, 40)),
    "sombrio": ((30, 10, 50), (190, 140, 255), (200, 120, 255)),
    "brasa": ((28, 16, 14), (205, 100, 50), (255, 190, 60)),
    "pioneiro": ((10, 34, 28), (150, 255, 200), (90, 255, 160)),
    # 15/11: skins de conquista
    "pesadelo": ((8, 6, 8), (120, 30, 40), (255, 40, 40)),
    "abissal": ((2, 8, 14), (40, 110, 140), (0, 255, 255)),
    "soberano": ((120, 95, 40), (255, 248, 210), (255, 255, 255)),
    "lenda": ((70, 10, 60), (255, 130, 210), (255, 230, 90)),
    # 15/11: skins dos eventos da semana
    "musgo": ((16, 30, 12), (150, 200, 90), (230, 255, 120)),
    "prata": ((70, 75, 90), (240, 245, 255), (255, 60, 60)),
    "estelar": ((10, 12, 40), (130, 150, 255), (255, 255, 255)),
    "forja": ((25, 28, 35), (120, 130, 150), (255, 140, 40)),
    # 17/11: Passe do Cisma, temporada 1 (cisma = trilha grátis; as outras, trilha paga)
    "cisma": ((40, 10, 30), (200, 80, 150), (255, 200, 240)),
    "rubro": ((60, 0, 10), (230, 40, 60), (255, 215, 90)),
    "obsidiana": ((4, 2, 10), (60, 40, 90), (190, 120, 255)),
    "aurora": ((10, 40, 50), (120, 240, 210), (255, 150, 230)),
}
FONTES = [("assets/arte/kravenox.png", "kravenox.png")] + [("assets/kravenox-passo-%d.png" % n, "kravenox-passo-%d.png" % n) for n in range(4)]


def mistura(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


for skin, (escuro, claro, destaque) in SKINS.items():
    pasta = "assets/skins/%s" % skin
    os.makedirs(pasta, exist_ok=True)
    for origem, nome in FONTES:
        im = Image.open(origem).convert("RGBA")
        px = im.load()
        for y in range(im.height):
            for x in range(im.width):
                r, g, b, a = px[x, y]
                if a == 0:
                    continue
                h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
                vermelho = s > 0.45 and r > 90 and r > g * 1.6 and r > b * 1.6
                if vermelho:
                    brilho = min(1.0, l * 1.6)
                    c = mistura((0, 0, 0), destaque, min(1.0, 0.35 + brilho))
                else:
                    t = min(1.0, l * 2.6)
                    c = mistura(escuro, claro, t)
                px[x, y] = (c[0], c[1], c[2], a)
        im.save(os.path.join(pasta, nome))
print("skins prontas:", ", ".join(SKINS))
