# Decisões

## 2026-11-02: de fogueira em HTML para quadros em Python

- **Era:** "A Última Fogueira", em HTML, com o personagem parado no centro
  defendendo uma fogueira e o jogador tocando nos monstros.
- **Passou a ser:** "Quadros do Cisma", em Python (pygame). O Kravenox anda
  sem parar num anel de quadros e ativa o poder de cada quadro onde pisa.
  Os poderes vêm de uma loja embaixo, com custo. Os monstros são os do livro
  e do gibi, com os sprites que já existem.
- **Por quê:** o Rone pediu Python, nada de HTML, e o mesmo estilo do jogo de
  referência (quadros que o personagem percorre).
- A versão anterior ficou em `versoes-antigas/fogueira-html/`.

## 2026-11-02: versão em Godot 4.5

- **Era:** só a versão em Python.
- **Passou a ser:** a versão em Python continua, e a mesma versão foi passada
  para Godot 4.5 (`godot/`), no mesmo padrão do Cratera do Cisma
  (Compatibility, exportação Web, modo `--robo`).
- **Por quê:** o Rone pediu o jogo em Godot 4. A mecânica (quadros que o
  Kravenox percorre, loja com custo e ondas) fica; não foi feita cópia das
  fases, dos itens nem da arte do jogo de referência.
- **Mudança nas duas versões:** o Kravenox ganhou uma mordida básica, e os
  monstros aceleram depois de 20 s de onda. Sem isso, um tabuleiro só com
  cura e velocidade deixava a onda sem fim.

## 2026-11-02: visual com as artes detalhadas

- **Era:** sprites de pixel art (do Cratera do Cisma e do RPG), fundo
  vermelho liso e interface de cores claras.
- **Passou a ser:** recortes das estátuas 3D e das pinturas conceituais,
  fundo com a pintura da Cratera do Cisma, interface escura de fantasia
  sombria (pedra, roxo do Vazio, ouro velho).
- **Por quê:** o Rone achou os desenhos infantis e pediu o nível de detalhe
  das artes 3D.
- **Monstros:** saíram a Sombra, os Devoradores e A Coisa que Dormia (não têm
  arte detalhada ainda). Entraram o Verme de Dentes (nome provisório: no
  livro ele ainda não tem nome) e, como chefes, a Sentinela sem Rosto
  (onda 10) e o Thornox (onda 15, como no Cratera do Cisma).
- Os sprites antigos continuam em `assets/` e `godot/assets/`.
