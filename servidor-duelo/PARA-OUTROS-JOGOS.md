# Servidor online do Kravenox: como outros jogos podem usar

Servidor: **https://kravenox-duelo.kravenox.workers.dev** (Cloudflare Workers,
conta do Rone, plano grátis). Código: `The3dig/kravenox-jogo-casual`, pasta
`servidor-duelo/`, branch `claude/new-session-7fm2ni`.

Regras:
- **Só a parte online usa internet.** O jogo tem que funcionar sem ela; se a
  chamada falhar, guarde e mande depois (o Quadros guarda em `pendentes_online`).
- **Não mude nem apague o que o Quadros do Cisma usa** (`/sala/…`,
  `/api/recorde` e `/api/ranking` com as categorias `abismo`, `colosso`, `duelo`,
  e `/api/ordem/…`). Se precisar mudar o servidor, combine com o Rone antes.
- O servidor não guarda nada pessoal: só o nome escolhido no jogo e um número
  aleatório do aparelho (`id`, 8 a 40 letras minúsculas/números, criado e
  guardado pelo próprio jogo). Ids que começam com `teste` não entram no ranking
  (use para testar).
- Todas as respostas têm CORS liberado (o jogo no GitHub Pages pode chamar).

## 1. Ranking semanal (qualquer jogo)

Categoria com o nome do jogo na frente: `mmo-nivel`, `mmo-chefes`, `plataforma-tempo`…
(formato `jogo-coisa`, letras minúsculas, números e `_`).

```
POST /api/recorde   {"id": "...", "nome": "Rone", "cat": "mmo-nivel", "valor": 42, "skin": ""}
     → {"ok": true, "valor": 42, "minha_pos": 1, "total": 7}
     guarda o MAIOR valor da semana. Com "soma": true, soma (ex.: vitórias, chefes derrotados).
GET  /api/ranking?cat=mmo-nivel&id=...
     → {"semana": "2026-S46", "top": [{"pos", "nome", "valor", "skin", "eu"}...20],
        "minha_pos", "total", "campeoes": [top 3 da semana passada]}
```
A semana vai de segunda a domingo (UTC) e recomeça sozinha.

## 2. Ordem (clã) — compartilhada entre os jogos

A mesma Ordem do Quadros pode ser usada no MMO (o código de 5 letras é o mesmo).

```
POST /api/ordem/criar          {"id", "nome", "ordem": "Nome da Ordem"} → {"codigo": "7NQT3", ...}
POST /api/ordem/CODIGO/entrar  {"id", "nome"}
POST /api/ordem/CODIGO/sair    {"id"}
POST /api/ordem/CODIGO/dano    {"id", "dano": golpes}   (até 3000 por envio)
GET  /api/ordem/CODIGO?id=...  → {"nome", "membros": [{"nome", "golpes", "eu"}], "gigante_vida", "gigante_golpes", "derrubado", "semana"}
```
O "Gigante da semana" tem 2500 golpes por membro. Se o MMO mandar golpes (por
exemplo, ao derrotar chefes), eles somam com os do Quadros: é a Ordem de todo
o universo Kravenox.

## 3. Sala livre (tempo real, até 8 jogadores)

```
WebSocket: wss://kravenox-duelo.kravenox.workers.dev/sala-livre/CODIGO?nome=Rone
CODIGO: 3 a 32 caracteres (A-Z, 0-9, _ e -), ex.: "MMO-REINO-1" ou o código de uma Ordem.
```
- Ao entrar ou sair alguém, todos recebem `{"t": "sala", "voce": n, "jogadores": [{"n", "nome"}]}`.
- Tudo o que um manda (JSON com `"t"`, até 4000 caracteres) chega aos outros
  com `"de": n` e `"nome"`. Ex.: `{"t": "pos", "x": 10, "y": 20}`,
  `{"t": "chat", "msg": "oi"}`, `{"t": "golpe", "alvo": 3}`.
- O servidor não guarda nada nem confere o jogo: só repassa. Mande posição no
  máximo ~5 vezes por segundo.
- Com a 9ª pessoa: `{"t": "erro", "msg": "sala cheia"}`.

## Pôr no ar uma mudança no servidor

Só se combinar com o Rone. A chave da Cloudflare fica no ambiente
"Kravenox jogos" do Claude Code (nunca no repositório):
```sh
cd servidor-duelo
CLOUDFLARE_API_TOKEN=proxy-injected CLOUDFLARE_ACCOUNT_ID=<conta> npx wrangler@4 deploy
```
Para testar de dentro do Claude Code, o endereço
`kravenox-duelo.kravenox.workers.dev` já está liberado nesse ambiente.
