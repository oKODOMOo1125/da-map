/* DA Map: เปิดได้แม้เน็ตหลุด — ใช้ของใหม่จากเน็ตก่อนเสมอ ถ้าเน็ตไม่มีค่อยใช้ของที่เก็บไว้ */
const C="damap-v1";
self.addEventListener("install",e=>{self.skipWaiting();e.waitUntil(caches.open(C).then(c=>c.addAll(["./","./index.html","./icon-192.png","./manifest.webmanifest"]).catch(()=>{})))});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==C).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{const r=e.request;if(r.method!=="GET")return;const u=new URL(r.url);if(u.origin!==location.origin)return;
  e.respondWith(fetch(r).then(res=>{if(res.ok){const cp=res.clone();caches.open(C).then(c=>c.put(r.mode==="navigate"?"./":r,cp))}return res})
    .catch(()=>caches.match(r.mode==="navigate"?"./":r).then(m=>m||caches.match("./"))))});
