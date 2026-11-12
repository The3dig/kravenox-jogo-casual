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

## 2026-11-09: o jogo ganha os sistemas da pesquisa de jogos parecidos

- **Era:** a partida era só comprar, posicionar e fundir poderes; fora dela,
  melhorias, missões, baús e conquistas. Barra de abas: Melhorias ·
  Bestiário · Batalha · Mundos · Ajustes.
- **Passou a ser:** tudo o que está em `ideias-evolucao.md`:
  - **Na partida:** combinações entre quadros vizinhos (Grimório), poderes
    lendários (nível 5 + parceiro), escolha de 1 de 3 bênçãos entre as ondas
    (às vezes uma "sombria"), Encruzilhada no meio do capítulo (trecho do
    livro, onda de elite ou fogueira), monstros de elite (blindado, veloz,
    vampiro, divisor), terreno (fenda, altar, pedra maldita), Fúria do
    Kravenox (golpe em todos, muda com a forma), combo, números de dano maiores
    no crítico, tremor de tela, câmera lenta no chefe, vibração (só no app) e
    "arriscar mais uma onda" depois do bônus.
  - **Fora da partida:** Abismo sem Fim (recorde), Desafio do Dia (regra
    sorteada pela data, sem internet), Pactos do Abismo, Crônicas (trechos
    dos capítulos), nível de caça no Bestiário com a ficha de cada monstro,
    Ecos (companheiros abertos pelos baús), Acampamento (6 construções),
    presente do dia em sequência de 7 dias, presente de volta depois de 3 dias
    fora, e as novidades liberadas uma por capítulo.
  - **Abas:** Bestiário saiu da barra (continua na tela do Kravenox) e entrou
    Acampamento.
- **Por quê:** o Rone pediu para analisar jogos parecidos e fazer tudo o que
  agrega interesse.
- **Ficou de fora de propósito:** o Modo Pesadelo continua (os Pactos somam a
  ele, não substituem, para não mexer no progresso já salvo). O mapa do
  capítulo com bifurcação virou a Encruzilhada, que é mais simples.
- **Inventado (não está no livro):** os nomes das bênçãos, das combinações,
  das lendárias, dos pactos e das construções; os Ecos (luzes da Essência,
  sem ser personagem do livro); a Larva-Mãe e a Sentinela sem Rosto já eram
  invenção do jogo. Os textos das Crônicas e dos eventos saem do RPG
  (`kravenox-jogar/rpg/js`), que adapta o livro, pela ferramenta
  `godot/ferramentas/extrair_trechos.py`.

## 2026-11-09: a versão nova aparece sozinha no ícone do iPhone

- **Era:** o jogo abria sempre a página guardada e só buscava a nova "por
  trás", para valer na abertura seguinte. No iPhone o ícone fixado quase
  nunca fecha de verdade (fica suspenso), então a versão nova não aparecia.
- **Passou a ser:** a página (pequena) é buscada primeiro, com prazo de
  2,5 s; sem internet ou com internet lenta abre a guardada. Ao voltar para
  o jogo depois de 5 minutos ou mais fora, ele confere se há versão nova e
  recarrega. Os arquivos grandes continuam guardados (sem gastar internet).
- **Por quê:** o Rone reclamou que a atualização automática não acontecia.

## 2026-11-09: uma música por mundo

- **Era:** 7 trilhas do RPG; a mesma ("abismo") tocava entre as ondas em
  todos os mundos, e "reino" em todos os menus.
- **Passou a ser:** cada um dos 19 mundos tem uma trilha do RPG que combina
  com ele (floresta, Valdora, biblioteca, estrelas…), tocando na tela
  inicial, no mapa e entre as ondas. Batalha, chefe, vitória e derrota
  continuam iguais; a abertura continua com "reino". Lista em
  `MUSICA_MUNDO` (`jogo.gd`). O jogo ficou ~11 MB maior (baixado uma vez).
- **Por quê:** o Rone achou a música boa, mas repetitiva; escolheu uma por mundo.

## 2026-11-09: aba Modos com quatro jeitos novos de jogar

- **Era:** só capítulos, Abismo sem Fim e Desafio do Dia (estes dois em
  botões na tela inicial). Barra de abas com 5 abas.
- **Passou a ser:** aba **Modos** (6 abas na barra) com:
  - **Horda:** multidões vêm de cima, de baixo e dos lados contra a torre;
    o Kravenox ataca sozinho; 10 ondas, com um poder para escolher entre elas.
  - **Colosso:** o "Gigante do Vazio" (nome do capítulo 17; arte da Sentinela
    do Vazio, tingida) ataca marcando áreas vermelhas; o jogador arrasta o
    Kravenox para desviar e o dano dele cresce com o tempo. 90 s, recorde de dano.
  - **Refúgio:** o Kravenox corre para um quarto; o jogador constrói torre,
    raio, cristal (conserta a porta) e fonte (essência) e reforça a porta até
    o amanhecer (2:30).
  - **Caçada:** anda pela sala arrastando o dedo; parado, ataca sozinho;
    10 salas, chefe na 5 e na 10, poder para escolher a cada sala.
  - A aba também abre o Abismo sem Fim e o Desafio do Dia.
