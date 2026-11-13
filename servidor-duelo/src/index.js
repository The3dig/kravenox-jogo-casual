// Kravenox: Quadros do Cisma — servidor do Duelo ao vivo.
//
// Cada sala (código de 4 letras) é um Durable Object que junta 2 jogadores
// por WebSocket. O servidor não roda o jogo: ele só dá a largada (a mesma
// semente da horda para os dois) e repassa as mensagens de um para o outro.
//
// Mensagens (JSON), do jogo para o servidor:
//   {t:"pronto"}                      quero começar (quando os 2 estão prontos, sai a largada)
//   {t:"estado", torre, onda, mortes} como estou (repassado ao outro como t:"op")
//   {t:"ataque", n}                   mando n monstros para o outro
//   {t:"caiu", tempo}                 minha torre caiu
// Do servidor para o jogo:
//   {t:"sala", voce, nomes}           entrou na sala (voce = 0 ou 1)
//   {t:"comecar", semente}            largada
//   {t:"op", ...} / {t:"ataque"} / {t:"caiu"} / {t:"saiu"} vindos do outro
//   {t:"erro", msg}

const CODIGO = /^[A-Z2-9]{4}$/;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const partes = url.pathname.split("/").filter(Boolean);
    if (req.method === "OPTIONS") return new Response(null, { headers: CORS });
    if (partes[0] === "api") return api(req, env, partes.slice(1));
    if (partes.length === 0) {
      return new Response("Kravenox Duelo: ok", { headers: { "content-type": "text/plain; charset=utf-8" } });
    }
    if (partes[0] === "sala-livre" && partes.length >= 2) {
      const cod = partes[1].toUpperCase();
      if (!/^[A-Z0-9_-]{3,32}$/.test(cod)) return new Response("código inválido", { status: 400 });
      if (req.headers.get("Upgrade") !== "websocket") return new Response("use WebSocket", { status: 426 });
      return env.SALAS_LIVRES.get(env.SALAS_LIVRES.idFromName(cod)).fetch(req);
    }
    if (partes[0] !== "sala" || partes.length < 2) return new Response("não encontrado", { status: 404 });
    const codigo = partes[1].toUpperCase();
    if (!CODIGO.test(codigo)) return new Response("código inválido", { status: 400 });
    if (req.headers.get("Upgrade") !== "websocket") return new Response("use WebSocket", { status: 426 });
    const id = env.SALAS.idFromName(codigo);
    return env.SALAS.get(id).fetch(req);
  },
};

export class Sala {
  constructor(state) {
    this.state = state;
    this.jogadores = []; // {ws, nome, pronto}
  }

  async fetch(req) {
    const url = new URL(req.url);
    const nome = (url.searchParams.get("nome") || "Jogador").slice(0, 16);
    const par = new WebSocketPair();
    const [cliente, servidor] = Object.values(par);
    servidor.accept();
    // tira quem já caiu da sala
    this.jogadores = this.jogadores.filter((j) => j.ws.readyState === 1);
    if (this.jogadores.length >= 2) {
      servidor.send(JSON.stringify({ t: "erro", msg: "sala cheia" }));
      servidor.close(1000, "cheia");
      return new Response(null, { status: 101, webSocket: cliente });
    }
    const eu = { ws: servidor, nome, pronto: false };
    this.jogadores.push(eu);
    this.avisarSala();
    servidor.addEventListener("message", (ev) => this.mensagem(eu, ev.data));
    const sair = () => {
      this.jogadores = this.jogadores.filter((j) => j !== eu);
      for (const j of this.jogadores) this.enviar(j, { t: "saiu", nome: eu.nome });
      for (const j of this.jogadores) j.pronto = false;
    };
    servidor.addEventListener("close", sair);
    servidor.addEventListener("error", sair);
    return new Response(null, { status: 101, webSocket: cliente });
  }

  avisarSala() {
    const nomes = this.jogadores.map((j) => j.nome);
    this.jogadores.forEach((j, i) => this.enviar(j, { t: "sala", voce: i, nomes }));
  }

  enviar(j, obj) {
    try { j.ws.send(JSON.stringify(obj)); } catch (e) { /* já saiu */ }
  }

  outro(eu) {
    return this.jogadores.find((j) => j !== eu);
  }

