# Kravenox: Quadros do Cisma

Jogo casual do universo Kravenox, em **Godot 4.5**, na pasta `godot/` (veja
`godot/LEIAME.md`). Jogar: https://the3dig.github.io/kravenox-jogar/quadros/

O Kravenox anda sem parar por um caminho de quadros. Na loja de baixo você
compra poderes e coloca nos quadros; quando ele pisa num quadro, o poder dali
dispara. Entre as ondas ele espera no meio do anel.

## Estrutura

- **76 capítulos**, um para cada capítulo do livro (35 do Livro I e 41 do
  Livro II), com os títulos do RPG.
- **Cada mundo tem um caminho diferente, e eles crescem:** o mundo 1 começa
  com 8 quadros e os últimos têm 20 (anéis, cruz, degrau, dente, cruz grande,
  dois dentes; alguns espelhados). Em caminhos maiores o Kravenox anda um
  pouco mais rápido.
- **19 mundos** de 4 capítulos cada. O mapa dos mundos mostra o que já foi
  vencido, o próximo capítulo e o que ainda está trancado.
- **Fase bônus:** depois das 4 fases, os monstros vão atrás de uma torre no
  meio do caminho em vez do Kravenox. Se a torre ficar de pé, rende
  fragmentos extras; se cair, o capítulo continua vencido.
- **4 fases por capítulo**; a 4ª tem chefe: Larva-Mãe nos dois primeiros
  capítulos de cada mundo, Sentinela sem Rosto no terceiro e Thornox no último.
- **Começa simples:** no capítulo 1 só existem Garras, Espinhos e Cristal e só
  aparece a Larva. Os outros poderes e monstros entram aos poucos (Raio no 2,
  Passo no 3, Esmagamento no 5, Fonte no 7, Rasgo no 9, Escudo no 4, Corrida no 6; Sentinela Esférica no
  2, Verme no 4, Sentinela do Vazio no 6).
- **Descrições:** cada item da loja tem uma frase curta; ao tocar no item (ou
  num quadro ocupado) aparece a explicação completa.
- **Melhorias:** cada capítulo dá fragmentos (mais na primeira vitória). Na
  tela de Melhorias eles viram vida, essência inicial, dano, velocidade e
  trocas grátis, que valem para todos os capítulos.
- O progresso fica salvo no aparelho.

## Telas

- **Abertura:** logo e carregamento.
- **Início:** barra com o Kravenox, o Poder e os fragmentos; botão de ajustes;
  modo **Normal / Pesadelo** (Pesadelo libera depois do Mundo 1: monstros
  mais fortes e fragmentos em dobro); o capítulo escolhido com setas, sobre a
  ilustração do mundo dele; botão Começar (ou Continuar); botões laterais:
  **Presente do dia**, **Missões do dia**, **Baús dos mundos** (um por mundo
  completo) e **Enquanto você estava fora** (fragmentos que juntam sozinhos,
  até 12 horas).
- **Barra de baixo:** Melhorias · Bestiário · Batalha · Mundos · Ajustes.
- **Mundos:** cada mundo tem uma ilustração do lugar do livro
  (`godot/assets/mundos/`, pintadas por `godot/ferramentas/pintar_mundos.py`;
  os mundos 1, 2 e 8 usam as pinturas conceituais oficiais) e os 4 capítulos
  embaixo.
- **Ajustes:** música, efeitos e apagar progresso.

## Como abrir

No Godot 4.5, importe a pasta `godot/` e aperte F5. Para publicar a versão Web,
rode `godot/ferramentas/publicar.sh`.

## Como se joga

- Arraste um item da loja até um quadro para colocar (ou toque no item e depois
  no quadro). O custo aparece no item.
- Item igual e do mesmo nível no mesmo quadro: os dois se fundem (nível +1, máximo 5).
- Arraste um item de um quadro para outro para mover, fundir ou trocar de lugar.
- **Lixo:** toque nele e depois num quadro para vender o item pela metade.
- **Trocar:** sorteia outros 3 itens (a primeira troca de cada onda é grátis, depois custa 2).
- **Iniciar onda** (ou espaço) começa a onda. **x1/x2** acelera.
- O Kravenox sempre morde quem está colado nele. Depois de 20 s de onda, os
  monstros ficam cada vez mais rápidos.
- Matar monstros dá essência roxa, que paga a loja. Vencer a onda dá essência e cura.

## Poderes (dos poderes do Kravenox)

O **Escudo de Espinhos** (a partir do capítulo 4) cria um escudo azul por cima
da vida, que leva o dano primeiro; quanto maior o nível, mais escudo ele
guarda.

| Poder | O que faz quando ele pisa |
|---|---|
| Garras | golpe em volta dele |
| Espinhos | 8 espinhos para todos os lados |
| Raio da Essência | raio em cadeia nos monstros mais perto |
| Esmagamento | dano numa área grande |
| Rasgo do Abismo | corte que atravessa os monstros |
| Cristal de Vida | cura |
| Passo Predador | salta para a frente: 2 quadros por nível (só o quadro onde cai dispara) |
| Corrida do Cisma | corre mais rápido e dispara cada casa: 2x por 2 casas no nível 1, 4x por 4 no nível 2, 6x por 6 no nível 3... |
| Fonte de Essência | dá essência |

## Visual

As artes são as oficiais do Kravenox, recortadas do fundo: o Kravenox e o
Thornox vêm das estátuas 3D (`kravenox/3d/`), os monstros vêm das pinturas
conceituais (`kravenox/arte/conceitos/`), e o fundo é a pintura da Cratera do
Cisma. Letras: Cinzel nos títulos e Alegreya Sans no texto (licença OFL, em
`godot/fontes/`). Origem de cada arquivo em
`versoes-antigas/python/assets/LEIAME.md` (as mesmas artes de `godot/assets/`).

## Som

As músicas são as do RPG 2D (`kravenox-jogar/rpg/music`): **Reino** nos menus, **Abismo** na loja,
**Batalha** nas ondas, **Chefe** na fase do chefe, **Espinhos** contra o
Thornox, e **Vitória** e **Game over** no fim. Os efeitos (golpe,
raio, esmagamento, dano, essência, chefe) são os do Cratera do Cisma. O botão
de alto-falante no alto liga e desliga o som.

## Monstros (do livro e do gibi)

Larva da Essência, Sentinela Esférica, Verme de Dentes e Sentinela do Vazio.
Chefes: **Larva-Mãe** (onda 5), **Sentinela sem Rosto** (onda 10) e
**Thornox** (onda 15).

Versões anteriores guardadas em `versoes-antigas/`: a fogueira em HTML e a
versão em Python (pygame), que deixou de ser atualizada.
