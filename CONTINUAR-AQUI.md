# Kravenox: Quadros do Cisma — para continuar numa conversa nova

Resumo de tudo o que foi feito até 7/11/2026, para continuar o trabalho numa
conversa nova sem perder nada. Leia inteiro antes de mexer.

## Quem é o Rone e como ele trabalha

- Projeto pessoal do Rone (fora do trabalho). Tudo em **português**: texto,
  nomes de arquivo, commits.
- Joga no **iPhone**. Usa o jogo pelo Safari e, a partir de segunda (9/11),
  como app instalado pelo **AltStore** num Mac emprestado.
- **Sem gastar internet:** a franquia dele acabou por causa do jogo. Nada pode
  baixar coisas grandes a cada abertura. O jogo tem que abrir e funcionar
  **sem internet**.
- **Tudo grátis:** não vai pagar a conta da Apple (US$ 99/ano) nem pôr
  anúncios agora (não compensa).
- Gosta de ver resultado no celular, com prints. Responder curto e claro.
- Regras do repositório `The3dig/kravenox` (CLAUDE.md de lá): o livro é o
  cânone; **toda mudança de rumo entra em `decisoes.md`** e a versão anterior
  fica guardada; nunca apagar material.
- **Não copiar o jogo de referência** (Turnaround Adventure): só a ideia de
  gênero (quadros que o personagem percorre, loja, ondas). Arte, nomes e
  conteúdo são do universo Kravenox.

## Repositórios

| Repositório | O que tem | Branch |
|---|---|---|
| `The3dig/kravenox-jogo-casual` | **o jogo** (Godot 4.5 em `godot/`) | `claude/kravenox-ultima-fogueira` (ainda não foi para a `main`) |
| `The3dig/kravenox-jogar` | o site publicado (GitHub Pages): raiz = Cratera do Cisma, `rpg/`, `plataforma/`, `quadros/` = este jogo | `main` (publicação direta) |
| `The3dig/kravenox` | livro, universo, artes, Cratera do Cisma (fonte) | `claude/jogos-offline` (falta juntar na `main`) |
| `The3dig/Gibi-kravenox-` | bíblia e roteiros do gibi | só leitura |

- Jogar no navegador: https://the3dig.github.io/kravenox-jogar/quadros/
- App de iPhone (.ipa, sem assinatura): https://github.com/The3dig/kravenox-jogo-casual/releases/tag/app-iphone
  (montado sozinho pelo workflow `.github/workflows/app-iphone.yml` a cada push em `godot/**`).

## O jogo hoje

Tudo em `godot/scripts/jogo.gd` (um nó só, desenho em `_draw()`).
Versão atual em Ajustes: **2026-11-12e** (código de beta tester: BETA-KRAVENOX) (português e inglês: dicionário em godot/dados/en.json, função tx()) (Loja do Apoiador: 7 toques na versão em Ajustes liberam tudo para testar) (constante `VERSAO`).
Branch de trabalho desde 9/11: `claude/new-session-7fm2ni` (saiu da
`claude/kravenox-ultima-fogueira`).

- **Mecânica:** o Kravenox anda sem parar por um caminho de quadros; cada quadro
  guarda um poder comprado na loja; ao pisar, o poder dispara. Arrastar itens
  da loja para os quadros (ou tocar e tocar); item igual do mesmo nível funde
  (até nível 5).
- **Poderes (10):** Garras, Espinhos Vorazes, Raio da Essência, Esmagamento,
  Rasgo do Abismo, Cristal de Vida, Passo Predador (pula 2 quadros por nível;
  só o quadro onde cai dispara), Corrida do Cisma (nível n: corre 2n× por 2n
  casas, todas disparam), Escudo de Espinhos (escudo azul por cima da vida),
  Fonte de Essência. Liberados aos poucos (`ITEM_DESDE`).
- **Monstros (artes oficiais recortadas):** Larva da Essência, Sentinela
  Esférica, Verme de Dentes (nome provisório), Sentinela do Vazio. Chefes:
  Larva-Mãe, Sentinela sem Rosto, Thornox.
- **Estrutura:** 76 capítulos (35 do Livro I + 41 do Livro II, títulos do RPG)
  em 19 mundos de 4. Cada capítulo: 4 fases (a 4ª com chefe) + **fase bônus**
  (monstros atacam uma torre no meio; se aguentar, fragmentos extras).
- **Caminhos crescem:** 8 quadros no mundo 1 até 20 no fim
  (`CAMINHO_DO_MUNDO`, `FORMAS`).
- **Modo Pesadelo** (libera após o Mundo 1): monstros ×1,8 vida e ×1,4 dano,
  fragmentos em dobro, progresso separado (`feitos_p`, `liberado_p`).
- **Telas:** abertura → início (Poder, fragmentos, Normal/Pesadelo, capítulo
  com setas sobre a ilustração do mundo, Começar/Continuar, Presente do dia,
  Missões do dia, Baús dos mundos, "Fora" = fragmentos que juntam até 12 h,
  barra de abas Melhorias · Bestiário · Batalha · Mundos · Ajustes) → mundos
  (ilustração de cada mundo + 4 capítulos) → capítulo.
