// Valida project-status.json y genera docs/ESTADO.md a partir de él.
//   node tools/status-doc.mjs           valida y regenera docs/ESTADO.md
//   node tools/status-doc.mjs --check   solo valida y comprueba que ESTADO.md está al día (código 1 si no)
// No cambia ningún estado: solo lee el JSON y escribe el resumen.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const STATUS = path.join(ROOT, "project-status.json");
const OUT = path.join(ROOT, "docs", "ESTADO.md");
const DOCS = ["README.md", "ARCHITECTURE.md", "docs/ENTORNO.md", "docs/IOS.md", "docs/DIRECCION_VISUAL.md"];
const check = process.argv.includes("--check");

const PHASE = { pending: "Pendiente", in_progress: "En curso", blocked: "Bloqueada", completed: "Completada" };
const TASK = { pending: "Pendiente", in_progress: "En curso", blocked: "Bloqueada", done: "Terminada sin verificar", verified: "Verificada" };
const TEST = { passed: "Aprobada", failed: "Fallida", not_run: "Sin ejecutar", requires_user: "Requiere tu intervención" };
const KIND = { automated: "Automatizada (PC)", device: "En dispositivo", manual: "Revisión manual" };
const SEV = { critical: "Crítico", high: "Alto", medium: "Medio", low: "Bajo", info: "Info" };

const s = JSON.parse(fs.readFileSync(STATUS, "utf8")); // si el JSON es inválido, falla aquí con el error
const errors = [];
const warnings = [];

// ---------- validación ----------
const ids = new Map();
for (const [kind, list] of Object.entries({ phases: s.phases, tasks: s.tasks, tests: s.tests, builds: s.builds, issues: s.issues, decisions: s.decisions })) {
  if (!Array.isArray(list)) { errors.push(`Falta la lista "${kind}".`); continue; }
  for (const x of list) {
    if (!x.id) errors.push(`Elemento sin id en "${kind}".`);
    else if (ids.has(x.id)) errors.push(`Id duplicado: ${x.id}.`);
    else ids.set(x.id, kind);
  }
}
const phaseIds = new Set(s.phases.map((p) => p.id));
for (const p of s.phases) {
  if (!(p.status in PHASE)) errors.push(`Fase ${p.id}: estado "${p.status}" no válido.`);
  const pt = s.tasks.filter((t) => t.phase === p.id);
  if (p.status === "completed" && pt.some((t) => t.status !== "verified")) errors.push(`Fase ${p.id} completada con tareas sin verificar.`);
}
for (const t of s.tasks) {
  if (!(t.status in TASK)) errors.push(`Tarea ${t.id}: estado "${t.status}" no válido.`);
  if (!phaseIds.has(t.phase)) errors.push(`Tarea ${t.id}: fase "${t.phase}" inexistente.`);
  if (t.status === "verified" && (!t.verification || !t.verifiedAt)) errors.push(`Tarea ${t.id} verificada sin "verification" o "verifiedAt".`);
}
for (const t of s.tests) {
  if (!(t.result in TEST)) errors.push(`Prueba ${t.id}: resultado "${t.result}" no válido.`);
  if (!((t.kind ?? "automated") in KIND)) errors.push(`Prueba ${t.id}: tipo "${t.kind}" no válido.`);
}
for (const b of s.builds) if (b.deviceTested && !(b.tests ?? []).some((id) => s.tests.find((t) => t.id === id && t.kind === "device" && t.result === "passed")))
  errors.push(`Compilación ${b.id} marcada como probada en dispositivo sin una prueba de dispositivo aprobada.`);
for (const b of s.builds) for (const id of b.tests ?? []) if (ids.get(id) !== "tests") errors.push(`Compilación ${b.id}: la prueba ${id} no existe.`);
for (const [cat, list] of Object.entries(s.inventory ?? {}))
  for (const a of list) if (a.preview && !fs.existsSync(path.join(ROOT, a.preview))) warnings.push(`Inventario ${a.id}: falta la vista previa ${a.preview}.`);

// Coherencia de los documentos: los ids que citan deben existir.
for (const doc of DOCS) {
  const file = path.join(ROOT, doc);
  if (!fs.existsSync(file)) { warnings.push(`No existe ${doc}.`); continue; }
  const text = fs.readFileSync(file, "utf8");
  for (const m of new Set(text.match(/\b(?:T-\d{3}|TEST-\d{2}|ISS-\d{2}|B-\d{4})\b|\bD\d\b(?=[\s).,])/g) ?? []))
    if (!ids.has(m)) errors.push(`${doc} cita ${m}, que no existe en project-status.json.`);
}

