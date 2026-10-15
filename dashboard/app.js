// Panel de progreso de Final Fire.
// Lee /api/status (que sirve project-status.json) cada POLL_MS y vuelve a pintar
// solo si los datos cambiaron. No calcula estados a partir de archivos ni commits:
// todo lo que se muestra sale del JSON.
"use strict";

const POLL_MS = 5000;

const LABELS = {
  phase: { pending: "Pendiente", in_progress: "En curso", blocked: "Bloqueada", completed: "Completada" },
  task: { pending: "Pendiente", in_progress: "En curso", blocked: "Bloqueada", done: "Terminada sin verificar", verified: "Verificada" },
  test: { passed: "Aprobada", failed: "Fallida", not_run: "Sin ejecutar", requires_user: "Requiere tu intervención" },
  severity: { critical: "Crítico", high: "Alto", medium: "Medio", low: "Bajo", info: "Info" },
  issue: { open: "Abierto", resolved: "Resuelto" },
  decision: { pending: "Pendiente", answered: "Respondida" },
  asset: { placeholder: "Provisional", draft: "Borrador", final: "Final" },
  kind: { automated: "Automatizadas en el PC", device: "En dispositivo físico", manual: "Revisiones manuales" },
  inventory: { characters: "Personajes", animations: "Animaciones", scenarios: "Escenarios", ui: "Interfaz", sounds: "Sonidos", references: "Referencias" },
};
const PHASE_STATES = Object.keys(LABELS.phase);
const TASK_STATES = Object.keys(LABELS.task);
const TEST_STATES = Object.keys(LABELS.test);

let etag = null;
let current = null;
let lastOk = 0;
let invTab = sessionGet("invTab") || "characters";

// ---------- utilidades ----------
function h(tag, attrs = {}, ...children) {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (v == null || v === false) continue;
    if (k === "class") el.className = v;
    else if (k.startsWith("on")) el.addEventListener(k.slice(2), v);
    else el.setAttribute(k, v === true ? "" : v);
  }
  for (const c of children.flat()) if (c != null && c !== false) el.append(c.nodeType ? c : String(c));
  return el;
}
const $ = (id) => document.getElementById(id);
const chip = (kind, state) => h("span", { class: `chip s-${state}` }, LABELS[kind][state] ?? state);
const empty = (text) => h("li", { class: "empty" }, text);
function fmtDate(s) {
  if (!s) return "—";
  const d = new Date(s);
  if (isNaN(d)) return s;
  return /T/.test(s) ? d.toLocaleString("es", { dateStyle: "medium", timeStyle: "short" }) : d.toLocaleDateString("es", { dateStyle: "medium", timeZone: "UTC" });
}
function fmtBytes(n) {
  if (n == null) return "—";
  return n > 1e6 ? (n / 1048576).toFixed(1) + " MB" : (n / 1024).toFixed(0) + " KB";
}
function fileUrl(p) { return "/files/" + p.split("/").map(encodeURIComponent).join("/"); }
function sessionGet(k) { try { return sessionStorage.getItem(k); } catch { return null; } }
function sessionSet(k, v) { try { sessionStorage.setItem(k, v); } catch { /* sin almacenamiento */ } }
function count(list, key, states) {
  const c = Object.fromEntries(states.map((s) => [s, 0]));
  for (const x of list) c[x[key]] = (c[x[key]] ?? 0) + 1;
  return c;
}
function pct(n, d) { return d ? Math.round((n / d) * 100) : 0; }

// ---------- validación (avisos de coherencia, no corrige nada) ----------
function validate(s) {
  const w = [];
  const phases = new Map((s.phases ?? []).map((p) => [p.id, p]));
  for (const p of s.phases ?? []) {
    if (!PHASE_STATES.includes(p.status)) w.push(`Fase ${p.id}: estado desconocido "${p.status}".`);
    const tasks = (s.tasks ?? []).filter((t) => t.phase === p.id);
    if (p.status === "completed" && tasks.some((t) => t.status !== "verified"))
      w.push(`Fase ${p.id} está marcada como completada, pero tiene tareas sin verificar.`);
  }
  for (const t of s.tasks ?? []) {
    if (!TASK_STATES.includes(t.status)) w.push(`Tarea ${t.id}: estado desconocido "${t.status}".`);
    if (!phases.has(t.phase)) w.push(`Tarea ${t.id}: la fase "${t.phase}" no existe.`);
    if (t.status === "verified" && !t.verification) w.push(`Tarea ${t.id} está verificada sin describir la comprobación.`);
  }
  for (const t of s.tests ?? []) if (!TEST_STATES.includes(t.result)) w.push(`Prueba ${t.id}: resultado desconocido "${t.result}".`);
  return w;
}

