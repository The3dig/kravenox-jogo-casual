# Servidor do Duelo ao vivo

Só o modo **Duelo ao vivo** do Quadros do Cisma usa internet; o resto do jogo
funciona sem ela. Este servidor roda na Cloudflare (Workers + Durable
Objects, plano grátis) e só junta os dois jogadores de uma sala, dá a largada
e repassa vida, onda e ataques. Ele não guarda nada.

## Pôr no ar

```sh
cd servidor-duelo
npx wrangler deploy        # precisa de CLOUDFLARE_API_TOKEN e CLOUDFLARE_ACCOUNT_ID
```

Depois, o endereço (`https://kravenox-duelo.<sua-conta>.workers.dev`) vai em
`SERVIDOR_DUELO` no `godot/scripts/jogo.gd` (com `wss://`).

## Testar no computador

```sh
npx wrangler dev           # sobe em http://localhost:8787
```
