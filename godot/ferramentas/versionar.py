"""Dá nome com "impressão digital" aos arquivos da versão Web e gera o sw.js.

Por que: sem isso o Safari baixava o motor do Godot (38 MB) toda vez que o
jogo abria. Com nomes que mudam só quando o conteúdo muda, o service worker
guarda cada arquivo no celular e só baixa de novo o que mudou numa versão
nova (normalmente só o pacote do jogo, ~5 MB; o motor quase nunca muda).

Uso: python3 ferramentas/versionar.py <pasta com o index.html exportado>
"""
import hashlib
import json
import re
import sys
from pathlib import Path

pasta = Path(sys.argv[1])


def impressao(arq):
    return hashlib.sha1((pasta / arq).read_bytes()).hexdigest()[:10]


h_motor = impressao("index.wasm")
h_jogo = impressao("index.pck")
motor = f"kx-{h_motor}"
pacote = f"jogo-{h_jogo}.pck"

renomear = {
    "index.wasm": f"{motor}.wasm",
    "index.js": f"{motor}.js",
    "index.audio.worklet.js": f"{motor}.audio.worklet.js",
    "index.audio.position.worklet.js": f"{motor}.audio.position.worklet.js",
    "index.pck": pacote,
}
for velho, novo in renomear.items():
    (pasta / velho).rename(pasta / novo)

html = (pasta / "index.html").read_text()
html = html.replace('<script src="index.js"></script>', f'<script src="{motor}.js"></script>')
m = re.search(r"const GODOT_CONFIG = (\{.*?\});", html)
cfg = json.loads(m.group(1))
cfg["executable"] = motor
cfg["mainPack"] = pacote
cfg["fileSizes"] = {renomear.get(k, k): v for k, v in cfg["fileSizes"].items()}
html = html.replace(m.group(0), "const GODOT_CONFIG = " + json.dumps(cfg, separators=(",", ":")) + ";")
(pasta / "index.html").write_text(html)

guardar = sorted(renomear.values()) + ["index.png", "index.icon.png", "index.apple-touch-icon.png"]
sw = (Path(__file__).parent / "sw-modelo.js").read_text()
sw = sw.replace("__VERSAO__", f"{h_motor}-{h_jogo}").replace("__ARQUIVOS__", json.dumps(guardar))
(pasta / "sw.js").write_text(sw)
print("motor", motor, "· pacote", pacote)