// ---------- secciones ----------
function renderHeader(s) {
  const p = s.project ?? {};
  $("project-name").textContent = p.name ?? "Proyecto";
  $("project-engine").textContent = p.engine ?? "";
  $("project-summary").textContent = p.summary ?? "";
  document.title = `${p.name ?? "Proyecto"} · Progreso`;
}

function renderKpis(s) {
  const tasks = s.tasks ?? [];
  const tc = count(tasks, "status", TASK_STATES);
  const total = tasks.length;
  const tests = s.tests ?? [];
  const xc = count(tests, "result", TEST_STATES);
  const issues = (s.issues ?? []).filter((i) => i.status !== "resolved");
  const serious = issues.filter((i) => i.severity === "critical" || i.severity === "high").length;
  const decisions = (s.decisions ?? []).filter((d) => d.status !== "answered").length;
  const bar = (parts) => h("div", { class: "bar", role: "img", "aria-label": parts.map(([, n, l]) => `${l}: ${n}`).join(", ") },
    parts.map(([cls, n]) => h("span", { class: cls, style: `width:${total ? (n / total) * 100 : 0}%` })));

  $("kpis").replaceChildren(
    h("div", { class: "kpi primary" },
      h("div", { class: "label" }, "Avance del desarrollo"),
      h("div", { class: "value" }, `${pct(tc.verified, total)}%`, " ", h("small", {}, `${tc.verified} de ${total} tareas verificadas`)),
      bar([["v", tc.verified, "Verificadas"], ["d", tc.done, "Terminadas sin verificar"], ["p", tc.in_progress, "En curso"], ["b", tc.blocked, "Bloqueadas"]]),
      h("div", { class: "detail" },
        h("span", {}, `${tc.done} sin verificar`), h("span", {}, `${tc.in_progress} en curso`),
        h("span", {}, `${tc.blocked} bloqueadas`), h("span", {}, `${tc.pending} pendientes`))),
    testKpi("Pruebas automatizadas (PC)", tests.filter((t) => (t.kind ?? "automated") === "automated")),
    testKpi("Pruebas en dispositivo", tests.filter((t) => t.kind === "device")),
    h("div", { class: "kpi" },
      h("div", { class: "label" }, "Problemas abiertos"),
      h("div", { class: "value" }, `${issues.length}`),
      h("div", { class: "detail" }, h("span", {}, `${serious} graves (alto o crítico)`))),
    h("div", { class: "kpi" },
      h("div", { class: "label" }, "Decisiones pendientes"),
      h("div", { class: "value" }, `${decisions}`),
      h("div", { class: "detail" }, h("a", { href: "#decisiones" }, "Ver decisiones"))),
  );

  const warnings = validate(s);
  const ul = $("warnings");
  ul.hidden = warnings.length === 0;
  ul.replaceChildren(...warnings.map((w) => h("li", {}, w)));
}

function testKpi(label, list) {
  const c = count(list, "result", TEST_STATES);
  return h("div", { class: "kpi" },
    h("div", { class: "label" }, label),
    h("div", { class: "value" }, `${c.passed}`, " ", h("small", {}, `aprobadas de ${list.length}`)),
    h("div", { class: "detail" },
      h("span", {}, `${c.failed} fallidas`), h("span", {}, `${c.requires_user} requieren tu intervención`), h("span", {}, `${c.not_run} sin ejecutar`)));
}

