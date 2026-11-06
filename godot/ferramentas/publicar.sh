#!/bin/sh
# Exporta a versão Web e copia para a pasta quadros/ do repositório público
# kravenox-jogar, de onde o GitHub Pages serve o jogo em
# https://the3dig.github.io/kravenox-jogar/quadros/
#
# Uso: ferramentas/publicar.sh [caminho do clone do kravenox-jogar]
# Só o jogo montado vai para lá; o projeto e as artes ficam aqui.
# Não mexe na raiz do kravenox-jogar (lá fica o Cratera do Cisma).
set -e
cd "$(dirname "$0")/.."
DESTINO="${1:-../../kravenox-jogar}/quadros"
GODOT="${GODOT:-godot}"
rm -rf build/web && mkdir -p build/web
"$GODOT" --headless --export-release "Web" build/web/index.html
# nomes com impressão digital + sw.js que guarda o jogo no celular
python3 ferramentas/versionar.py build/web
mkdir -p "$DESTINO"
find "$DESTINO" -maxdepth 1 \( -name 'index*' -o -name 'kx-*' -o -name 'jogo-*' -o -name 'sw.js' \) -delete
cp build/web/* "$DESTINO"/
# Celulares que abriram uma versão antiga têm um service worker guardando o
# jogo; com este arquivo eles passam a usar o sw.js novo, sem recarregar a página.
cp build/web/sw.js "$DESTINO"/index.service.worker.js
echo "Pronto. Faça o commit e o push no kravenox-jogar."
