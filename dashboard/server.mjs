// Panel de progreso de Final Fire: servidor local sin dependencias.
//   node dashboard/server.mjs            -> http://127.0.0.1:8765 (solo este equipo)
//   node dashboard/server.mjs --open     -> además abre el navegador
//   node dashboard/server.mjs --lan      -> accesible desde el móvil en tu red local (Wi-Fi)
//   node dashboard/server.mjs --port 9000
// Solo lee archivos. Nunca modifica project-status.json ni marca tareas.

import http from "node:http";
import fs from "node:fs/promises";
import { existsSync, statSync } from "node:fs";
import path from "node:path";
import os from "node:os";
import crypto from "node:crypto";
import { exec } from "node:child_process";
import { fileURLToPath } from "node:url";

const DASHBOARD_DIR = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_DIR = path.resolve(DASHBOARD_DIR, "..");
const STATUS_FILE = path.join(PROJECT_DIR, "project-status.json");

// Carpetas del proyecto cuyos archivos se pueden mostrar como vista previa.
const PREVIEW_ROOTS = ["docs/previews", "docs/referencias", "assets"];

const args = process.argv.slice(2);
const lan = args.includes("--lan");
const open = args.includes("--open");
const portArg = args.indexOf("--port");
const PORT = portArg >= 0 ? Number(args[portArg + 1]) : 8765;
const HOST = lan ? "0.0.0.0" : "127.0.0.1";

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
  ".gif": "image/gif",
  ".ogg": "audio/ogg",
  ".wav": "audio/wav",
  ".mp3": "audio/mpeg",
  ".webm": "video/webm",
  ".mp4": "video/mp4",
};

function send(res, code, body, headers = {}) {
  res.writeHead(code, { "Cache-Control": "no-store", "X-Content-Type-Options": "nosniff", ...headers });
  res.end(body);
}

// Resuelve una ruta relativa sin permitir salir de `base`.
function safeJoin(base, rel) {
  const full = path.resolve(base, "." + path.sep + rel);
  return full === base || full.startsWith(base + path.sep) ? full : null;
}

async function serveFile(res, file) {
  const type = file && TYPES[path.extname(file).toLowerCase()];
  if (!type || !existsSync(file) || !statSync(file).isFile()) return send(res, 404, "No encontrado");
  send(res, 200, await fs.readFile(file), { "Content-Type": type });
}

async function serveStatus(req, res) {
  let raw;
  try {
    raw = await fs.readFile(STATUS_FILE, "utf8");
  } catch (e) {
    return send(res, 500, JSON.stringify({ error: `No se puede leer project-status.json: ${e.message}` }), { "Content-Type": TYPES[".json"] });
  }
  const etag = '"' + crypto.createHash("sha1").update(raw).digest("hex") + '"';
  if (req.headers["if-none-match"] === etag) return send(res, 304, "", { ETag: etag });

  let status;
  try {
    status = JSON.parse(raw);
  } catch (e) {
    // Normalmente ocurre a mitad de una edición: el panel conserva los últimos datos válidos.
    return send(res, 422, JSON.stringify({ error: `JSON no válido: ${e.message}` }), { "Content-Type": TYPES[".json"], ETag: etag });
  }

  // Comprobación informativa: ¿siguen en disco las compilaciones registradas?
  // No cambia ningún estado; solo se muestra junto a la compilación.
  const disk = {};
  for (const b of status.builds ?? []) {
    const f = b.path ? safeJoin(PROJECT_DIR, b.path) : null;
    disk[b.id] = f && existsSync(f) ? { exists: true, sizeBytes: statSync(f).size } : { exists: false };
  }
  send(res, 200, JSON.stringify({ status, disk, servedAt: new Date().toISOString() }), {
    "Content-Type": TYPES[".json"],
    ETag: etag,
  });
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.method !== "GET" && req.method !== "HEAD") return send(res, 405, "Solo lectura");
    const url = new URL(req.url, "http://localhost");
    const p = decodeURIComponent(url.pathname);

    if (p === "/api/status") return await serveStatus(req, res);
    if (p.startsWith("/files/")) {
      const rel = p.slice("/files/".length);
      const allowed = PREVIEW_ROOTS.some((r) => rel === r || rel.startsWith(r + "/"));
      return await serveFile(res, allowed ? safeJoin(PROJECT_DIR, rel) : null);
    }
    return await serveFile(res, safeJoin(DASHBOARD_DIR, p === "/" ? "index.html" : p.slice(1)));
  } catch (e) {
    send(res, 500, "Error interno: " + e.message);
  }
});

server.on("error", (e) => {
  console.error(e.code === "EADDRINUSE" ? `El puerto ${PORT} está ocupado. Prueba: node dashboard/server.mjs --port 8766` : e.message);
  process.exit(1);
});

server.listen(PORT, HOST, () => {
  const local = `http://127.0.0.1:${PORT}/`;
  console.log(`Panel de Final Fire en ${local}`);
  if (lan) {
    const ips = Object.values(os.networkInterfaces()).flat().filter((i) => i && i.family === "IPv4" && !i.internal);
    for (const i of ips) console.log(`  En tu red local: http://${i.address}:${PORT}/`);
    console.log("  Aviso: cualquier dispositivo de tu red local puede verlo. No es accesible desde internet salvo que abras el puerto en el router.");
  }
  console.log("Ctrl+C para detenerlo.");
  if (open) exec(process.platform === "win32" ? `start "" "${local}"` : `xdg-open ${local}`);
});