  mensagem(eu, dados) {
    let m;
    try { m = JSON.parse(dados); } catch (e) { return; }
    if (!m || typeof m.t !== "string") return;
    if (m.t === "pronto") {
      eu.pronto = true;
      if (this.jogadores.length === 2 && this.jogadores.every((j) => j.pronto)) {
        const semente = Math.floor(Math.random() * 2147483647);
        for (const j of this.jogadores) { j.pronto = false; this.enviar(j, { t: "comecar", semente }); }
      }
      return;
    }
    const o = this.outro(eu);
    if (!o) return;
    if (m.t === "estado") {
      this.enviar(o, { t: "op", torre: Number(m.torre) || 0, onda: Number(m.onda) || 0, mortes: Number(m.mortes) || 0 });
    } else if (m.t === "ataque") {
      this.enviar(o, { t: "ataque", n: Math.max(1, Math.min(10, Number(m.n) || 1)) });
    } else if (m.t === "caiu") {
      this.enviar(o, { t: "caiu", tempo: Number(m.tempo) || 0 });
    }
  }
}


// ------------------------------------------------------------ ranking semanal e Ordens (13/11)
// API em JSON, só para o jogo:
//   POST /api/recorde        {id, nome, cat, valor, skin}   guarda o melhor da semana
//   GET  /api/ranking?cat=X&id=Y                            top 20 da semana, a sua posição e os campeões da semana passada
//   POST /api/ordem/criar    {id, nome, ordem}              cria uma Ordem (devolve o código de 5 letras)
//   POST /api/ordem/CODIGO/entrar {id, nome}
//   POST /api/ordem/CODIGO/sair   {id}
//   POST /api/ordem/CODIGO/dano   {id, dano}                golpes no Gigante da semana
//   GET  /api/ordem/CODIGO                                  membros, Gigante e contribuições
// Não guarda nada além do nome escolhido no jogo e de um número aleatório do aparelho.

const CATS = ["abismo", "colosso", "duelo"];
// outros jogos do Kravenox: categoria com o nome do jogo na frente (ex.: "mmo-nivel")
const catValida = (c) => CATS.includes(c) || /^[a-z0-9]{2,12}-[a-z0-9_]{2,20}$/.test(c);
const LETRAS = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { "content-type": "application/json; charset=utf-8", ...CORS } });
}

// semana no formato 2026-S46 (segunda-feira a domingo, UTC)
function semana(d = new Date()) {
  const t = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
  const dia = t.getUTCDay() || 7;
  t.setUTCDate(t.getUTCDate() + 4 - dia);
  const ini = new Date(Date.UTC(t.getUTCFullYear(), 0, 1));
  const n = Math.ceil(((t - ini) / 86400000 + 1) / 7);
  return t.getUTCFullYear() + "-S" + String(n).padStart(2, "0");
}

function semanaPassada() {
  return semana(new Date(Date.now() - 7 * 86400000));
}

function limpaNome(n) {
  return String(n || "Jogador").replace(/[<>]/g, "").trim().slice(0, 16) || "Jogador";
}

function limpaId(i) {
  const s = String(i || "");
  return /^[a-z0-9]{8,40}$/.test(s) ? s : null;
}

async function api(req, env, partes) {
  let corpo = {};
  if (req.method === "POST") {
    try { corpo = await req.json(); } catch (e) { return json({ erro: "json inválido" }, 400); }
  }
  const url = new URL(req.url);
  if (partes[0] === "recorde" || partes[0] === "ranking") {
    const ranking = env.RANKING.get(env.RANKING.idFromName("global"));
    return ranking.fetch(new Request("https://interno/" + partes[0] + url.search, { method: req.method, body: req.method === "POST" ? JSON.stringify(corpo) : undefined }));
  }
  if (partes[0] === "ordem") {
    let codigo = (partes[1] || "").toUpperCase();
    let acao = partes[2] || "ver";
    if (codigo === "CRIAR") {
      codigo = "";
      for (let i = 0; i < 5; i++) codigo += LETRAS[Math.floor(Math.random() * LETRAS.length)];
      acao = "criar";
    }
    if (!/^[A-Z2-9]{5}$/.test(codigo)) return json({ erro: "código inválido" }, 400);
    const ordem = env.ORDENS.get(env.ORDENS.idFromName(codigo));
    const quem = encodeURIComponent(url.searchParams.get("id") || "");
    return ordem.fetch(new Request("https://interno/" + acao + "?codigo=" + codigo + "&id=" + quem, { method: req.method, body: req.method === "POST" ? JSON.stringify(corpo) : undefined }));
  }
  return json({ erro: "não encontrado" }, 404);
}

