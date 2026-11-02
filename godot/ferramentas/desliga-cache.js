// Desliga o service worker antigo do Quadros do Cisma. Ele guardava o jogo no
// celular e mostrava a versão velha mesmo depois de publicar uma nova.
// O publicar.sh copia este arquivo como quadros/index.service.worker.js: o
// navegador acha a "atualização", instala esta versão, que apaga a cópia
// guardada, se desliga e recarrega o jogo já com a versão nova.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
	event.waitUntil((async () => {
		const chaves = await caches.keys();
		await Promise.all(chaves.filter((k) => k.startsWith('Kravenox: Quadro')).map((k) => caches.delete(k)));
		await self.registration.unregister();
		const abas = await self.clients.matchAll({ type: 'window' });
		abas.forEach((aba) => aba.navigate(aba.url));
	})());
});