- **Tela do Kravenox** (toque no rosto dele): Poder, nível (1 + soma das
  melhorias), 10 formas do livro (Despertar Frágil … Soberano do Reino
  Quebrado) que mudam a cor da aura, atributos, cartas Vida/Ataque/Defesa/
  Crítico, Formas, 12 Conquistas, Bestiário.
- **Melhorias permanentes (7):** vida, essência inicial, força, passo, sorte,
  defesa, crítico — compradas com fragmentos.
- **Progresso salvo** em `user://progresso.json` (no navegador vai para o
  IndexedDB). **Continuar de onde parou:** entre as ondas e a cada compra o
  jogo grava a partida (`prog["partida"]`, com o modo); ao recarregar, a tela
  inicial mostra CONTINUAR (inclusive fase bônus).
- **Música:** trilhas do RPG (`godot/musica/*.ogg`: reino, abismo, batalha,
  chefe, espinhos, vitoria, gameover), com fade. Efeitos do Cratera do Cisma
  (`godot/sons/`).
- **Visual:** fundo = pintura da Cratera; quadros de pedra pré-pintados;
  Kravenox em pixel art com 4 passos (o andar com a estátua 3D foi rejeitado);
  ilustrações dos mundos em `godot/assets/mundos/` (pintadas por
  `godot/ferramentas/pintar_mundos.py`; mundos 1, 2 e 8 usam as pinturas
  oficiais); letras Cinzel e Alegreya Sans.

Origem de cada arte: `versoes-antigas/python/assets/LEIAME.md`.
Histórico de decisões: `decisoes.md` (raiz deste repositório).

## Evoluções de 9/11 (pesquisa de jogos parecidos)

Tudo de `ideias-evolucao.md` entrou (ver `decisoes.md`). Onde fica no código
(`jogo.gd`): constantes `SINERGIAS`, `LENDARIAS`, `BENCAOS`, `TRACOS`,
`PACTOS`, `REGRAS_DESAFIO`, `ECOS`, `CONSTRUCOES`, `NOVIDADES` no topo; a
lógica na seção "evoluções de 9/11/2026" e as telas novas em "telas novas"
(fim do arquivo). `tipo_partida` = capitulo / abismo / desafio. Cada sistema
aparece num capítulo (`liberou(id)`, tabela `NOVIDADES`). Trechos do livro
para Crônicas e eventos: `godot/dados/trechos.json`, gerado por
`godot/ferramentas/extrair_trechos.py` a partir do RPG.
Robô: `-- --robo --abismo --cap=20` e `-- --robo --desafio --cap=30` testam
os modos novos.

## Aba Modos (9/11)

Horda, Colosso, Refúgio e Caçada: seção "modos especiais" no fim do
`jogo.gd` (`comecar_modo`, `atualizar_esp`, `desenhar_esp`, `tela ==
"especial"`, `tipo_partida == "especial"`). Recordes em `prog["modos"]`.
Uma música do RPG por mundo: `MUSICA_MUNDO`.
Sobre vender: a conta da Apple custa ~R$ 550/ano; precisa de ~130-150
pessoas pagando R$ 5. Sugestão dada: testar antes no Google Play (US$ 25 uma
vez) ou itch.io (grátis).

## MMO (não é deste jogo)

O MMO "Reino Quebrado Online" é de outra conversa. Em 10/11 ele foi copiado
para o repositório próprio `The3dig/kravenox-mmo` (falta ligar o GitHub Pages
e, depois, tirar a pasta `mmo/` do `kravenox-jogar`). **Isso fica com a
conversa do MMO**: esta conversa não mexe mais nele. Ao publicar o Quadros,
se a `main` do `kravenox-jogar` tiver mudado, juntar com merge (sem forçar).

## Como trabalhar no jogo

Ferramentas usadas na nuvem (baixar de novo numa sessão nova):

```sh
# Godot 4.5 (Linux)
curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.5-stable/Godot_v4.5-stable_linux.x86_64.zip && unzip g.zip
# modelo de exportação Web (só ele, sem baixar o pacote de 1,3 GB)
python3 godot/ferramentas/baixar_modelo.py web_nothreads_release.zip ~/.local/share/godot/export_templates/4.5.stable
GD=./Godot_v4.5-stable_linux.x86_64
cd godot && $GD --headless --import        # depois de mudar artes
```

- **Testar sem tela (robô):** `$GD --headless -- --robo` joga os capítulos em
  sequência, compra melhorias e imprime `ROBO cap N: venceu/perdeu ... bônus`.
  `-- --robo --cap=60` começa no 60 com melhorias no máximo.
- **Prints:** rodar um script `-s teste.gd` com
  `xvfb-run -a -s "-screen 0 600x900x24" $GD --rendering-driver opengl3 -s teste.gd`
  e salvar `root.get_texture().get_image().save_png(...)`.
