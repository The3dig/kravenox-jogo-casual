# Ideias de evolução (pesquisa de 8/11/2026)

O que outros jogos do mesmo gênero fazem para prender quem joga, e como isso
pode virar coisa do universo Kravenox. Tudo aqui funciona **sem internet** e
**sem dinheiro de verdade**. A regra continua: pegar a *ideia*, nunca a arte,
os nomes ou o conteúdo de outro jogo.

> **Feito em 9/11/2026 (versão 2026-11-09a).** Tudo abaixo entrou no jogo, com
> duas diferenças: o Modo Pesadelo continua (os Pactos somam a ele) e o "mapa
> com bifurcação" virou a **Encruzilhada** depois da fase 2. Detalhes em
> `decisoes.md`.

Complementa `ideias-futuras.md` (equipamento, relíquias, desejos e masmorra,
vistos no Turnaround Adventure). Aqui não repeti esses.

## Jogos analisados

| Jogo | O que ele faz bem | O que serve para nós |
|---|---|---|
| **Loop Hero** | caminho em anel com quadros colocados pelo jogador; quadros vizinhos se combinam e criam efeitos novos, alguns secretos | sinergia de vizinhança entre os quadros |
| **Vampire Survivors** | item no máximo + item certo = arma "evoluída"; lista de segredos a descobrir | evoluções lendárias dos poderes |
| **Archero / Survivor.io** | a cada nível, escolher 1 de 3 habilidades; elites com efeitos | escolha entre as ondas |
| **Slay the Spire** | mapa com bifurcações (elite, loja, evento, descanso); relíquias | caminho do capítulo com escolhas |
| **Balatro / Hades** | o jogador liga dificuldades extras (apostas, "Calor") em troca de recompensa | Pactos do Abismo no lugar do Pesadelo de um botão só |
| **Capybara Go!** | eventos de texto curtos com escolha; funções liberadas aos poucos por semanas; recompensa ao voltar depois de muito tempo | eventos do livro entre as fases; liberar abas aos poucos |
| **Luck be a Landlord / Backpack Hero** | posição importa: o mesmo item vale mais ou menos conforme os vizinhos | reforça a sinergia de vizinhança |
| **Desafios diários (vários)** | partida do dia igual para todo mundo, gerada pela data | dá para fazer sem servidor: a data é a semente |

O que todos eles têm em comum: **a cada partida o jogador descobre ou decide
alguma coisa nova**. Hoje no Quadros do Cisma a decisão é só "qual item comprar
e onde pôr". As ideias abaixo aumentam as decisões e as descobertas.

## As 5 que eu faria primeiro (mais efeito, menos trabalho)

### 1. Vizinhos que se combinam
Dois quadros lado a lado com certos poderes ganham um efeito extra. Uma
correntinha de luz roxa liga os dois para mostrar que combinaram.

| Vizinhos | Efeito |
|---|---|
| Garras + Espinhos Vorazes | **Sangria**: o monstro perde vida por 3 s |
| Raio da Essência + Fonte de Essência | o raio custa nada e dá +1 de essência |
| Cristal de Vida + Escudo de Espinhos | cura também enche o escudo |
| Esmagamento + Rasgo do Abismo | o rasgo atinge todos os monstros em volta |
| Passo Predador + qualquer ataque | o quadro onde cai bate em dobro |

Faz o jogador pensar na *ordem* dos quadros, não só no nível. Algumas duplas
podem ficar **secretas** e aparecer num "Grimório de Combinações" quando
descobertas.

### 2. Evoluções lendárias
Poder no nível 5 + outro poder certo no caminho = na próxima onda ele vira uma
forma lendária, com arte e nome novos. Exemplos:
- Garras 5 + Passo Predador → **Garras do Predador** (cada salto dá um corte)
- Espinhos Vorazes 5 + Escudo de Espinhos → **Coroa de Espinhos**
- Rasgo do Abismo 5 + Fonte de Essência → **Fenda do Vazio**

Dá um objetivo dentro da partida e uma lista para completar.

### 3. Escolha 1 de 3 entre as ondas
Ao fim de cada onda aparecem 3 cartas de **Bênção** (só valem na partida):
"+20% de dano em quadros de canto", "monstros dão +1 fragmento", "o primeiro
quadro dispara duas vezes"... Às vezes vem uma **Bênção Sombria**: ganho grande
com custo ("dano ×2, vida −30%").

### 4. Eventos do livro entre as fases
Telinha com um trecho curto do capítulo e duas escolhas. Exemplo: "A fogueira
ainda queima. **Descansar** (+40% de vida) ou **Ouvir as vozes** (+1 poder
aleatório, −15% de vida)". O texto vem dos capítulos do livro, então o jogo
também conta a história, e o livro continua sendo o cânone.

### 5. Sentir os golpes (polimento)
Coisas pequenas que deixam o jogo gostoso de jogar:
- números de dano saltando, maiores e dourados no crítico;
- tremor de tela no esmagamento e no golpe do chefe;
- câmera lenta de meio segundo quando o chefe morre;
- **vibração** do iPhone nos golpes fortes (`Input.vibrate_handheld`, no app);
- contador de combo quando vários quadros disparam em sequência;
- botão de **velocidade 2×**.