function renderPhases(s) {
  const tasks = s.tasks ?? [];
  const items = (s.phases ?? []).map((p) => {
    const pt = tasks.filter((t) => t.phase === p.id);
    const v = pt.filter((t) => t.status === "verified").length;
    return h("li", { class: "phase" },
      h("span", { class: "pid" }, p.id),
      h("span", { class: "name" }, p.name),
      chip("phase", p.status),
      p.description && h("span", { class: "desc" }, p.description),
      p.note && h("span", { class: "note" }, p.note),
      h("span", { class: "pbar" },
        h("span", { class: "bar" }, h("span", { class: "v", style: `width:${pct(v, pt.length)}%` })),
        pt.length ? `${v}/${pt.length} tareas verificadas` : "Sin tareas registradas"));
  });
  $("phases").replaceChildren(...(items.length ? items : [empty("No hay fases registradas.")]));
}

function taskItem(t, phases) {
  return h("li", { class: "task" },
    h("div", { class: "row" }, h("span", { class: "title" }, t.title), chip("task", t.status)),
    h("div", { class: "meta" }, `${t.id} · ${phases.get(t.phase)?.name ?? t.phase}`, t.verifiedAt ? ` · verificada ${fmtDate(t.verifiedAt)}` : ""),
    (t.verification || t.note) && h("div", { class: "why" }, t.verification ?? t.note));
}

function renderTasks(s) {
  const phases = new Map((s.phases ?? []).map((p) => [p.id, p]));
  const order = { in_progress: 0, blocked: 1, pending: 2 };
  const tasks = s.tasks ?? [];
  const next = tasks.filter((t) => t.status in order).sort((a, b) => order[a.status] - order[b.status]).slice(0, 8);
  const done = tasks.filter((t) => t.status === "verified" || t.status === "done").sort((a, b) => (a.status === "done" ? -1 : 0) - (b.status === "done" ? -1 : 0));
  const remaining = tasks.filter((t) => t.status in order).length - next.length;
  $("tasks-next").replaceChildren(...(next.length ? next.map((t) => taskItem(t, phases)) : [empty("No hay tareas pendientes.")]),
    ...(remaining > 0 ? [h("li", { class: "empty" }, `…y ${remaining} más en el roadmap.`)] : []));
  $("tasks-done").replaceChildren(...(done.length ? done.map((t) => taskItem(t, phases)) : [empty("Aún no hay tareas terminadas.")]));
}

function renderBuild(s, disk) {
  const builds = [...(s.builds ?? [])].sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt)));
  const b = builds[0];
  if (!b) return $("build").replaceChildren(h("p", { class: "empty" }, "Todavía no hay compilaciones registradas."));
  const tests = new Map((s.tests ?? []).map((t) => [t.id, t]));
  const d = disk?.[b.id];
  const diskText = d ? (d.exists ? `Sí (${fmtBytes(d.sizeBytes)})${b.sizeBytes && d.sizeBytes !== b.sizeBytes ? " — el tamaño no coincide con el registrado" : ""}` : "No encontrado en disco") : "—";
  $("build").replaceChildren(h("div", { class: "build" },
    h("dl", { class: "facts" },
      h("dt", {}, "Plataforma"), h("dd", {}, `${b.platform} · ${b.type}`),
      h("dt", {}, "Versión"), h("dd", {}, b.version ?? "—"),
      h("dt", {}, "Fecha"), h("dd", {}, fmtDate(b.createdAt)),
      h("dt", {}, "Motor"), h("dd", {}, b.engine ?? "—"),
      h("dt", {}, "Archivo"), h("dd", {}, h("code", {}, b.path)),
      h("dt", {}, "En disco"), h("dd", {}, diskText),
      h("dt", {}, "Tamaño"), h("dd", {}, fmtBytes(b.sizeBytes)),
      h("dt", {}, "SHA-256"), h("dd", {}, h("code", {}, b.sha256 ?? "—")),
      h("dt", {}, "Firma"), h("dd", {}, b.signing ?? "—")),
    h("div", {},
      h("h3", {}, "Pruebas de esta compilación"),
      h("ul", { class: "tests" }, ...(b.tests ?? []).map((id) => {
        const t = tests.get(id);
        const kind = t ? (LABELS.kind[t.kind ?? "automated"] ?? "") : "";
        return h("li", { class: "test" }, h("div", { class: "row" }, h("span", { class: "name" }, t?.name ?? id), t ? chip("test", t.result) : chip("test", "not_run")), kind && h("div", { class: "meta" }, kind));
      })),
      h("p", { class: `callout ${b.deviceTested ? "ok" : "warn"}` },
        b.deviceTested ? "Probada en un dispositivo físico." : "No probada en un dispositivo físico.", b.notes ? ` ${b.notes}` : ""))));
}