- **Publicar no site:** `GODOT=$GD godot/ferramentas/publicar.sh <clone do kravenox-jogar>`
  e depois commit + push na `main` do `kravenox-jogar`. O script exporta, dá
  nomes com impressão digital (`versionar.py`), gera o `sw.js` e copia para
  `quadros/`.
- **Testar no navegador:** servir o `kravenox-jogar` em `http://localhost:PORTA`
  e usar o Chromium do Playwright (390×780 ou 390×844 com
  `deviceScaleFactor: 3`). `pkill -f "http.server ..."` mata o próprio shell:
  matar o servidor pelo PID.
- **Commits:** em português, terminando com
  `Co-Authored-By: Claude ...` e `Claude-Session: ...` (o ambiente informa).

## Sem internet (muito importante)

Guia completo: `The3dig/kravenox` → `jogos/JOGAR-SEM-INTERNET.md`.

- Godot na Web **sem o PWA do Godot** (`progressive_web_app/enabled=false`).
- `versionar.py` renomeia `index.wasm/js/pck` com hash e gera `sw.js` a partir
  de `sw-modelo.js`: arquivos grandes saem do cache; a página sai da cópia
  guardada na hora e a versão nova é buscada por trás (vale na **segunda**
  abertura). Versão nova baixa só o pacote (~6 MB); o motor (38 MB) fica.
- `quadros/index.service.worker.js` = cópia do `sw.js` (para aparelhos que
  tinham o service worker antigo do Godot).
- A raiz (Cratera do Cisma) foi convertida do mesmo jeito à mão;
  RPG e Plataforma: página e `version.json` com prazo de 2,5 s.
- Resolução limitada a 2x (script no `head_include` do `export_presets.cfg`).

## Problema em aberto: o Safari "reinicia" o jogo

- O Rone vê o jogo recarregar enquanto joga (só neste jogo; os outros não).
- Medido e descartado: vazamento de memória (34 MB estável), memória de vídeo
  (23 MB estável). Já feito para aliviar: resolução 2x, brilhos com textura,
  lajes pré-pintadas, sem sombra desfocada (formas por quadro 38 mil → 9 mil).
- Proteção feita: grava a partida **na hora** em que a onda acaba (inclusive
  ao abrir a fase bônus) e volta no modo certo.
- **Próximo passo combinado:** o Rone vai jogar com Música e Efeitos
  desligados (Ajustes). Se parar de reiniciar, o culpado é o áudio (OGG + 8
  canais de efeitos). Suspeitos seguintes: gravações frequentes, service
  worker.
- O app pelo AltStore (segunda) não passa pelo Safari e deve resolver.

## App de iPhone grátis (AltStore no Mac)

- Preset "iOS" no `export_presets.cfg` (só gera o projeto do Xcode; team ID
  falso `KRAVENOX00`; compressão ETC2/ASTC ligada; ícone `icone-1024.png`).
- O workflow compila sem assinatura num Mac do GitHub e publica
  `Kravenox-Quadros-do-Cisma.ipa` (28 MB) na release `app-iphone`.
- Passos para o Rone: AltServer (altstore.io) no Mac → Install AltStore no
  iPhone pelo cabo com o Apple ID → confiar no perfil (Ajustes → Geral → VPN e
  Gerenciamento de Dispositivos) → Modo de Desenvolvedor se pedir → baixar o
  .ipa no Wi-Fi → AltStore → My Apps → + → escolher o arquivo. Renovar a cada
  7 dias (AltServer aberto no mesmo Wi-Fi). Progresso do app é separado do
  site.
- **Não foi testado num iPhone de verdade** — pode precisar de ajuste.

## Pendências

- [ ] Resultado do teste com som desligado (reinício).
- [ ] Instalação do app no iPhone (segunda, 9/11) e corrigir o que aparecer.
- [ ] Juntar `claude/jogos-offline` na `main` do `kravenox` (publicar.sh do
      Cratera que funciona sem internet + o guia). Abrir PR se o Rone pedir.
- [ ] Juntar `claude/kravenox-ultima-fogueira` na `main` deste repositório.
- [ ] Plataforma: copiar o `three.min.js` r128 para dentro do jogo (hoje vem do cdnjs).
- [ ] "Verme de Dentes" é nome provisório (no livro não tem nome).
- [ ] Ideias de loja, anúncios, equipamento, relíquias, desejos, masmorra:
      `ideias-futuras.md` (o Rone decidiu que monetizar **não compensa** agora).

## Histórico rápido do que mudou de rumo

1. Fogueira em HTML → 2. Quadros em Python (pygame) → 3. Godot 4.5 (só ele
agora; Python e HTML em `versoes-antigas/`) → artes detalhadas (recortes das
estátuas 3D e pinturas) → andar volta a ser pixel art → capítulos/mundos/
melhorias → caminhos por mundo e crescentes → Escudo, fase bônus, salto,
Corrida → sem internet → tela inicial nova, mundos ilustrados, Pesadelo →
tela do Kravenox e conquistas. Detalhes e motivos em `decisoes.md`.
