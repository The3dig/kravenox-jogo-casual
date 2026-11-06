"""Baixa só um arquivo de dentro dos modelos de exportação do Godot (1,3 GB),
lendo pedaços do zip pela internet, sem baixar o pacote inteiro.

Uso: python3 baixar_modelo.py <arquivo, ex.: ios.zip> <pasta de destino>
"""
import os
import sys
import urllib.request
import zipfile

URL = "https://github.com/godotengine/godot/releases/download/4.5-stable/Godot_v4.5-stable_export_templates.tpz"


class Remoto:
    def __init__(self, url):
        r = urllib.request.urlopen(urllib.request.Request(url, method="HEAD"))
        self.url, self.tam, self.pos = r.url, int(r.headers["Content-Length"]), 0

    def seekable(self):
        return True

    def tell(self):
        return self.pos

    def seek(self, off, de=0):
        self.pos = off if de == 0 else (self.pos + off if de == 1 else self.tam + off)
        return self.pos

    def read(self, n=-1):
        if n < 0:
            n = self.tam - self.pos
        if n == 0 or self.pos >= self.tam:
            return b""
        fim = min(self.tam, self.pos + n) - 1
        req = urllib.request.Request(self.url, headers={"Range": "bytes=%d-%d" % (self.pos, fim)})
        dados = urllib.request.urlopen(req).read()
        self.pos += len(dados)
        return dados


alvo, destino = sys.argv[1], sys.argv[2]
os.makedirs(destino, exist_ok=True)
z = zipfile.ZipFile(Remoto(URL))
for nome in z.namelist():
    if nome.endswith("/" + alvo) or nome.endswith("version.txt"):
        with z.open(nome) as orig, open(os.path.join(destino, os.path.basename(nome)), "wb") as out:
            while True:
                bloco = orig.read(1 << 20)
                if not bloco:
                    break
                out.write(bloco)
        print("ok", nome)
