// Guarda o jogo no celular para não baixar tudo de novo a cada vez que abre.
// Gerado por ferramentas/versionar.py (versão __VERSAO__).
//
// - Os arquivos grandes têm a impressão digital no nome (kx-....wasm,
//   jogo-....pck): se estão guardados, saem do celular, sem internet.
// - A página (index.html) vem da internet quando dá, para trazer versões
//   novas; sem internet, sai da cópia guardada.
// - Numa versão nova, só os arquivos que mudaram são baixados; os que saíram
//   da lista são apagados.
const CAIXA = 'kravenox-quadros';
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
			if (k.startsWith('Kravenox: Quadro')) await caches.delete(k);
		}
		await self.clients.claim();
	})());
});

self.addEventListener('fetch', (ev) => {
	const url = new URL(ev.request.url);
	if (ev.request.method !== 'GET' || !url.href.startsWith(self.registration.scope)) return;
	const nome = url.pathname.split('/').pop();
	if (ev.request.mode === 'navigate' || nome === '' || nome === 'index.html') {
		ev.respondWith((async () => {
			const c = await caches.open(CAIXA);
			try {
				const r = await fetch(ev.request);
				if (r.ok) c.put('index.html', r.clone());
				return r;
			} catch (e) {
				return (await c.match('index.html')) || Response.error();
			}
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
