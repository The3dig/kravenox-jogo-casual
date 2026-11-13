var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/index.js
var CODIGO = /^[A-Z2-9]{4}$/;
var CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type"
};
var src_default = {
  async fetch(req, env) {
    const url = new URL(req.url);
    const partes = url.pathname.split("/").filter(Boolean);
    if (req.method === "OPTIONS")
      return new Response(null, { headers: CORS });
    if (partes[0] === "api")
      return api(req, env, partes.slice(1));
    if (partes.length === 0) {
      return new Response("Kravenox Duelo: ok", { headers: { "content-type": "text/plain; charset=utf-8" } });
    }
    if (partes[0] !== "sala" || partes.length < 2)
      return new Response("n\xE3o encontrado", { status: 404 });
    const codigo = partes[1].toUpperCase();
    if (!CODIGO.test(codigo))
      return new Response("c\xF3digo inv\xE1lido", { status: 400 });
    if (req.headers.get("Upgrade") !== "websocket")
      return new Response("use WebSocket", { status: 426 });
    const id = env.SALAS.idFromName(codigo);
    return env.SALAS.get(id).fetch(req);
  }
};
var Sala = class {
  constructor(state) {
    this.state = state;
    this.jogadores = [];
  }
  async fetch(req) {
    const url = new URL(req.url);
    const nome = (url.searchParams.get("nome") || "Jogador").slice(0, 16);
    const par = new WebSocketPair();
    const [cliente, servidor] = Object.values(par);
    servidor.accept();
    this.jogadores = this.jogadores.filter((j) => j.ws.readyState === 1);
    if (this.jogadores.length >= 2) {
      servidor.send(JSON.stringify({ t: "erro", msg: "sala cheia" }));
      servidor.close(1e3, "cheia");
      return new Response(null, { status: 101, webSocket: cliente });
    }
    const eu = { ws: servidor, nome, pronto: false };
    this.jogadores.push(eu);
    this.avisarSala();
    servidor.addEventListener("message", (ev) => this.mensagem(eu, ev.data));
    const sair = /* @__PURE__ */ __name(() => {
      this.jogadores = this.jogadores.filter((j) => j !== eu);
      for (const j of this.jogadores)
        this.enviar(j, { t: "saiu", nome: eu.nome });
      for (const j of this.jogadores)
        j.pronto = false;
    }, "sair");
    servidor.addEventListener("close", sair);
    servidor.addEventListener("error", sair);
    return new Response(null, { status: 101, webSocket: cliente });
  }
  avisarSala() {
    const nomes = this.jogadores.map((j) => j.nome);
    this.jogadores.forEach((j, i) => this.enviar(j, { t: "sala", voce: i, nomes }));
  }
  enviar(j, obj) {
    try {
      j.ws.send(JSON.stringify(obj));
    } catch (e) {
    }
  }
  outro(eu) {
    return this.jogadores.find((j) => j !== eu);
  }
  mensagem(eu, dados) {
    let m;
    try {
      m = JSON.parse(dados);
    } catch (e) {
      return;
    }
    if (!m || typeof m.t !== "string")
      return;
    if (m.t === "pronto") {
      eu.pronto = true;
      if (this.jogadores.length === 2 && this.jogadores.every((j) => j.pronto)) {
        const semente = Math.floor(Math.random() * 2147483647);
        for (const j of this.jogadores) {
          j.pronto = false;
          this.enviar(j, { t: "comecar", semente });
        }
      }
      return;
    }
    const o = this.outro(eu);
    if (!o)
      return;
    if (m.t === "estado") {
      this.enviar(o, { t: "op", torre: Number(m.torre) || 0, onda: Number(m.onda) || 0, mortes: Number(m.mortes) || 0 });
    } else if (m.t === "ataque") {
      this.enviar(o, { t: "ataque", n: Math.max(1, Math.min(10, Number(m.n) || 1)) });
    } else if (m.t === "caiu") {
      this.enviar(o, { t: "caiu", tempo: Number(m.tempo) || 0 });
    }
  }
};
__name(Sala, "Sala");
var CATS = ["abismo", "colosso", "duelo"];
var LETRAS = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { "content-type": "application/json; charset=utf-8", ...CORS } });
}
__name(json, "json");
function semana(d = /* @__PURE__ */ new Date()) {
  const t = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
  const dia = t.getUTCDay() || 7;
  t.setUTCDate(t.getUTCDate() + 4 - dia);
  const ini = new Date(Date.UTC(t.getUTCFullYear(), 0, 1));
  const n = Math.ceil(((t - ini) / 864e5 + 1) / 7);
  return t.getUTCFullYear() + "-S" + String(n).padStart(2, "0");
}
__name(semana, "semana");
function semanaPassada() {
  return semana(new Date(Date.now() - 7 * 864e5));
}
__name(semanaPassada, "semanaPassada");
function limpaNome(n) {
  return String(n || "Jogador").replace(/[<>]/g, "").trim().slice(0, 16) || "Jogador";
}
__name(limpaNome, "limpaNome");
function limpaId(i) {
  const s = String(i || "");
  return /^[a-z0-9]{8,40}$/.test(s) ? s : null;
}
__name(limpaId, "limpaId");
async function api(req, env, partes) {
  let corpo = {};
  if (req.method === "POST") {
    try {
      corpo = await req.json();
    } catch (e) {
      return json({ erro: "json inv\xE1lido" }, 400);
    }
  }
  const url = new URL(req.url);
  if (partes[0] === "recorde" || partes[0] === "ranking") {
    const ranking = env.RANKING.get(env.RANKING.idFromName("global"));
    return ranking.fetch(new Request("https://interno/" + partes[0] + url.search, { method: req.method, body: req.method === "POST" ? JSON.stringify(corpo) : void 0 }));
  }
  if (partes[0] === "ordem") {
    let codigo = (partes[1] || "").toUpperCase();
    let acao = partes[2] || "ver";
    if (codigo === "CRIAR") {
      codigo = "";
      for (let i = 0; i < 5; i++)
        codigo += LETRAS[Math.floor(Math.random() * LETRAS.length)];
      acao = "criar";
    }
    if (!/^[A-Z2-9]{5}$/.test(codigo))
      return json({ erro: "c\xF3digo inv\xE1lido" }, 400);
    const ordem = env.ORDENS.get(env.ORDENS.idFromName(codigo));
    const quem = encodeURIComponent(url.searchParams.get("id") || "");
    return ordem.fetch(new Request("https://interno/" + acao + "?codigo=" + codigo + "&id=" + quem, { method: req.method, body: req.method === "POST" ? JSON.stringify(corpo) : void 0 }));
  }
  return json({ erro: "n\xE3o encontrado" }, 404);
}
__name(api, "api");
var Ranking = class {
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
      if (!id || !CATS.includes(cat) || valor <= 0 || valor > 1e12)
        return json({ erro: "dados inv\xE1lidos" }, 400);
      const chave = "s:" + semana() + ":" + cat;
      const tabela = await this.storage.get(chave) || {};
      const antigo = tabela[id];
      const novo = cat === "duelo" ? (antigo ? antigo.valor : 0) + 1 : Math.max(antigo ? antigo.valor : 0, valor);
      tabela[id] = { nome: limpaNome(c.nome), valor: novo, skin: String(c.skin || "").slice(0, 12) };
      await this.storage.put(chave, tabela);
      return json({ ok: true, valor: novo, ...this.posicao(tabela, id) });
    }
    if (acao === "ranking") {
      const cat = url.searchParams.get("cat") || "abismo";
      if (!CATS.includes(cat))
        return json({ erro: "categoria inv\xE1lida" }, 400);
      const id = limpaId(url.searchParams.get("id"));
      const tabela = await this.storage.get("s:" + semana() + ":" + cat) || {};
      const passada = await this.storage.get("s:" + semanaPassada() + ":" + cat) || {};
      const lista = this.ordenar(tabela);
      return json({
        semana: semana(),
        cat,
        top: lista.slice(0, 20).map(([i, v], k) => ({ pos: k + 1, nome: v.nome, valor: v.valor, skin: v.skin, eu: i === id })),
        ...this.posicao(tabela, id),
        campeoes: this.ordenar(passada).slice(0, 3).map(([i, v], k) => ({ pos: k + 1, nome: v.nome, valor: v.valor, eu: i === id }))
      });
    }
    return json({ erro: "n\xE3o encontrado" }, 404);
  }
  ordenar(tabela) {
    return Object.entries(tabela).sort((a, b) => b[1].valor - a[1].valor);
  }
  posicao(tabela, id) {
    const lista = this.ordenar(tabela);
    const k = lista.findIndex(([i]) => i === id);
    return { minha_pos: k >= 0 ? k + 1 : 0, total: lista.length };
  }
};
__name(Ranking, "Ranking");
var GOLPES_POR_MEMBRO = 2500;
var Ordem = class {
  constructor(state) {
    this.storage = state.storage;
  }
  async dados(codigo) {
    let d = await this.storage.get("ordem");
    if (d && d.semana !== semana()) {
      d.passada = { semana: d.semana, derrubado: d.derrubado };
      d.semana = semana();
      d.golpes = 0;
      d.derrubado = false;
      for (const m of Object.values(d.membros))
        m.golpes = 0;
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
      if (d)
        return json({ erro: "tente de novo" }, 409);
      if (!id)
        return json({ erro: "dados inv\xE1lidos" }, 400);
      d = { nome: limpaNome(c.ordem || "Ordem"), semana: semana(), golpes: 0, derrubado: false, membros: {} };
      d.membros[id] = { nome: limpaNome(c.nome), golpes: 0 };
      await this.storage.put("ordem", d);
      return json(this.vista(d, codigo, id));
    }
    if (!d)
      return json({ erro: "Ordem n\xE3o encontrada" }, 404);
    if (acao === "entrar") {
      if (!id)
        return json({ erro: "dados inv\xE1lidos" }, 400);
      if (!d.membros[id] && Object.keys(d.membros).length >= 30)
        return json({ erro: "Ordem cheia (30)" }, 409);
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
      if (!id || !d.membros[id])
        return json({ erro: "voc\xEA n\xE3o \xE9 desta Ordem" }, 403);
      const golpes = Math.max(0, Math.min(3e3, Math.floor(Number(c.dano) || 0)));
      d.membros[id].golpes += golpes;
      d.golpes += golpes;
      const vida = GOLPES_POR_MEMBRO * Math.max(1, Object.keys(d.membros).length);
      if (d.golpes >= vida)
        d.derrubado = true;
      await this.storage.put("ordem", d);
    }
    return json(this.vista(d, codigo, id));
  }
};
__name(Ordem, "Ordem");

