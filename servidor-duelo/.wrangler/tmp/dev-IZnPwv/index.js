var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/index.js
var CODIGO = /^[A-Z2-9]{4}$/;
var src_default = {
  async fetch(req, env) {
    const url = new URL(req.url);
    const partes = url.pathname.split("/").filter(Boolean);
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

// .wrangler/tmp/bundle-i9gTzl/middleware-insertion-facade.js
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

// .wrangler/tmp/bundle-i9gTzl/middleware-loader.entry.ts
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
  Sala,
  __INTERNAL_WRANGLER_MIDDLEWARE__,
  middleware_loader_entry_default as default
};
//# sourceMappingURL=index.js.map
