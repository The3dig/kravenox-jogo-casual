# Kravenox: Quadros do Cisma

Jogo casual do universo Kravenox, em **Godot 4.5**, na pasta `godot/` (veja
`godot/LEIAME.md`). Jogar: https://the3dig.github.io/kravenox-jogar/quadros/

O Kravenox anda sem parar por um anel de 12 quadros. Na loja de baixo você
compra poderes e coloca nos quadros; quando ele pisa num quadro, o poder dali
dispara. Entre as ondas ele espera no meio do anel.

## Estrutura

- **76 capítulos**, um para cada capítulo do livro (35 do Livro I e 41 do
  Livro II), com os títulos do RPG.
- **19 mundos** de 4 capítulos cada. O mapa dos mundos mostra o que já foi
  vencido, o próximo capítulo e o que ainda está trancado.
- **4 fases por capítulo**; a 4ª tem chefe: Larva-Mãe nos dois primeiros
  capítulos de cada mundo, Sentinela sem Rosto no terceiro e Thornox no último.
- **Começa simples:** no capítulo 1 só existem Garras, Espinhos e Cristal e só
  aparece a Larva. Os outros poderes e monstros entram aos poucos (Raio no 2,
  Passo no 3, Esmagamento no 5, Fonte no 7, Rasgo no 9; Sentinela Esférica no
  2, Verme no 4, Sentinela do Vazio no 6).
- **Descrições:** cada item da loja tem uma frase curta; ao tocar no item (ou
  num quadro ocupado) aparece a explicação completa.
- **Melhorias:** cada capítulo dá fragmentos (mais na primeira vitória). Na
  tela de Melhorias eles viram vida, essência inicial, dano, velocidade e
  trocas grátis, que valem para todos os capítulos.
- O progresso fica salvo no aparelho.

## Telas

Abertura (logo e carregamento) → Início (Jogar, Melhorias, Bestiário, Som) →
Mundos → Capítulo. O Bestiário mostra os monstros já encontrados.

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

| Poder | O que faz quando ele pisa |
|---|---|
| Garras | golpe em volta dele |
| Espinhos | 8 espinhos para todos os lados |
| Raio da Essência | raio em cadeia nos monstros mais perto |
| Esmagamento | dano numa área grande |
| Rasgo do Abismo | corte que atravessa os monstros |
| Cristal de Vida | cura |
| Passo Predador | ele anda mais rápido por um tempo |
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