- **Por quê:** pedido do Rone, pensando em publicar o jogo. As ideias são de
  gênero (defesa de quarto, horda, chefe gigante, "Archero"); arte, nomes e
  conteúdo são do Kravenox.

## 2026-11-09: Loja do Apoiador, modos mais espaçados e Horda com o que fazer

- **Loja do Apoiador** (botão "Loja" na tela inicial): só visual e conforto,
  **nada de pagar para ganhar** (pedido do Rone). Pacote do Apoiador (aura
  Coroa Rubra, Eco Estelar, moldura dourada, selo), três auras, Moldura de
  Brasa, Velocidade 3× e Coleta de 24 h. Pacotes de fragmentos e "fragmentos
  em dobro" ficaram de fora de propósito. A compra de verdade ainda não está
  ligada (liga quando o jogo for para a Apple ou o Google); para testar, em
  Ajustes tocar 7 vezes na versão.
- **Modos:** eram liberados nos capítulos 5, 6, 7 e 8; passaram a 5 (Horda),
  10 (Colosso), 15 (Refúgio) e 20 (Caçada).
- **Horda:** era só olhar (o Kravenox atirava sozinho em tudo). Passou a ser:
  ele só alcança quem está perto, o jogador arrasta o Kravenox até a horda e
  usa dois golpes com recarga (Esmagar e Espinhos).

## 2026-11-09: Velocidade 4× e Baú do Dia na loja

- **Era:** o item pago dava Velocidade 3× (perto demais do 2× grátis).
- **Passou a ser:** Velocidade 4× (o botão vai 1× → 2× → 4×; acelerado, o
  jogo dá vários passos pequenos para os tiros não atravessarem os monstros).
  No alto da Loja entrou o **Baú do Dia, grátis**: fragmentos (quase sempre),
  às vezes Fúria pela metade na próxima partida ou um monte grande de
  fragmentos, e raramente (5%) um visual da loja (aura ou moldura).
- **Por quê:** pedido do Rone.

## 2026-11-09: Horda com andar natural e torre sólida; "Fora" vira "Vigília"

- **Era:** na Horda o Kravenox deslizava em linha reta, sempre na mesma
  velocidade, e passava por dentro da torre. O bônus de tempo longe se
  chamava "Fora".
- **Passou a ser:** ele acelera e freia aos poucos, as pernas acompanham a
  velocidade, solta poeira nos passos (vale também na Caçada) e a torre é
  sólida: ele bate e desliza pela borda, tem que dar a volta. O bônus virou
  **Vigília do Kravenox** (e o item da loja, "Vigília de 24 horas").
- **Por quê:** o Rone achou a locomoção artificial e o nome "Fora" ruim.

## 2026-11-09: Horda com controle virtual

- **Era:** o Kravenox ia até o ponto onde o dedo estava (o dedo cobria o
  personagem e o controle parecia artificial).
- **Passou a ser:** controle virtual, igual à Caçada: tocar em qualquer lugar
  e arrastar; ele anda na direção arrastada (com aceleração, poeira e a torre
  sólida da versão anterior).
- **Por quê:** o Rone continuou achando a locomoção ruim.

## 2026-11-09: o Kravenox obedece na hora na Horda e na Caçada

- **Era:** aceleração lenta (~0,3 s até a velocidade cheia) e velocidade
  máxima alta: "demora para responder e depois dá uma corrida".
- **Passou a ser:** responde em ~0,1 s, para rápido ao soltar e a velocidade
  máxima caiu de 230/220 para 195 (passo, não disparada).
- **Por quê:** relato do Rone jogando a Horda.

## 2026-11-09: continuar em outro celular, tutorial curto e política de privacidade

- **Continuar em outro celular** (Ajustes): "Copiar progresso" gera um código
  de texto (o progresso comprimido, ~200 a 800 letras) e "Colar progresso" no
  outro celular troca o progresso pelo do código (pede para tocar de novo
  para confirmar). Sem servidor e sem internet. Pedido do Rone, que tem dois
  celulares.
- **Tutorial curto:** só no capítulo 1 de quem está começando, uma mãozinha
  mostra arrastar um poder, iniciar a onda e fundir. Não trava nada e acaba
  na segunda onda. O Rone pediu que não fosse longo.
- **Política de privacidade:** `kravenox-jogar/privacidade.html` (exigida pela
  Apple e pelo Google): o jogo não coleta nada. Ainda falta um contato.

## 2026-11-10: o jogo em inglês

- **Era:** só em português.
- **Passou a ser:** português e inglês (Ajustes → "Idioma / Language"; na
  primeira vez segue o idioma do celular). Todo texto passa por `tx()` na
  hora de desenhar, com o dicionário `godot/dados/en.json` (português →
  inglês; textos com números viram moldes como "Fase %d de %d"). Nomes em
  inglês: "Kravenox: Schism Tiles", Essence Larva, Void Sentinel, Toothed
  Worm, Giant of the Void etc. Os títulos dos capítulos foram traduzidos
  livremente.
