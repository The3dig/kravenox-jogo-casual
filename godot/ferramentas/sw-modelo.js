// Guarda o jogo no celular para não baixar tudo de novo a cada vez que abre.
// Gerado por ferramentas/versionar.py (versão __VERSAO__).
//
// - Os arquivos grandes têm a impressão digital no nome (kx-....wasm,
//   jogo-....pck): se estão guardados, saem do celular, sem internet.
// - A página (index.html) sai da cópia guardada na hora; a versão nova é
//   buscada por trás e vale na próxima vez que o jogo abrir.
// - Numa versão nova, só os arquivos que mudaram são baixados; os que saíram
//   da lista são apagados.
const CAIXA = '__CAIXA__';
const ARQUIVOS = __ARQUIVOS__;

self.addEventListener('install', (ev) => {
	ev.waitUntil((async () => {
		const c = await caches.open(CAIXA);
		for (const a of ARQUIVOS) {
			if (!(await c.match(a))) {
				try { await c.add(a); } catch (e) { /* baixa depois, quando o jogo pedir */ }
			}
		}
		self.skipWaiting();
	})());
});

self.addEventListener('activate', (ev) => {
	ev.waitUntil((async () => {
		const c = await caches.open(CAIXA);
		const fica = new Set(ARQUIVOS.map((a) => new URL(a, self.registration.scope).href));
		fica.add(new URL('index.html', self.registration.scope).href);
		fica.add(self.registration.scope);
		for (const req of await c.keys()) {
			if (!fica.has(req.url.split('?')[0])) await c.delete(req);
		}
		// caixas do service worker antigo do Godot
		for (const k of await caches.keys()) {
			if (k.startsWith('__VELHO__')) await caches.delete(k);
		}
		await self.clients.claim();
	})());
});

self.addEventListener('fetch', (ev) => {
	const url = new URL(ev.request.url);
	if (ev.request.method !== 'GET' || !url.href.startsWith(self.registration.scope)) return;
	const nome = url.pathname.split('/').pop();
	// só a página deste jogo (outros jogos em subpastas cuidam das suas)
	const pagina = url.href.split('?')[0];
	if (pagina === self.registration.scope || pagina === self.registration.scope + 'index.html') {
		// A página é pequena: tenta a nova primeiro (assim a versão nova já vale
		// nesta abertura). Se a internet não responder em 2,5 s, ou não houver
		// internet, abre a cópia guardada. A nova continua sendo guardada por trás.
		const caixa = caches.open(CAIXA);
		const nova = fetch(ev.request, { cache: 'no-store' }).then(async (r) => {
			if (r.ok && (r.headers.get('content-type') || '').includes('text/html')) await (await caixa).put('index.html', r.clone());
			return r;
		});
		ev.waitUntil(nova.then(() => {}, () => {}));
		ev.respondWith((async () => {
			const prazo = new Promise((ok) => setTimeout(() => ok(null), 2500));
			const r = await Promise.race([nova.then((x) => (x.ok ? x.clone() : null), () => null), prazo]);
			if (r) return r;
			const guardada = await (await caixa).match('index.html');
			if (guardada) return guardada;
			try { return await nova; } catch (e) { return Response.error(); }
		})());
		return;
	}
	if (ARQUIVOS.includes(nome)) {
		ev.respondWith((async () => {
			const c = await caches.open(CAIXA);
			const guardado = await c.match(nome);
			if (guardado) return guardado;
			const r = await fetch(ev.request);
			if (r.ok) c.put(nome, r.clone());
			return r;
		})());
	}
});