export class Ranking {
  constructor(state) {
    this.storage = state.storage;
  }

  async fetch(req) {
    const url = new URL(req.url);
    const acao = url.pathname.slice(1);
    if (acao === "recorde" && req.method === "POST") {
      const c = await req.json();
      const id = limpaId(c.id);
      const cat = String(c.cat || "");
      const valor = Math.floor(Number(c.valor) || 0);
      if (!id || !catValida(cat) || valor <= 0 || valor > 1e12) return json({ erro: "dados inválidos" }, 400);
      if (id.startsWith("teste")) return json({ ok: true, teste: true });   // testes não entram no ranking
      const chave = "s:" + semana() + ":" + cat;
      const tabela = (await this.storage.get(chave)) || {};
      const antigo = tabela[id];
      // duelo soma vitórias; os outros guardam o melhor da semana
      // "soma": cada envio soma (vitórias); senão guarda o melhor da semana
      const soma = cat === "duelo" || c.soma === true;
      const novo = soma ? (antigo ? antigo.valor : 0) + (cat === "duelo" ? 1 : valor) : Math.max(antigo ? antigo.valor : 0, valor);
      tabela[id] = { nome: limpaNome(c.nome), valor: novo, skin: String(c.skin || "").slice(0, 12) };
      await this.storage.put(chave, tabela);
      return json({ ok: true, valor: novo, ...this.posicao(tabela, id) });
    }
    if (acao === "ranking") {
      const cat = url.searchParams.get("cat") || "abismo";
      if (!catValida(cat)) return json({ erro: "categoria inválida" }, 400);
      const id = limpaId(url.searchParams.get("id"));
      const tabela = (await this.storage.get("s:" + semana() + ":" + cat)) || {};
      const passada = (await this.storage.get("s:" + semanaPassada() + ":" + cat)) || {};
      const lista = this.ordenar(tabela);
      return json({
        semana: semana(),
        cat,
        top: lista.slice(0, 20).map(([i, v], k) => ({ pos: k + 1, nome: v.nome, valor: v.valor, skin: v.skin, eu: i === id })),
        ...this.posicao(tabela, id),
        campeoes: this.ordenar(passada).slice(0, 3).map(([i, v], k) => ({ pos: k + 1, nome: v.nome, valor: v.valor, eu: i === id })),
      });
    }
    return json({ erro: "não encontrado" }, 404);
  }

  ordenar(tabela) {
    return Object.entries(tabela).filter(([i]) => !i.startsWith("teste")).sort((a, b) => b[1].valor - a[1].valor);
  }

  posicao(tabela, id) {
    const lista = this.ordenar(tabela);
    const k = lista.findIndex(([i]) => i === id);
    return { minha_pos: k >= 0 ? k + 1 : 0, total: lista.length };
  }
}

// Gigante da Ordem: a vida cresce com o número de membros. Cada partida no
// Colosso soma "golpes" (dano dividido pelo dano básico do jogador, para o
// nível não pesar demais). Toda segunda-feira nasce um Gigante novo.
const GOLPES_POR_MEMBRO = 2500;

export class Ordem {
  constructor(state) {
    this.storage = state.storage;
  }

  async dados(codigo) {
    let d = await this.storage.get("ordem");
    if (d && d.semana !== semana()) {
      // semana nova: guarda o resultado da passada e zera o Gigante
      d.passada = { semana: d.semana, derrubado: d.derrubado };
      d.semana = semana();
      d.golpes = 0;
      d.derrubado = false;
      for (const m of Object.values(d.membros)) m.golpes = 0;
      await this.storage.put("ordem", d);
    }
    return d;
  }

  vista(d, codigo, id) {
    const membros = Object.entries(d.membros).map(([i, m]) => ({ nome: m.nome, golpes: m.golpes, eu: i === id })).sort((a, b) => b.golpes - a.golpes);
    const vida = GOLPES_POR_MEMBRO * Math.max(1, membros.length);
    return { codigo, nome: d.nome, semana: d.semana, membros, gigante_vida: vida, gigante_golpes: Math.min(vida, d.golpes), derrubado: d.derrubado, passada: d.passada || null };
  }