// ../../../../tmp/claude-0/-home-user/9a5cbf93-0e9a-56ba-a619-0519f6e032ca/scratchpad/wr/node_modules/wrangler/templates/middleware/middleware-ensure-req-body-drained.ts
var drainBody = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } finally {
    try {
      if (request.body !== null && !request.bodyUsed) {
        const reader = request.body.getReader();
        while (!(await reader.read()).done) {
        }
      }
    } catch (e) {
      console.error("Failed to drain the unused request body.", e);
    }
  }
}, "drainBody");
var middleware_ensure_req_body_drained_default = drainBody;

// ../../../../tmp/claude-0/-home-user/9a5cbf93-0e9a-56ba-a619-0519f6e032ca/scratchpad/wr/node_modules/wrangler/templates/middleware/middleware-miniflare3-json-error.ts
function reduceError(e) {
  return {
    name: e?.name,
    message: e?.message ?? String(e),
    stack: e?.stack,
    cause: e?.cause === void 0 ? void 0 : reduceError(e.cause)
  };
}
__name(reduceError, "reduceError");
var jsonError = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } catch (e) {
    const error = reduceError(e);
    return Response.json(error, {
      status: 500,
      headers: { "MF-Experimental-Error-Stack": "true" }
    });
  }
}, "jsonError");
var middleware_miniflare3_json_error_default = jsonError;