// ---------- resumen ----------
const tc = Object.fromEntries(Object.keys(TASK).map((k) => [k, s.tasks.filter((t) => t.status === k).length]));
const xc = Object.fromEntries(Object.keys(TEST).map((k) => [k, s.tests.filter((t) => t.result === k).length]));
const total = s.tasks.length;
const pct = total ? Math.round((tc.verified / total) * 100) : 0;
const open = s.issues.filter((i) => i.status !== "resolved");
const pend = s.decisions.filter((d) => d.status !== "answered");
const build = [...s.builds].sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt)))[0];
const esc = (v) => String(v ?? "").replace(/\|/g, "\\|").replace(/\n/g, " ");

const md = [];
md.push("# Estado del proyecto", "");
md.push("> Archivo **generado** por `node tools/status-doc.mjs` a partir de `project-status.json`. No lo edites a mano.", "");
md.push(`Datos del ${s.project.updatedAt}.`, "");
md.push("## Resumen", "");
md.push(`- **Avance del desarrollo: ${pct}%** = ${tc.verified} tareas verificadas ÷ ${total} tareas registradas. Las terminadas sin verificar (${tc.done}) no cuentan.`);
md.push(`- Tareas: ${tc.verified} verificadas · ${tc.done} sin verificar · ${tc.in_progress} en curso · ${tc.blocked} bloqueadas · ${tc.pending} pendientes.`);
for (const k of Object.keys(KIND)) {
  const list = s.tests.filter((t) => (t.kind ?? "automated") === k);
  if (!list.length) continue;
  const c = (r) => list.filter((t) => t.result === r).length;
  md.push(`- **Pruebas · ${KIND[k]}**: ${c("passed")}/${list.length} aprobadas · ${c("failed")} fallidas · ${c("requires_user")} requieren tu intervención · ${c("not_run")} sin ejecutar.`);
}
md.push(`- Problemas abiertos: ${open.length} · Decisiones pendientes: ${pend.length}.`, "");
md.push("## Fases", "", "| Fase | Estado | Tareas verificadas | Nota |", "|---|---|---|---|");
for (const p of s.phases) {
  const pt = s.tasks.filter((t) => t.phase === p.id);
  md.push(`| ${p.id} · ${esc(p.name)} | ${PHASE[p.status]} | ${pt.filter((t) => t.status === "verified").length}/${pt.length} | ${esc(p.note)} |`);
}
md.push("", "## Tareas", "", "| Id | Fase | Tarea | Estado |", "|---|---|---|---|");
for (const t of s.tasks) md.push(`| ${t.id} | ${t.phase} | ${esc(t.title)} | ${TASK[t.status]} |`);
md.push("", "## Última compilación", "");
if (build) {
  md.push(`- ${build.platform} · ${build.type} · ${build.version} · ${build.createdAt}`);
  md.push(`- \`${build.path}\` (${build.sizeBytes} bytes) · SHA-256 \`${build.sha256}\``);
  md.push(`- Probada en dispositivo: **${build.deviceTested ? "sí" : "no"}**. ${esc(build.notes)}`);
} else md.push("Sin compilaciones.");
md.push("", "## Pruebas", "", "| Id | Tipo | Prueba | Resultado | Última ejecución |", "|---|---|---|---|---|");
for (const t of s.tests) md.push(`| ${t.id} | ${KIND[t.kind ?? "automated"]} | ${esc(t.name)} | ${TEST[t.result]} | ${t.lastRun ?? "—"} |`);
md.push("", "## Problemas abiertos", "");
for (const i of open) md.push(`- **${i.id}** (${SEV[i.severity] ?? i.severity}) ${esc(i.title)}`);
md.push("", "## Decisiones pendientes", "");
for (const d of pend) md.push(`- **${d.id}** ${esc(d.question)}`);
md.push("", "## Historial", "");
for (const e of [...s.history].reverse()) {
  md.push(`### ${e.date} · ${e.title}`, "", e.description, "");
  for (const c of e.changes ?? []) md.push(`- ${c}`);
  if (e.checks?.length) md.push("", "Pruebas: " + e.checks.map((c) => `${c.name} (${TEST[c.result] ?? c.result})`).join(" · "));
  md.push("");
}
const output = md.join("\n").trimEnd() + "\n";

// ---------- salida ----------
for (const w of warnings) console.log("AVISO  " + w);
for (const e of errors) console.log("ERROR  " + e);
if (check) {
  const current = fs.existsSync(OUT) ? fs.readFileSync(OUT, "utf8").replace(/\r\n/g, "\n") : "";
  if (current !== output) errors.push("docs/ESTADO.md no está al día: ejecuta node tools/status-doc.mjs");
  if (errors.length) { console.log(`${errors.length} error(es).`); process.exit(1); }
  console.log("project-status.json válido y docs/ESTADO.md al día.");
} else {
  if (errors.length) { console.log(`${errors.length} error(es): no se regenera docs/ESTADO.md.`); process.exit(1); }
  fs.writeFileSync(OUT, output);
  console.log(`project-status.json válido. docs/ESTADO.md regenerado (${pct}% · ${tc.verified}/${total} tareas verificadas).`);
}
