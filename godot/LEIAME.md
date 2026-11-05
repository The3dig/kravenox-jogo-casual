# Kravenox: Quadros do Cisma (Godot 4.5)

A versão oficial do jogo, em Godot 4.5, com o
renderizador Compatibility (o que roda no navegador do iPhone), em pé
(480 × 820).

## Abrir e jogar

1. Abra o Godot 4.5 e importe a pasta `godot/` (o arquivo `project.godot`).
2. Aperte F5.

No celular, toque; no computador, use o mouse. Espaço inicia a onda.

## Teste automático

```
godot --headless --path godot -- --robo
```

Um robô compra sozinho (prefere fundir itens), inicia as ondas e escreve no
terminal como foi cada onda e onde a partida terminou.

## Arquivos

| | |
|---|---|
| `scripts/jogo.gd` | o jogo inteiro: tabuleiro, loja, ondas, poderes e desenho |
| `cenas/principal.tscn` | a cena que carrega o script |
| `assets/`, `musica/`, `sons/`, `fontes/` | artes, trilhas, efeitos e letras (origem em `../versoes-antigas/python/assets/LEIAME.md`) |
| `export_presets.cfg` | exportação Web, igual à do Cratera do Cisma |

## Internet: o jogo fica guardado no celular

A versão Web usa um service worker (`ferramentas/sw-modelo.js`) e nomes de
arquivo com impressão digital (`ferramentas/versionar.py`, chamado pelo
`publicar.sh`). Na primeira vez o jogo baixa ~42 MB (o motor do Godot tem
38 MB). Depois disso, abrir o jogo não gasta internet. Numa versão nova, só
baixa o que mudou: normalmente só o pacote do jogo (~5 MB).
