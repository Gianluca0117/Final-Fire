# Arquitectura de Final Fire

Versión 1 · 2026-10-14 · Estado: **propuesta documentada, pendiente de implementar por etapas**.

Este documento define cómo se organiza el juego antes de ampliar el prototipo. La escena actual
(`scenes/test_level.tscn` + `scripts/`) solo sirve para verificar el entorno y **no sigue todavía
esta arquitectura**: se migrará en la fase F1 (ver [Plan por etapas](#11-plan-por-etapas)).

---

## 1. Base

| Decisión | Valor |
|---|---|
| Motor | Godot **4.7.2-stable**, edición estándar, **GDScript** |
| Renderizador | **Compatibility** (OpenGL ES 3; ANGLE en Windows cuando el driver lo requiere) |
| Juego | 2D, vista lateral, 2–6 participantes (humanos o bots) |
| Proyecto | **Uno solo** para Android, iOS, PC (pruebas) y, más adelante, servidor dedicado |
| Física | `CharacterBody2D` para personajes y `AnimatableBody2D` para plataformas móviles. Se evita `RigidBody2D` en lo jugable: es más difícil de sincronizar y de reproducir en el servidor |
| Ritmo | Física a 60 ticks/s (`physics/common/physics_ticks_per_second`). La simulación avanza solo en `_physics_process` |

Principios:

1. **Simulación separada de la presentación.** Las reglas (moverse, empujar, quemarse, recoger,
   ganar) no dependen de sprites, sonidos, interfaz ni controles táctiles. Deben poder ejecutarse
   sin ventana (`--headless`): es lo que hará el servidor dedicado y lo que usan las pruebas automáticas.
2. **Una sola fuente de verdad por partida:** la *autoridad* (anfitrión o servidor). Nadie más
   decide impactos, recogidas, lava, eliminaciones ni victoria.
3. **Mismas acciones para todos.** Humanos, bots y jugadores remotos controlan el personaje con el
   mismo `InputFrame`; el personaje aplica las mismas reglas sin saber quién lo controla.
4. **Datos en Resources** (`.tres`), no números sueltos en scripts.
5. **Componentes pequeños** con una responsabilidad; nada de un script central que lo haga todo.
6. **Por etapas:** primero mecánicas sin conexión, después LAN y, al final, internet.

---

## 2. Capas y dependencias

```
                ┌────────────────────────────────────────────────┐
                │ ui/  menús · HUD · controles táctiles · results │──┐
                └───────────────┬────────────────────────────────┘  │ (solo lee estado /
                                │ acciones de Input                  │  envía órdenes)
┌──────────────────┐   ┌────────▼─────────┐   ┌──────────────────┐  │
│ presentation/    │   │ controllers/     │   │ net/             │  │
│ vistas, anim.,   │   │ humano · bot ·   │   │ ENet · lobby ·   │  │
│ VFX, audio       │   │ remoto           │   │ snapshots        │  │
└────────┬─────────┘   └────────┬─────────┘   └───┬──────────┬───┘  │
         │ señales/estado       │ InputFrame      │ InputFrame│estado│
         │ (solo lectura)       ▼                 ▼           │      │
         │            ┌──────────────────────────────────────┐ │      │
         └───────────►│ game/  SIMULACIÓN (reglas)            │◄┘◄─────┘
                      │ personaje · arena · partida · herram. │
                      └──────────────────┬───────────────────┘
                                         ▼
                      data/  Resources (.tres)  ·  assets/ (solo presentación)
```

Reglas de dependencia (se revisan en cada entrega):

| Módulo | Puede usar | **No** puede usar |
|---|---|---|
| `game/` | `data/`, utilidades `core/` | `ui/`, `presentation/`, `net/`, `Input` |
| `controllers/` | `game/` (API pública), `Input` (solo el humano) | `ui/`, `presentation/` |
| `presentation/` | `game/` en solo lectura (señales y propiedades), `assets/` | modificar estado de `game/` |
| `ui/` | `game/` (lectura), `Input` (acciones), `net/` (crear/unirse a sala) | modificar estado de `game/` |
| `net/` | `game/`, `controllers/` | `ui/` (la UI escucha a `net/`, no al revés) |
| `dashboard/` | `project-status.json` | **nada del juego** (herramienta aparte) |

---

## 3. Estructura de carpetas (objetivo)

```
FinalFire/
├─ project.godot · export_presets.cfg · project-status.json · ARCHITECTURE.md · README.md
├─ core/                     utilidades sin estado: InputFrame, constantes, helpers
├─ game/                     SIMULACIÓN — sin sprites, sonidos ni UI
│  ├─ character/             fighter.gd (CharacterBody2D), estados, empujón, protección
│  ├─ arena/                 plataformas (inclinación, desgaste), lava, avisos de peligro
│  ├─ match/                 match_controller.gd (estados), participantes, fases, eliminaciones
│  └─ tools/                 tool_pickup.gd, tool_state.gd, efectos de cada herramienta
├─ controllers/              human_controller.gd · bot_controller.gd · remote_controller.gd
├─ net/                      net_session.gd (autoload) · lobby · protocolo · snapshots · interpolación
├─ presentation/             fighter_view.tscn, arena_view, vfx/, audio_director.gd
├─ ui/                       menus/ · hud/ · touch/ (joystick y botones) · results/
├─ data/                     instancias .tres
│  ├─ characters/            stats_default.tres …
│  ├─ tools/                 shield.tres · plank.tres · hook.tres …
│  ├─ phases/  arenas/  rules/
├─ assets/                   SOLO archivos fuente de presentación
│  ├─ sprites/  animations/  audio/sfx/  audio/music/  fonts/  vfx/
├─ scenes/                   escenas de entrada: main.tscn, match.tscn, test_level.tscn
├─ tests/                    pruebas headless (SceneTree), sin UI
├─ tools/                    scripts de desarrollo (PowerShell, Node, capturas) — no se exportan
├─ dashboard/                panel de progreso (.gdignore) — no se exporta
├─ docs/                     documentación, capturas y referencias (.gdignore)
└─ builds/                   compilaciones (ignoradas por Git)
```

Convenciones: archivos y carpetas en `snake_case`; clases con `class_name` en `PascalCase`;
señales en pasado (`jumped`, `eliminated`, `tool_picked`); una escena por entidad con su script al lado
o en la carpeta del módulo; las escenas de `game/` no contienen nodos visuales salvo, como hijo
reemplazable, su vista (ver §4.1).

---

## 4. Módulos

### 4.1 Personaje (`game/character/`)

`Fighter` (`CharacterBody2D`) — movimiento, salto, empujón, protección y eliminación.

- Consume **un `InputFrame` por tick** (`apply_input(frame)`); no lee `Input` directamente.
- Máquina de estados: `IDLE · RUN · JUMP · FALL · PUSH · STUNNED (retroceso) · SHIELDED · ELIMINATED`.
- **Empujón:** área corta delante del personaje; la autoridad aplica un retroceso (`knockback`)
  al afectado según `push_force` y su `knockback_resistance`; enfriamiento `push_cooldown`.
- **Protección:** reduce o anula el retroceso durante `shield_duration` (base o herramienta).
- **Eliminación:** al tocar lava o salir de los límites → `ELIMINATED`, se desactiva la colisión
  y emite `eliminated(cause, by)`; la partida decide qué pasa después.
- Señales para la presentación: `state_changed`, `jumped`, `landed`, `pushed(target)`,
  `was_pushed(by)`, `shield_changed`, `eliminated`.
- Parámetros en `CharacterStats` (Resource): velocidad, aceleración, fricción, salto, gravedad,
  coyote time, buffer de salto, fuerza y enfriamiento del empujón, resistencia, protección.

**Vista separada:** `fighter.tscn` tiene un hijo `View` (escena de `presentation/`) que solo lee el
estado y las señales (animación, partículas, sonido). En el servidor dedicado
(`OS.has_feature("dedicated_server")` o `DisplayServer.get_name() == "headless"`) la vista no se crea.

### 4.2 Controladores (`controllers/`)

Todos producen el mismo `InputFrame` y se lo entregan al `Fighter` cada tick:

```
InputFrame { tick, move_x ∈ [-1, 1], jump_pressed, jump_held, push_pressed, tool_pressed }
```

| Controlador | Dónde corre | Fuente |
|---|---|---|
| `HumanController` | dispositivo del jugador | acciones del `InputMap` (teclado, mando y controles táctiles generan las **mismas** acciones) |
| `BotController` | **en la autoridad** | decide con la información de la partida; no puede hacer nada que un humano no pueda |
| `RemoteController` | en la autoridad | último `InputFrame` recibido por red de ese jugador (validado) |

La autoridad valida cada `InputFrame` (rangos, frecuencia, que el jugador siga vivo); nunca acepta
posiciones ni resultados enviados por un cliente.

### 4.3 Arena (`game/arena/`)

- `Platform` (`AnimatableBody2D`) con componentes opcionales:
  - **Inclinación:** gira según el peso/posición de quienes están encima, con límite y retorno.
  - **Desgaste:** pierde resistencia mientras está ocupada o por calendario de la fase; etapas
    `INTACTA → AGRIETADA → CRÍTICA → CAE`. Al caer desactiva la colisión.
  - **Cadenas / suspensión:** variante que se balancea o se suelta.
- `LavaZone` (`Area2D`): nivel de lava por fase; zonas de suelo que pasan a lava.
- **Señales de peligro:** todo peligro se anuncia antes de activarse:
  `hazard_warned(kind, area, seconds)` → la presentación muestra brillo/temblor/sonido.
- Configuración en `ArenaDefinition` + `PhaseDefinition` (Resources).

### 4.4 Partida (`game/match/`)

`MatchController` — máquina de estados que **solo corre en la autoridad**:

```
LOBBY → COUNTDOWN → PHASE(n) → … → RESULTS
                     │  aparece 1 herramienta, avanzan lava y desgaste
                     └─ eliminaciones; si queda ≤ 1 participante vivo → RESULTS
```

- Participantes (2–6): id, nombre, color, tipo (`HUMAN_LOCAL`, `HUMAN_REMOTE`, `BOT`), peer id, estado.
- Fases según `MatchRules.phases` (lista de `PhaseDefinition`): duración, calendario de lava y
  desgaste, conjunto de herramientas posibles, puntos de aparición.
- Emite eventos de partida (`participant_eliminated`, `phase_started`, `tool_spawned`,
  `match_finished(winner)`), que la UI, el audio y la red escuchan.
- Ganador: último participante vivo; si se agota el tiempo, regla definida en `MatchRules`.

### 4.5 Herramientas (`game/tools/`)

- **Una sola herramienta compartida por fase**: `MatchController` crea exactamente un `ToolPickup`
  al inicio de cada fase y no crea otro hasta la siguiente fase.
- Estados: `SPAWNED → HELD(owner) → ACTIVE(restante) → CONSUMED`. Si el portador es eliminado,
  la herramienta cae donde estaba (si cae en lava, se destruye) — regla configurable.
- Recogida, propietario, activación, duración, usos y consumo los decide **la autoridad**.
- `ToolDefinition` (Resource): id, nombre, icono, duración, usos, enfriamiento y escena del efecto.
  Candidatas de la referencia visual: escudo, tablón, gancho/cuerda.

### 4.6 Interfaz (`ui/`)

- Menús (inicio, crear/unirse a sala, ajustes), lobby, HUD (`VIVOS n/6`, cronómetro, pausa,
  ranura de herramienta), resultados.
- **Controles táctiles:** joystick virtual + botones de salto, empujar y herramienta. Solo
  convierten toques en **acciones del InputMap** (como ahora `touch_button.gd`); no conocen al personaje.
  Multitáctiles, anclados a las esquinas, con margen de área segura.
- La UI nunca cambia el estado del juego directamente: lee estado y emite órdenes (p. ej. «listo» en el lobby).

### 4.7 Audio y efectos (`presentation/`)

- `AudioDirector` (autoload) y vistas/VFX **reaccionan a señales** del juego; no deciden reglas.
- Buses: `Master`, `Music`, `SFX`, `UI`. En el servidor dedicado no se instancian.
- En un cliente remoto, los mismos eventos llegan desde la red (§5.4), así que la presentación
  funciona igual sin conexión, como anfitrión o como cliente.

### 4.8 Red (`net/`)

Conexión, lobby, mensajes, sincronización y desconexiones. Ver §5.

---

## 5. Multijugador

### 5.1 Modelo: cliente-servidor con autoridad del servidor

| Modo | Simulación | Presentación | Red |
|---|---|---|---|
| **Sin conexión** (F1–F2) | local | sí | no |
| **Anfitrión** (LAN, F3) | local = autoridad | sí | servidor ENet + su propio jugador |
| **Cliente** | no (salvo predicción, §5.5) | sí | cliente ENet |
| **Servidor dedicado** (F6) | autoridad | **no** (`--headless`, `dedicated_server`) | servidor ENet |

El mismo `MatchController` y las mismas reglas funcionan en los cuatro modos: lo que cambia es qué
controladores se conectan y si existe la vista. Así el modo sin conexión de F1–F2 ya es la «autoridad»
y no hay que reescribir las reglas para la red.

**Flujo por tick (en red):**

1. Cliente: `HumanController` genera el `InputFrame` → se envía a la autoridad
   (`unreliable_ordered`, con número de tick; se repiten los últimos frames para tolerar pérdidas).
2. Autoridad: `RemoteController` entrega el frame válido al `Fighter`; los bots deciden; se simula.
3. Autoridad: cada 2–3 ticks (20–30 Hz) envía un **snapshot** compacto (posiciones, velocidades,
   estados, plataformas, lava, herramienta) por `unreliable_ordered`.
4. Autoridad: los **eventos importantes** (eliminación, recogida, inicio de fase, ganador) se envían
   `reliable`, para que no se pierdan aunque se pierda un snapshot.
5. Cliente: interpola entre snapshots y dispara la presentación con los eventos.

### 5.2 Transporte: evaluación de ENet

| | ENet (`ENetMultiplayerPeer`) |
|---|---|
| Plataformas | Android, iOS, Windows, macOS, Linux (nativas). **No** web (allí solo WebSocket/WebRTC; no es objetivo) |
| Protocolo | UDP con canales fiables y no fiables; encaja con inputs/snapshots y eventos |
| Integración | Nativo en Godot, sin plugins; RPC y `SceneMultiplayer` de alto nivel |
| Limitación | **No atraviesa NAT**: el cliente necesita una IP:puerto alcanzable del servidor |
| Requisito Android | permiso **`INTERNET`** en el preset de exportación (también para LAN) |

**Decisión:** ENet para todas las conexiones nativas. Se usará el sistema de RPC de Godot, con
snapshots e inputs propios (no `MultiplayerSynchronizer` para los personajes), porque la
interpolación y la reconciliación necesitan números de tick y control del formato.
`MultiplayerSpawner` puede usarse para crear/quitar participantes si simplifica el código.
**A validar** con pruebas en F3.

### 5.3 LAN e internet NO funcionan igual

**LAN (F3)** — un jugador aloja (anfitrión = servidor + jugador):
- Conexión por **IP local manual** (o código QR con la IP) como método que siempre funciona.
- Descubrimiento automático por **broadcast UDP** como comodidad. Limitaciones conocidas:
  algunos routers/redes de invitados aíslan dispositivos; en **iOS** el acceso a la red local pide
  permiso al usuario (`NSLocalNetworkUsageDescription`) y el broadcast/multicast requiere un
  *entitlement* que Apple concede a petición; en Android puede requerir permisos de multicast.
  Por eso la IP manual se mantiene siempre como alternativa.
- Puerto UDP fijo configurable (p. ej. 24680). En Windows, el firewall preguntará la primera vez.

**Internet (F6)** — no se asume que basta con lo de LAN:
- Un móvil en **datos móviles** suele estar tras CGNAT: **no puede alojar** partidas por internet.
- En casa, alojar exige **reenviar el puerto UDP** en el router o UPnP (clase `UPNP` de Godot),
  que a menudo está desactivado. No es fiable para jugadores normales.
- **Plan:** servidores **dedicados headless** (exportación «dedicated server», Linux) con IP pública,
  más un **servicio de salas** ligero (HTTP/WebSocket) que crea/lista salas, asigna un servidor
  (IP:puerto) y entrega un **token de acceso** que el servidor de juego valida.
- Alternativas a evaluar entonces: relé (TURN/WebRTC) o servicios de terceros con relé.
- Alojar servidores **cuesta dinero**: es una decisión tuya (D6) y no se contrata nada ahora.

### 5.4 Sincronización

- **Tick de simulación:** 60 Hz en la autoridad. **Snapshots:** 20–30 Hz (ajustable).
- **Interpolación** (primero): el cliente muestra a los demás ~100 ms en el pasado, interpolando
  entre dos snapshots; extrapolación corta si falta uno.
- **Predicción y reconciliación** (solo si las pruebas lo piden): el cliente simula su propio
  personaje con el mismo `Fighter` y su historial de `InputFrame`; al llegar el snapshot corrige y
  reaplica los inputs no confirmados. Por eso `Fighter` debe ser determinista *en lo posible*
  (sin `randf()` sin semilla, sin depender del framerate).
- **Versión de protocolo** en el saludo inicial: si cliente y servidor difieren, se rechaza la conexión
  con un mensaje claro.

### 5.5 Bots

Se ejecutan **solo en la autoridad** (anfitrión o servidor dedicado), como un `BotController` más.
Los clientes los ven como cualquier otro participante remoto.

### 5.6 Desconexiones (versión 1)

| Situación | Comportamiento |
|---|---|
| Un cliente se desconecta en el **lobby** | Se libera su plaza; los demás ven el cambio |
| Un cliente se desconecta **en partida** | Tiempo de espera de ENet (~5 s). Después, su personaje queda **eliminado por desconexión** (no cuenta como eliminación de nadie) y el HUD lo indica. Cuando existan bots (F4), la regla podrá ser «lo controla un bot hasta el final» (`MatchRules.on_disconnect = ELIMINATE | BOT`) |
| Quedan < 2 participantes vivos | Termina la fase/partida con las reglas normales de victoria |
| **El anfitrión abandona** o se cae | La partida **termina para todos**: los clientes vuelven al menú con «El anfitrión cerró la partida». **Sin migración de anfitrión** en la v1 |
| El servidor dedicado cae | Igual que el anfitrión |
| Reconexión | **No** en la v1. Más adelante: volver con el token de sala durante un periodo de gracia |

### 5.7 Seguridad básica

- Los clientes solo envían `InputFrame` y órdenes de lobby; la autoridad valida todo.
- Límite de frecuencia de mensajes por peer; tamaños máximos; nombres saneados.
- Nunca se envían ni se guardan en el repositorio claves, tokens ni contraseñas.

---

## 6. Datos y recursos

| Resource (`class_name`) | Contenido | Instancias en |
|---|---|---|
| `CharacterStats` | movimiento, salto, empujón, resistencia, protección | `data/characters/` |
| `ToolDefinition` | id, nombre, icono, duración, usos, enfriamiento, escena del efecto | `data/tools/` |
| `PhaseDefinition` | duración, lava, desgaste, herramientas posibles, apariciones | `data/phases/` |
| `ArenaDefinition` | escena de arena, límites, puntos de aparición | `data/arenas/` |
| `MatchRules` | 2–6 participantes, fases, regla de desconexión, desempate | `data/rules/` |

- Los scripts reciben su Resource por `@export`; los valores no se repiten en el código.
- Las imágenes, animaciones (`SpriteFrames`/`AnimationPlayer`), sonidos, escenas y código van en
  carpetas separadas (§3). `game/` no referencia `assets/`.
- Las reglas no dependen de la UI ni de los controles táctiles, para reutilizarlas en la **campaña**
  (otro `MatchRules`/modo con los mismos `Fighter`, arena, herramientas y bots).

---

## 7. Autoloads (mínimos)

| Autoload | Responsabilidad |
|---|---|
| `NetSession` | estado de la conexión (sin conexión / anfitrión / cliente / dedicado), peers, versión de protocolo |
| `Settings` | ajustes del usuario (volumen, controles, nombre) en `user://` |
| `AudioDirector` | reproduce sonidos en respuesta a eventos; no existe en el servidor dedicado |

El estado de la partida **no** es global: vive en la escena de la partida y se destruye con ella.

---

## 8. Plataformas

- **Android:** APK de depuración ahora; AAB firmado con clave propia para publicar (F7, requiere NDK).
  Permiso `INTERNET` desde F3.
- **iOS:** mismo proyecto; exportación con Xcode en un Mac ([docs/IOS.md](docs/IOS.md)).
  Permiso de red local y, si se usa descubrimiento por broadcast, el entitlement de multicast.
- **PC (Windows):** pruebas, varias instancias locales para probar la red en un solo equipo.
- **Servidor dedicado (Linux, headless):** preset «dedicated server» en F6.

---

## 9. Pruebas

- `tests/` con scripts `SceneTree` ejecutables en `--headless` (como `tools/smoke_test.gd`):
  reglas del personaje, arena, partida y herramientas **sin UI**.
- Partidas solo de bots en headless como prueba de estabilidad (F4).
- Pruebas de red: dos o más instancias en el PC (anfitrión + clientes) y luego varios teléfonos en la misma Wi-Fi.
- Cada prueba ejecutada se registra en `project-status.json`.

---

## 10. Panel de progreso

Herramienta de desarrollo **independiente del juego**: `dashboard/` (con `.gdignore`), servidor Node
sin dependencias que solo lee `project-status.json`. No se exporta, no es necesaria para jugar y el
juego no la conoce.

---

## 11. Plan por etapas

| Fase | Contenido | Red |
|---|---|---|
| F0 | Entorno y escena de comprobación | — |
| **F1** | Migrar a esta estructura: `InputFrame`, controladores, `Fighter` con empujón y protección, Resources, arena (inclinación, desgaste, lava, avisos), vista separada, controles táctiles definitivos | sin conexión |
| **F2** | Partida: participantes, fases, una herramienta por fase, eliminaciones, ganador, HUD y resultados. Prueba con 2 jugadores locales en el PC | sin conexión |
| **F3** | Multijugador LAN: ENet, anfitrión-servidor, lobby, IP manual + descubrimiento, snapshots + interpolación, desconexiones v1 | LAN |
| F4 | Bots en la autoridad | LAN |
| F5 | Arte, animación y sonido (según la [dirección visual](docs/DIRECCION_VISUAL.md)) | — |
| F6 | Internet: servidor dedicado headless + servicio de salas (tras decidir D6) | internet |
| F7 | Publicación Android | — |
| F8 | iOS (requiere Mac) | — |
| F9 | Campaña reutilizando las reglas | — |

No se construye infraestructura de internet antes de validar las mecánicas (F1–F2) y la LAN (F3).

---

## 12. Registro de decisiones

| # | Decisión | Motivo | Estado |
|---|---|---|---|
| A1 | Godot 4.7.2, GDScript, Compatibility | Equipo modesto, compatibilidad móvil | Aplicada |
| A2 | Simulación separada de la presentación | Servidor headless, pruebas automáticas, campaña | Aceptada |
| A3 | Cliente-servidor con autoridad; anfitrión en LAN | Evitar trampas y desincronizaciones; sin costes al inicio | Aceptada (instrucciones del 14-10-2026) |
| A4 | ENet para conexiones nativas | Nativo, UDP, móvil y PC | Aceptada, a validar en F3 |
| A5 | Snapshots/inputs propios vía RPC en vez de `MultiplayerSynchronizer` para personajes | Interpolación y reconciliación con ticks | Propuesta, a validar en F3 |
| A6 | `CharacterBody2D`/`AnimatableBody2D` en vez de `RigidBody2D` | Control y sincronización | Propuesta |
| A7 | Sin migración de anfitrión ni reconexión en v1 | Complejidad | Aceptada |
| A8 | Internet con servidor dedicado + servicio de salas | NAT/CGNAT impide alojar desde móviles | Propuesta; hosting pendiente (D6) |
| A9 | Datos en Resources `.tres` | Ajuste sin tocar código | Aceptada |
| A10 | Panel de progreso fuera del juego | Herramienta de desarrollo | Aplicada |
