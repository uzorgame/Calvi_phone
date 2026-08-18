/* Copied over build/web/flutter_service_worker.js after every web build.
   Early builds registered a real worker, and a browser that has one keeps
   serving its cache no matter what the server sends: deleting the file only
   stops updates, it does not unregister what is already installed. This one
   unregisters itself and drops every cache, so the next reload is live. */
self.addEventListener('install', () => self.skipWaiting())

self.addEventListener('activate', (e) => {
  e.waitUntil(
    (async () => {
      for (const key of await caches.keys()) await caches.delete(key)
      await self.registration.unregister()
      for (const client of await self.clients.matchAll({ type: 'window' })) client.navigate(client.url)
    })(),
  )
})