## Dentro da partida (mais ideias)

- **Monstros de elite com traços**: Blindado (só leva meio dano das Garras),
  Veloz, Vampiro (cura ao bater), Divisor (vira dois menores). Brilho de cor
  diferente.
- **Quadros de terreno** que já vêm no caminho e mudam por mundo: Fenda (dano
  ×1,5 ali), Altar (cura um pouco), Pedra Amaldiçoada (não aceita poder, mas
  dá fragmentos ao passar).
- **Mapa do capítulo com bifurcação**: depois da fase 1 e da 2, escolher o
  próximo nó: Combate, Elite (mais difícil, recompensa melhor), Loja barata,
  Evento, Fogueira (descanso).
- **Risco ou volta** (do Loop Hero): depois da fase bônus, botão "Voltar
  agora" com o que juntou ou "Mais uma onda" com recompensa crescente, e se
  perder fica só com metade.
- **Fúria do Kravenox**: barra que enche com os golpes; cheia, o jogador toca
  e solta um golpe especial da forma atual dele (cada uma das 10 formas com o
  seu).

## Fora da partida (o que faz voltar no dia seguinte)

- **Pactos do Abismo** (no lugar do Pesadelo de um botão só): lista de
  maldições que o jogador liga e desliga ("monstros mais rápidos", "loja mais
  cara", "sem cura"…). Cada uma soma pontos de Pacto e multiplica os
  fragmentos. Recorde de Pacto por capítulo.
- **Abismo sem Fim**: modo infinito que libera depois do Mundo 1, ondas cada
  vez mais fortes, **recorde pessoal** guardado no aparelho.
- **Desafio do Dia**: a data do dia gera um capítulo com regras fixas (ex.:
  "só Garras e Raio", "chefe duplo"). Igual para todo mundo, sem internet.
  Recompensa grande uma vez por dia.
- **Crônicas**: ao vencer um capítulo pela primeira vez, libera um trecho do
  livro e uma ilustração numa galeria. Quem gosta do jogo conhece o livro.
- **Bestiário com história**: matar 10, 50, 100 de um monstro libera a
  ficha completa dele (do `universo/`), e +2% de dano contra ele.
- **Companheiro**: um bichinho do universo que segue o Kravenox e tem um
  poder pequeno (cura, pega fragmentos, ataca de vez em quando). Liberados
  pelos baús dos mundos.
- **Acampamento**: lugar que o jogador reconstrói com fragmentos (forja,
  altar, biblioteca); cada construção libera um sistema (a forja libera
  equipamento, a biblioteca as Crônicas…). Dá sentido aos fragmentos depois
  que as melhorias acabam.
- **Liberar aos poucos**: em vez de mostrar todas as abas no começo, cada uma
  aparece com um aviso ("Nova: Bestiário!") num capítulo diferente. O jogador
  sempre tem algo novo para ver nas primeiras semanas.
- **Volta depois de muito tempo**: se ficou 3 dias ou mais sem jogar, um
  presente maior e "Fúria" mais fácil nas 3 primeiras partidas.
- **Sequência de 7 dias**: presente do dia que cresce se jogar dias seguidos;
  no 7º dia, um item raro. (Perder um dia não zera, só volta 2 casas.)

## Como encaixar no código hoje

Tudo cabe no `jogo.gd` como está. A ordem que eu sugiro:

1. Polimento (números de dano, tremor, vibração, 2×) — mais barato, muda a
   sensação na hora.
2. Vizinhos que se combinam + Grimório.
3. Escolha 1 de 3 entre as ondas.
4. Evoluções lendárias (precisam de 3 artes novas).
5. Eventos do livro (precisam escolher os trechos dos capítulos).
6. Desafio do Dia e Abismo sem Fim.
7. Pactos do Abismo (substituir o Pesadelo, com registro em `decisoes.md`).
8. Acampamento, companheiros e Crônicas (sistemas grandes).

## Fontes da pesquisa

- [Game Design Breakdown: Loop Hero](https://medium.com/@sacitsivri/game-design-breakdown-loop-hero-4a86d55142b8)
- [PC Gamer: Loop Hero](https://pcgamer.com/loop-hero-is-the-years-first-slam-dunk)
- [Game Wisdom: Loop Hero Feels Stuck on Repeat](https://game-wisdom.com/?p=26046)
- [Capybara Go: estudo de caso](https://mechanics-playbook-next.pages.dev/case-studies/capybara-go/)
- [Meta progressão em jogos mobile (iLogos)](https://ilogos.biz/how-to-add-meta-progression-to-a-mobile-game/)
- [Como desenhar meta progressão em roguelites](https://bugnet.io/blog/how-to-design-a-roguelite-meta-progression)
- [Turnaround Adventure (BlueStacks)](https://www.bluestacks.com/campaign/com.zzdmx.sfgame/vi/)
- Os demais (Vampire Survivors, Archero, Slay the Spire, Balatro, Hades,
  Luck be a Landlord, Backpack Hero) a partir do conhecimento geral desses
  jogos.