function renderTests(s) {
  const groups = Object.keys(LABELS.kind).map((k) => [k, (s.tests ?? []).filter((t) => (t.kind ?? "automated") === k)]).filter(([, l]) => l.length);
  const testItem = (t) => h("li", { class: "test" },
    h("div", { class: "row" }, h("span", { class: "name" }, t.name), chip("test", t.result)),
    h("div", { class: "meta" }, `${t.id} · ${t.platform ?? ""} · ${t.lastRun ? "última ejecución " + fmtDate(t.lastRun) : "nunca ejecutada"}`),
    t.details && h("div", { class: "details" }, t.details),
    t.command && h("div", { class: "details" }, h("code", {}, t.command)));
  const items = groups.flatMap(([k, list]) => [h("li", { class: "group" }, h("h3", {}, LABELS.kind[k])), ...list.map(testItem)]);
  $("tests").replaceChildren(...(items.length ? items : [empty("No hay pruebas registradas.")]));
}

function preview(item) {
  const p = item.preview;
  if (!p) return h("div", { class: "preview none" }, "Sin vista previa");
  if (/\.(ogg|wav|mp3)$/i.test(p)) return h("audio", { controls: true, preload: "none", src: fileUrl(p) });
  if (/\.(webm|mp4)$/i.test(p)) return h("video", { class: "preview", controls: true, muted: true, loop: true, preload: "metadata", src: fileUrl(p) });
  return h("button", { class: "preview", type: "button", "aria-label": `Ampliar ${item.name}`, onclick: () => openLightbox(fileUrl(p), item.name) },
    h("img", { src: fileUrl(p), alt: item.name, loading: "lazy", onerror: (e) => e.target.replaceWith("Vista previa no encontrada") }));
}

function renderInventory(s) {
  const inv = s.inventory ?? {};
  const keys = Object.keys(LABELS.inventory).filter((k) => k in inv);
  if (!keys.includes(invTab)) invTab = keys[0];
  $("inv-tabs").replaceChildren(...keys.map((k) => h("button", {
    type: "button", role: "tab", "aria-selected": String(k === invTab),
    onclick: () => { invTab = k; sessionSet("invTab", k); renderInventory(current.status); },
  }, `${LABELS.inventory[k]} (${inv[k].length})`)));
  const list = inv[invTab] ?? [];
  $("inventory").replaceChildren(...(list.length ? list.map((a) => h("article", { class: "asset" },
    preview(a),
    h("div", { class: "body" },
      h("div", { class: "row" }, h("span", { class: "title" }, a.name), a.status && chip("asset", a.status)),
      a.path && h("code", {}, a.path),
      a.notes && h("div", { class: "notes" }, a.notes)))) :
    [h("p", { class: "empty" }, `Aún no hay ${LABELS.inventory[invTab].toLowerCase()} registrados.`)]));
}

function renderBalance(s) {
  const list = s.balance ?? [];
  const head = h("tr", {}, ["Área", "Parámetro", "Valor", "Archivo", "Estado"].map((t) => h("th", { scope: "col" }, t)));
  const rows = list.map((b) => h("tr", {},
    h("td", {}, b.area), h("td", {}, b.parameter), h("td", { class: "num" }, b.value),
    h("td", {}, h("code", {}, b.file)), h("td", {}, h("span", { class: "chip s-placeholder" }, b.status === "provisional" ? "Provisional" : b.status))));
  $("balance").replaceChildren(h("thead", {}, head), h("tbody", {}, ...(rows.length ? rows : [h("tr", {}, h("td", { colspan: "5", class: "empty" }, "Sin valores registrados."))])));
}

