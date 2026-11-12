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

export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    const partes = url.pathname.split("/").filter(Boolean);
    if (partes.length === 0) {
      return new Response("Kravenox Duelo: ok", { headers: { "content-type": "text/plain; charset=utf-8" } });
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