  async fetch(req) {
    const url = new URL(req.url);
    const acao = url.pathname.slice(1);
    const codigo = url.searchParams.get("codigo");
    const c = req.method === "POST" ? await req.json() : {};
    const id = limpaId(c.id || url.searchParams.get("id"));
    let d = await this.dados(codigo);
    if (acao === "criar") {
      if (d) return json({ erro: "tente de novo" }, 409);
      if (!id) return json({ erro: "dados inválidos" }, 400);
      d = { nome: limpaNome(c.ordem || "Ordem"), semana: semana(), golpes: 0, derrubado: false, membros: {} };
      d.membros[id] = { nome: limpaNome(c.nome), golpes: 0 };
      await this.storage.put("ordem", d);
      return json(this.vista(d, codigo, id));
    }
    if (!d) return json({ erro: "Ordem não encontrada" }, 404);
    if (acao === "entrar") {
      if (!id) return json({ erro: "dados inválidos" }, 400);
      if (!d.membros[id] && Object.keys(d.membros).length >= 30) return json({ erro: "Ordem cheia (30)" }, 409);
      d.membros[id] = d.membros[id] || { nome: limpaNome(c.nome), golpes: 0 };
      d.membros[id].nome = limpaNome(c.nome);
      await this.storage.put("ordem", d);
    } else if (acao === "sair") {
      if (id && d.membros[id]) {
        delete d.membros[id];
        await this.storage.put("ordem", d);
      }
      return json({ ok: true });
    } else if (acao === "dano") {
      if (!id || !d.membros[id]) return json({ erro: "você não é desta Ordem" }, 403);
      const golpes = Math.max(0, Math.min(3000, Math.floor(Number(c.dano) || 0)));
      d.membros[id].golpes += golpes;
      d.golpes += golpes;
      const vida = GOLPES_POR_MEMBRO * Math.max(1, Object.keys(d.membros).length);
      if (d.golpes >= vida) d.derrubado = true;
      await this.storage.put("ordem", d);
    }
    return json(this.vista(d, codigo, id));
  }
}


// ------------------------------------------------------------ sala livre (14/11), para outros jogos
// wss://.../sala-livre/CODIGO?nome=X : até 8 jogadores. Tudo o que um manda
// (JSON com "t") vai para os outros, com "de" (número do jogador) e "nome".
// O servidor avisa {t:"sala", voce, nomes} quando alguém entra ou sai.
export class SalaLivre {
  constructor(state) {
    this.jogadores = [];
    this.proximo = 0;
  }

  async fetch(req) {
    const url = new URL(req.url);
    const nome = (url.searchParams.get("nome") || "Jogador").replace(/[<>]/g, "").slice(0, 16);
    const par = new WebSocketPair();
    const [cliente, servidor] = Object.values(par);
    servidor.accept();
    this.jogadores = this.jogadores.filter((j) => j.ws.readyState === 1);
    if (this.jogadores.length >= 8) {
      servidor.send(JSON.stringify({ t: "erro", msg: "sala cheia" }));
      servidor.close(1000, "cheia");
      return new Response(null, { status: 101, webSocket: cliente });
    }
    const eu = { ws: servidor, nome, n: this.proximo++ };
    this.jogadores.push(eu);
    this.avisar();
    servidor.addEventListener("message", (ev) => {
      if (typeof ev.data !== "string" || ev.data.length > 4000) return;
      let m;
      try { m = JSON.parse(ev.data); } catch (e) { return; }
      if (!m || typeof m.t !== "string") return;
      m.de = eu.n;
      m.nome = eu.nome;
      const txt = JSON.stringify(m);
      for (const j of this.jogadores) if (j !== eu) { try { j.ws.send(txt); } catch (e) {} }
    });
    const sair = () => { this.jogadores = this.jogadores.filter((j) => j !== eu); this.avisar(); };
    servidor.addEventListener("close", sair);
    servidor.addEventListener("error", sair);
    return new Response(null, { status: 101, webSocket: cliente });
  }

  avisar() {
    const nomes = this.jogadores.map((j) => ({ n: j.n, nome: j.nome }));
    for (const j of this.jogadores) { try { j.ws.send(JSON.stringify({ t: "sala", voce: j.n, jogadores: nomes })); } catch (e) {} }
  }
}
