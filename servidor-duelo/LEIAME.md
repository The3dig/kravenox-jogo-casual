# Servidor do Duelo ao vivo

Só o modo **Duelo ao vivo** do Quadros do Cisma usa internet; o resto do jogo
funciona sem ela. Este servidor roda na Cloudflare (Workers + Durable
Objects, plano grátis) e só junta os dois jogadores de uma sala, dá a largada
e repassa vida, onda e ataques. Ele não guarda nada.

## Pôr no ar

```sh
cd servidor-duelo
npx wrangler@4 deploy      # precisa de CLOUDFLARE_API_TOKEN e CLOUDFLARE_ACCOUNT_ID (o wrangler 3 dá erro 10013)
```

No ar desde 13/11/2026 em `https://kravenox-duelo.kravenox.workers.dev` (conta Cloudflare do Rone). O endereço vai em
`SERVIDOR_DUELO` no `godot/scripts/jogo.gd` (com `wss://`).

## Testar no computador

```sh
npx wrangler dev           # sobe em http://localhost:8787
```

## Contas (15/11/2026)

- `POST /api/conta/criar {usuario, senha, id}` cria a conta e liga ao número
  do jogador (`id`).
- `POST /api/conta/entrar {usuario, senha, id}` devolve `{nome, id}` da conta;
  o jogo passa a usar esse `id` (mesmo jogador em vários celulares).
- Nas categorias do Kravenox (`poder`, `abismo`, `colosso`, `duelo`) o
  `/api/recorde` só aceita quem tem conta e usa o nome da conta. Categorias de
  outros jogos (`jogo-coisa`) não mudaram.
- A senha não é guardada: só hash PBKDF2-SHA256 (100 mil voltas, sal de 16
  bytes). 10 erros seguidos travam o login por 15 min.

## Perfil e sugestões (15/11/2026)

- `POST /api/perfil {id, poder, skin, titulo, abismo, capitulos, pesadelo, skins}`
  (precisa de conta) e `GET /api/perfil?nome=X`.
- `POST /api/sugestao {id, texto}` (precisa de conta, até 10 por dia).
- `POST /api/sugestoes {id, token}` lista as últimas 100; só para usuários em
  `ADMINS` no `wrangler.toml` (separados por vírgula). O token vem no
  `/api/conta/criar` e no `/api/conta/entrar`.

## Progresso na conta (16/11/2026)

- `POST /api/save/guardar {id, token, save, tamanho, forcar}`: guarda o save
  (até 400 mil letras). Recusa (`menor: true`) se `tamanho` for menos da
  metade do guardado, a não ser com `forcar`. A versão anterior fica em
  `sv_ant:<id>`.
- `POST /api/save/carregar {id, token}`: devolve `{save, tamanho, t}`.
