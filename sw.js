// Henter alltid nyeste versjon når du er på nett, og bruker lagret kopi når du er offline.
const CACHE = "kalender-v2";
const FILES = ["./", "index.html", "config.js", "manifest.webmanifest", "icon-180.png", "icon-192.png", "icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)));
  self.skipWaiting();
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener("fetch", e => {
  const req = e.request, url = new URL(req.url);
  if (req.method !== "GET" || url.hostname.endsWith("supabase.co") || url.hostname.endsWith("supabase.in")) return;

  // Appens egne filer: prøv nettet først, bruk lagret kopi hvis du er offline.
  if (url.origin === self.location.origin) {
    e.respondWith(
      fetch(req, { cache: "no-store" })
        .then(r => { if (r && r.ok) caches.open(CACHE).then(c => c.put(req, r.clone())); return r; })
        .catch(() => caches.match(req).then(hit => hit || caches.match("index.html")))
    );
    return;
  }

  // Fonter og biblioteker: bruk lagret kopi, og oppdater i bakgrunnen.
  e.respondWith(caches.open(CACHE).then(async c => {
    const hit = await c.match(req);
    const net = fetch(req).then(r => { if (r && (r.ok || r.type === "opaque")) c.put(req, r.clone()); return r; }).catch(() => hit);
    return hit || net;
  }));
});
