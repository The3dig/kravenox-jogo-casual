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
mkdir -p "$DESTINO"
find "$DESTINO" -maxdepth 1 -name 'index*' -delete
cp build/web/* "$DESTINO"/
echo "Pronto. Faça o commit e o push no kravenox-jogar."