// .wrangler/tmp/bundle-i3i93U/middleware-insertion-facade.js
var __INTERNAL_WRANGLER_MIDDLEWARE__ = [
  middleware_ensure_req_body_drained_default,
  middleware_miniflare3_json_error_default
];
var middleware_insertion_facade_default = src_default;

// ../../../../tmp/claude-0/-home-user/9a5cbf93-0e9a-56ba-a619-0519f6e032ca/scratchpad/wr/node_modules/wrangler/templates/middleware/common.ts
var __facade_middleware__ = [];
function __facade_register__(...args) {
  __facade_middleware__.push(...args.flat());
}
__name(__facade_register__, "__facade_register__");
function __facade_invokeChain__(request, env, ctx, dispatch, middlewareChain) {
  const [head, ...tail] = middlewareChain;
  const middlewareCtx = {
    dispatch,
    next(newRequest, newEnv) {
      return __facade_invokeChain__(newRequest, newEnv, ctx, dispatch, tail);
    }
  };
  return head(request, env, ctx, middlewareCtx);
}
__name(__facade_invokeChain__, "__facade_invokeChain__");
function __facade_invoke__(request, env, ctx, dispatch, finalMiddleware) {
  return __facade_invokeChain__(request, env, ctx, dispatch, [
    ...__facade_middleware__,
    finalMiddleware
  ]);
}
__name(__facade_invoke__, "__facade_invoke__");