function renderIssues(s) {
  const rank = { critical: 0, high: 1, medium: 2, low: 3, info: 4 };
  const list = [...(s.issues ?? [])].sort((a, b) => (a.status === "resolved") - (b.status === "resolved") || (rank[a.severity] ?? 9) - (rank[b.severity] ?? 9));
  $("issues").replaceChildren(...(list.length ? list.map((i) => h("li", { class: "issue" },
    h("div", { class: "row" }, h("span", { class: "title" }, i.title), h("span", {}, chip("severity", i.severity), " ", chip("issue", i.status))),
    h("div", { class: "meta" }, `${i.id} · ${fmtDate(i.createdAt)}`),
    i.details && h("div", { class: "details" }, i.details))) : [empty("No hay problemas registrados.")]));
}

function renderDecisions(s) {
  const list = [...(s.decisions ?? [])].sort((a, b) => (a.status === "answered") - (b.status === "answered"));
  $("decisions").replaceChildren(...(list.length ? list.map((d) => h("li", { class: `decision ${d.status === "answered" ? "answered" : ""}` },
    h("div", { class: "row" }, h("span", { class: "q" }, `${d.id}. ${d.question}`), " ", chip("decision", d.status)),
    d.context && h("p", { class: "ctx" }, d.context),
    d.options?.length && h("ul", {}, d.options.map((o) => h("li", {}, o))),
    d.recommendation && h("p", { class: "rec" }, h("strong", {}, "Recomendación: "), d.recommendation),
    d.answer && h("p", { class: "rec" }, h("strong", {}, "Respuesta: "), d.answer))) : [empty("No hay decisiones pendientes.")]));
}

function renderHistory(s) {
  // Más reciente primero; con la misma fecha, la entrada añadida después va antes.
  const list = (s.history ?? []).map((e, i) => [e, i])
    .sort((a, b) => String(b[0].date).localeCompare(String(a[0].date)) || b[1] - a[1])
    .map(([e]) => e);
  $("history").replaceChildren(...(list.length ? list.map((e) => h("li", { class: "entry" },
    h("div", { class: "date" }, fmtDate(e.date)),
    h("div", { class: "title" }, e.title),
    e.description && h("p", {}, e.description),
    e.changes?.length && h("ul", {}, e.changes.map((c) => h("li", {}, c))),
    e.checks?.length && h("div", { class: "checks" }, h("span", { class: "muted small" }, "Pruebas:"),
      e.checks.map((c) => h("span", { class: `chip s-${c.result}`, title: LABELS.test[c.result] ?? c.result }, c.name))))) :
    [empty("Sin actualizaciones registradas.")]));
}

function render(data) {
  const s = data.status;
  renderHeader(s);
  renderKpis(s);
  renderPhases(s);
  renderTasks(s);
  renderBuild(s, data.disk);
  renderTests(s);
  renderInventory(s);
  renderBalance(s);
  renderIssues(s);
  renderDecisions(s);
  renderHistory(s);
}

function openLightbox(src, alt) {
  const dlg = $("lightbox");
  const img = dlg.querySelector("img");
  img.src = src;
  img.alt = alt;
  dlg.showModal();
}

// ---------- sincronización ----------
function setSync(kind, text) {
  $("sync").className = `sync ${kind}`;
  $("sync-text").textContent = text;
}

function banner(text) {
  const b = $("banner");
  b.hidden = !text;
  b.textContent = text ?? "";
}

async function poll() {
  try {
    const res = await fetch("/api/status", { cache: "no-store", headers: etag ? { "If-None-Match": etag } : {} });
    if (res.status === 304) {
      lastOk = Date.now();
    } else if (res.ok) {
      etag = res.headers.get("ETag");
      current = await res.json();
      render(current);
      lastOk = Date.now();
      banner(null);
    } else {
      const err = await res.json().catch(() => ({}));
      banner(`No se pudieron leer los datos: ${err.error ?? res.statusText}. Se muestran los últimos datos válidos.`);
      return setSync("stale", "Datos no válidos · reintentando");
    }
    const when = current?.status?.project?.updatedAt;
    setSync("live", `En vivo · datos del ${fmtDate(when)}`);
  } catch {
    setSync(lastOk ? "stale" : "error", lastOk ? "Sin conexión con el servidor local · reintentando" : "No se pudo conectar. ¿Está iniciado el servidor?");
  }
}

poll();
setInterval(() => { if (!document.hidden) poll(); }, POLL_MS);
document.addEventListener("visibilitychange", () => { if (!document.hidden) poll(); });
