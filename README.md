# Kravenox: Quadros do Cisma

Jogo casual do universo Kravenox, em **Python (pygame)**.

O Kravenox anda sem parar por um anel de 12 quadros. Na loja de baixo você
compra poderes e coloca nos quadros; quando ele pisa num quadro, o poder dali
dispara. Ao iniciar a onda, os monstros do Reino Quebrado vêm de todos os
lados. São 15 ondas, com chefe nas ondas 5, 10 e 15.

## Como rodar

```
pip install pygame-ce
python kravenox_quadros.py
```

## Como se joga

- Toque num item da loja e depois num quadro para colocar (o custo aparece no item).
- Item igual e do mesmo nível no mesmo quadro: os dois se fundem (nível +1, máximo 5).
- Toque num quadro com item para pegá-lo e levar para outro quadro (ou trocar de lugar).
- **Lixo:** toque nele e depois num quadro para vender o item pela metade.
- **Trocar:** sorteia outros 3 itens (a primeira troca de cada onda é grátis, depois custa 2).
- **Iniciar onda** (ou espaço) começa a onda. **x1/x2** acelera.
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

## Monstros (do livro e do gibi)

Larva da Essência, Sentinela Esférica, Sentinela do Vazio, Sombra e
Devorador Menor. Chefes: **Larva-Mãe** (onda 5), **A Coisa que Dormia**
(onda 10) e **O Devorador** (onda 15).

Os sprites estão em `assets/` (origem em `assets/LEIAME.md`).

A primeira versão (fogueira em HTML) está guardada em `versoes-antigas/`.