- **Ficou em português:** os trechos do livro (Crônicas e eventos), com o
  aviso "text in Portuguese, the book's language". Traduzir o livro é decisão
  do Rone.
- **Por quê:** para o jogo chegar a mais gente se for para as lojas.

## 2026-11-12: o desafio "Sem Trocas" passa a ser sem trocas de verdade

- **Era:** tirava só a troca grátis; trocar custava 4 de essência (o Rone
  trocou várias vezes e venceu, o que contradizia o nome). E na tela final do
  Desafio e do Abismo os dois botões diziam "Início".
- **Passou a ser:** no "Sem Trocas" a loja não troca (botão apagado: compre o
  que vier). O segundo botão do fim do Desafio e do Abismo virou "Modos".
- **Por quê:** relato do Rone com print.

## 2026-11-12: botão "Mais jogos"

- **Passou a ter:** na tela inicial, ao lado da engrenagem, o botão "Mais
  jogos" abre uma tela com os outros jogos do universo (Cratera do Cisma, RPG,
  Plataforma e o MMO), com o ícone de cada um e "Jogar" (abre o link). Os
  ícones foram copiados dos próprios jogos para `godot/assets/jogos/`.
- **Observação:** o MMO aponta para o endereço novo
  (`the3dig.github.io/kravenox-mmo/`), que só funciona depois que a conversa
  do MMO ligar o GitHub Pages daquele repositório.
- **Por quê:** pedido do Rone.

## 2026-11-12: o jogo fica mais difícil

- **Era:** com bênçãos, acampamento, Fúria e lendárias o Kravenox ficava forte
  rápido; o robô vencia os 76 capítulos perdendo poucas vezes, quase só no
  chefe. Um amigo do Rone achou "muito fácil" e pediu monstros com mais vida.
- **Passou a ser:** nos capítulos (não no Abismo nem nos Modos) os monstros
  têm 2,6× a vida e 1,12× o dano (`VIDA_MONSTROS`, `DANO_MONSTROS`); entre as
  ondas a essência caiu (4 + onda + capítulo/4) e a cura passou de 30 para 20.
- **Resultado no robô:** 56 derrotas espalhadas do capítulo 3 ao 76 (máximo
  de 5 tentativas num capítulo) e ainda chega ao fim. Testes: 1,45× e 1,9× de
  vida mal mudaram (o Kravenox mata antes); 2,6× com 1,25× de dano travou o
  robô no capítulo 52.

## 2026-11-12: skins do Kravenox

- **Passou a ter:** quatro skins na Loja do Apoiador (R$ 4,90 cada, só
  visual): Kravenox de Gelo, Dourado, do Vazio e de Brasa. O corpo muda de cor
  e os olhos e o contorno ganham a cor de destaque, no desenho grande e nos 4
  passos. As imagens são pintadas por `godot/ferramentas/pintar_skins.py`
  a partir das artes que o jogo já usa (`godot/assets/skins/`). A lista da
  loja passou a rolar com o dedo (o Baú do Dia fica fixo no alto).
- **Por quê:** um amigo do Rone perguntou "tem skin?"; as auras só mudavam a
  luz em volta, não o corpo.

## 2026-11-12: prêmio de beta tester

- **Passou a ter:** em Ajustes, "Código de presente". O código **BETA-KRAVENOX**
  (vale também BETATESTER, com ou sem hífen e espaços) abre o **Baú do Beta
  Tester**: skin exclusiva **Kravenox Pioneiro** (verde-esmeralda, não é
  vendida), 1 skin da loja à escolha (Gelo, Dourado, Vazio ou Brasa), selo
  "Beta Tester ★" em Ajustes e +100 fragmentos. Vale uma vez por aparelho
  (sem servidor, não dá para limitar por pessoa).
- **Por quê:** o Rone quis premiar os amigos que testam o jogo, com skins
  (o que o amigo mais gostou).
- **Fontes:** ✓, ★ e ♥ não existem nas fontes do jogo (Alegreya Sans e
  Cinzel) e apareciam como quadradinhos no navegador; foram trocados por
  texto ("Ativo", "Pego", "vencido", "Beta Tester", "Apoiador: obrigado!").

## 2026-11-12: código de beta tester pessoal

- **Era:** um código só para todo mundo (BETA-KRAVENOX), que podia circular.
- **Passou a ser:** um código por pessoa. O baú mostra "Para <nome>" e o selo
  em Ajustes fica "Beta Tester: <nome>". O código geral foi desligado. No
  repositório (público) fica só a impressão digital (sha256) de cada código,
  em `CODIGOS_BETA`; o código em si o Rone passa direto para a pessoa.
  Primeiro código: para o Ludivicky. Novos: `python3 godot/ferramentas/codigo_beta.py Nome`.
- **Por quê:** o Rone perguntou como saber que o prêmio é para aquele amigo.
