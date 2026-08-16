/* Serves build/web so a rebuild is a refresh instead of a restart.
   `flutter run -d web-server` owns the port and only reloads on a keypress,
   which is no use when the build is driven from a script. */
import { createServer } from 'node:http'
import { readFile } from 'node:fs/promises'
import { extname, join, normalize } from 'node:path'

const ROOT = new URL('../build/web/', import.meta.url).pathname.replace(/^\//, '')
const PORT = 5301

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff2': 'font/woff2',
  '.ico': 'image/x-icon',
  '.bin': 'application/octet-stream',
}

createServer(async (req, res) => {
  const url = decodeURIComponent((req.url || '/').split('?')[0])
  const rel = normalize(url === '/' ? 'index.html' : url.slice(1)).replace(/^(\.\.[/\\])+/, '')
  try {
    const body = await readFile(join(ROOT, rel))
    res.writeHead(200, {
      'Content-Type': TYPES[extname(rel)] || 'application/octet-stream',
      // Nothing is cached: the whole point is that a rebuild shows up.
      'Cache-Control': 'no-store',
    })
    res.end(body)
  } catch {
    // Anything unknown falls back to the app, so deep links work.
    try {
      res.writeHead(200, { 'Content-Type': TYPES['.html'], 'Cache-Control': 'no-store' })
      res.end(await readFile(join(ROOT, 'index.html')))
    } catch {
      res.writeHead(404).end('немає')
    }
  }
}).listen(PORT, '127.0.0.1', () => console.log(`http://127.0.0.1:${PORT}`))
