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

## 2026-11-02: o andar do Kravenox volta a ser o de antes

- **Era:** o Kravenox da estátua 3D, uma imagem só que balançava ao andar.
- **Passou a ser:** os 4 quadros de passo do Cratera do Cisma (pixel art),
  como na primeira versão. Monstros, fundo e interface continuam com as artes
  detalhadas. O recorte da estátua (`assets/arte/kravenox.png`) segue em uso
  na tela de fim de jogo.
- **Por quê:** o Rone achou o andar novo horrível e preferiu o anterior.

## 2026-11-02: fica só a versão Godot

- **Era:** duas versões iguais, Python (pygame) e Godot 4.5.
- **Passou a ser:** só a versão Godot é atualizada. A versão Python foi para
  `versoes-antigas/python/` (com a pasta `assets/` que ela usava).
- **Por quê:** a do Godot é a que vai para o celular, e manter as duas
  dobrava o trabalho a cada mudança.

## 2026-11-02: capítulos, mundos e melhorias

- **Era:** uma partida só de 15 ondas, sem tela inicial.
- **Passou a ser:** 76 capítulos (os do livro) em 19 mundos de 4; cada
  capítulo tem 4 fases, a última com chefe. Tela de abertura, tela inicial
  com Jogar, Melhorias, Bestiário e Som, mapa dos mundos, melhorias
  permanentes compradas com fragmentos e progresso salvo. Os poderes e os
  monstros vão sendo liberados aos poucos. Entre as ondas o Kravenox espera no
  meio do anel.
- **Por quê:** pedido do Rone: começar simples, ter evolução a cada missão e
  cobrir os 76 capítulos.

## 2026-11-03: caminhos que crescem, Escudo e fase bônus

- **Era:** caminhos de 12 a 16 quadros desde o mundo 1; 4 fases por capítulo.
- **Passou a ser:** o caminho cresce com os mundos (8 quadros no mundo 1, até
  20 no fim). Novo item Escudo de Espinhos. Depois das 4 fases vem uma fase
  bônus em que os monstros atacam uma torre no meio. No fim da onda o
  Kravenox termina o passo, para um instante e anda devagar até o meio.
- **Por quê:** pedido do Rone (o começo já vinha grande demais, a parada
  estava brusca e ele quis o escudo e a fase da torre).

## 2026-11-05: o jogo volta a ficar guardado no celular

- **Era:** sem cache (desligado em 2026-11-02 para as versões novas
  aparecerem), então o Safari baixava ~42 MB toda vez que o jogo abria. Isso
  acabou com a franquia de internet do Rone.
- **Passou a ser:** service worker próprio que guarda os arquivos, com nomes
  que mudam só quando o conteúdo muda; numa versão nova, só baixa o que
  mudou, e a página sempre confere se há versão nova.