// .wrangler/tmp/bundle-i3i93U/middleware-loader.entry.ts
var __Facade_ScheduledController__ = class {
  constructor(scheduledTime, cron, noRetry) {
    this.scheduledTime = scheduledTime;
    this.cron = cron;
    this.#noRetry = noRetry;
  }
  #noRetry;
  noRetry() {
    if (!(this instanceof __Facade_ScheduledController__)) {
      throw new TypeError("Illegal invocation");
    }
    this.#noRetry();
  }
};
__name(__Facade_ScheduledController__, "__Facade_ScheduledController__");
function wrapExportedHandler(worker) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return worker;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  const fetchDispatcher = /* @__PURE__ */ __name(function(request, env, ctx) {
    if (worker.fetch === void 0) {
      throw new Error("Handler does not export a fetch() function.");
    }
    return worker.fetch(request, env, ctx);
  }, "fetchDispatcher");
  return {
    ...worker,
    fetch(request, env, ctx) {
      const dispatcher = /* @__PURE__ */ __name(function(type, init) {
        if (type === "scheduled" && worker.scheduled !== void 0) {
          const controller = new __Facade_ScheduledController__(
            Date.now(),
            init.cron ?? "",
            () => {
            }
          );
          return worker.scheduled(controller, env, ctx);
        }
      }, "dispatcher");
      return __facade_invoke__(request, env, ctx, dispatcher, fetchDispatcher);
    }
  };
}
__name(wrapExportedHandler, "wrapExportedHandler");
function wrapWorkerEntrypoint(klass) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return klass;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  return class extends klass {
    #fetchDispatcher = (request, env, ctx) => {
      this.env = env;
      this.ctx = ctx;
      if (super.fetch === void 0) {
        throw new Error("Entrypoint class does not define a fetch() function.");
      }
      return super.fetch(request);
    };
    #dispatcher = (type, init) => {
      if (type === "scheduled" && super.scheduled !== void 0) {
        const controller = new __Facade_ScheduledController__(
          Date.now(),
          init.cron ?? "",
          () => {
          }
        );
        return super.scheduled(controller);
      }
    };
    fetch(request) {
      return __facade_invoke__(
        request,
        this.env,
        this.ctx,
        this.#dispatcher,
        this.#fetchDispatcher
      );
    }
  };
}
__name(wrapWorkerEntrypoint, "wrapWorkerEntrypoint");
var WRAPPED_ENTRY;
if (typeof middleware_insertion_facade_default === "object") {
  WRAPPED_ENTRY = wrapExportedHandler(middleware_insertion_facade_default);
} else if (typeof middleware_insertion_facade_default === "function") {
  WRAPPED_ENTRY = wrapWorkerEntrypoint(middleware_insertion_facade_default);
}
var middleware_loader_entry_default = WRAPPED_ENTRY;
export {
  Ordem,
  Ranking,
  Sala,
  __INTERNAL_WRANGLER_MIDDLEWARE__,
  middleware_loader_entry_default as default
};
//# sourceMappingURL=index.js.map
