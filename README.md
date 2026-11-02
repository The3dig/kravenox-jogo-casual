# Kravenox: Quadros do Cisma

Jogo casual do universo Kravenox, em **Godot 4.5**, na pasta `godot/` (veja
`godot/LEIAME.md`). Jogar: https://the3dig.github.io/kravenox-jogar/quadros/

O Kravenox anda sem parar por um anel de 12 quadros. Na loja de baixo você
compra poderes e coloca nos quadros; quando ele pisa num quadro, o poder dali
dispara. Ao iniciar a onda, os monstros do Reino Quebrado vêm de todos os
lados. São 15 ondas, com chefe nas ondas 5, 10 e 15.

## Como abrir

No Godot 4.5, importe a pasta `godot/` e aperte F5. Para publicar a versão Web,
rode `godot/ferramentas/publicar.sh`.

## Como se joga

- Toque num item da loja e depois num quadro para colocar (o custo aparece no item).
- Item igual e do mesmo nível no mesmo quadro: os dois se fundem (nível +1, máximo 5).
- Toque num quadro com item para pegá-lo e levar para outro quadro (ou trocar de lugar).
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

As músicas são as do RPG 2D (`kravenox-jogar/rpg/music`): **Abismo** na loja,
**Batalha** nas ondas, **Chefe** nas ondas 5 e 10, **Espinhos** contra o
Thornox na onda 15, e **Vitória** e **Game over** no fim. Os efeitos (golpe,
raio, esmagamento, dano, essência, chefe) são os do Cratera do Cisma. O botão
de alto-falante no alto liga e desliga o som.

## Monstros (do livro e do gibi)

Larva da Essência, Sentinela Esférica, Verme de Dentes e Sentinela do Vazio.
Chefes: **Larva-Mãe** (onda 5), **Sentinela sem Rosto** (onda 10) e
**Thornox** (onda 15).

Versões anteriores guardadas em `versoes-antigas/`: a fogueira em HTML e a
versão em Python (pygame), que deixou de ser atualizada.
