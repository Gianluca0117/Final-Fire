# Roadmap de Final Fire

> Archivo **generado** por `node tools/status-doc.mjs` a partir de `project-status.json`. No lo edites a mano.

Datos del 2026-10-14T22:14:45-05:00. Avance: **53%** (25 de 47 tareas verificadas).

Leyenda: ✅ verificada · ☑️ terminada sin verificar · 🔄 en curso · ⛔ bloqueada · ⬜ pendiente

## F0 · Entorno y proyecto mínimo — En curso (8/9)

Herramientas instaladas, proyecto Godot, escena de comprobación, APK de depuración.

> Falta la prueba en un teléfono Android físico (TEST-05).

- ✅ **T-001** Revisar el equipo y las herramientas existentes
- ✅ **T-002** Instalar Godot 4.7.2 estable (estándar) y las plantillas de exportación Android
- ✅ **T-003** Instalar JDK 17 y completar el Android SDK (cmdline-tools y build-tools 35.0.1)
- ✅ **T-004** Crear el proyecto (Compatibility, horizontal, interfaz adaptable)
- ✅ **T-005** Escena mínima: personaje, movimiento, salto, plataforma, controles táctiles y teclado
- ✅ **T-006** Repositorio Git local con .gitignore
- ✅ **T-007** Preset Android y APK de depuración firmado
- ⛔ **T-008** Instalar y ejecutar el APK en un teléfono Android físico
- ✅ **T-009** Documentación (README, entorno, iOS) y panel de progreso local

## F1 · Arquitectura y mecánicas base (sin conexión) — En curso (10/11)

Estructura de módulos, InputFrame y controladores, personaje con empujón y protección, arena con inclinación, desgaste y lava, vista separada y controles táctiles definitivos.

> Implementada y verificada con pruebas automáticas en el PC. Falta la prueba en un teléfono (TEST-05) y tu valoración del control y del ritmo.

- ✅ **T-010** Documentar la arquitectura (ARCHITECTURE.md)
- ✅ **T-011** Migrar el prototipo a la estructura de módulos (core, game, controllers, presentation, ui, data)
- ✅ **T-012** InputFrame y HumanController (mismo contrato para bots y red)
- ✅ **T-013** Fighter: movimiento, salto, empujón/agarre y protección con CharacterStats
- ✅ **T-014** Arena: plataformas con inclinación y desgaste
- ✅ **T-015** Lava y avisos de peligro
- ✅ **T-016** Vista separada de la simulación (animaciones y efectos por señales)
- ☑️ **T-017** Controles táctiles: joystick + salto, empujar y protección
- ✅ **T-018** Pruebas headless de las reglas (tests/)
- ✅ **T-034** Partida local mínima: menú, cuenta atrás, eliminación, ganador, empate y revancha
- ✅ **T-035** Maniquí de pruebas (rival provisional hasta los bots de F4)

## F2 · Partida y herramienta compartida (sin conexión) — En curso (5/8)

Participantes, fases, una herramienta por fase, eliminaciones, ganador, HUD y resultados.

> Ancla y Gancho implementados y verificados con pruebas automáticas. Faltan otras herramientas (escudo, tablón), la prueba en un teléfono y ajustar el equilibrio jugando.

- ✅ **T-019** MatchController: participantes, fases, eliminaciones y ganador
- ✅ **T-020** Herramienta única compartida por fase (aviso, recogida, caducidad, portador eliminado)
- ✅ **T-021** HUD: VIVOS n/6, cronómetro, pausa y resultados
- ✅ **T-037** Ancla: estabiliza temporalmente una plataforma inestable
- ✅ **T-038** Gancho: desplazamiento a una superficie válida con alcance limitado
- ☑️ **T-039** Apuntado táctil (mantener, arrastrar, soltar) con vista previa del destino
- ☑️ **T-040** Indicadores de posesión, uso y caducidad
- ⬜ **T-041** Más herramientas (candidatas de la referencia: escudo, tablón)

## F3 · Multijugador LAN (anfitrión-servidor) — Pendiente (0/5)

ENet, lobby, IP manual y descubrimiento, snapshots con interpolación y desconexiones v1.

- ⬜ **T-022** Conexión ENet anfitrión/cliente con IP manual y permiso INTERNET
- ⬜ **T-023** Lobby y descubrimiento en LAN
- ⬜ **T-024** Snapshots e interpolación
- ⬜ **T-025** Desconexiones v1 (cliente y anfitrión)
- ⬜ **T-026** Prueba con varios teléfonos en la misma Wi-Fi

## F4 · Bots — Pendiente (0/1)

Bots ejecutados en la autoridad de la partida con las mismas acciones que un humano.

- ⬜ **T-027** Bots básicos en la autoridad

## F5 · Arte, animación y sonido — En curso (1/8)

Recursos definitivos según docs/DIRECCION_VISUAL.md.

> Propuesta de estilo v1 (procedural) en el juego, pendiente de tu aprobación (D8). Arte definitivo y sonido, pendientes (ver ASSETS.md).

- 🔄 **T-028** Estilo artístico: 6 personajes y cueva de lava (propuesta v1) — _Implementada como propuesta (T-042 a T-045); falta tu aprobación (D8) para extenderla._
- ⬜ **T-029** Sonidos y música
- ☑️ **T-042** Personaje base animado con 6 variantes (color + detalle) y 8 animaciones
- ☑️ **T-043** Sección de arena: plataformas normales, frágiles e inclinables con estados visuales
- ☑️ **T-044** Efectos breves: aterrizaje, empujón, recogida de herramienta y eliminación
- ☑️ **T-045** HUD, menú y controles táctiles coherentes con el estilo
- ⬜ **T-046** Arte definitivo pintado (recursos listados en ASSETS.md) — _Requiere ilustración que este entorno no puede generar: especificaciones exactas en ASSETS.md §3._
- ✅ **T-047** Rendimiento del estilo en equipo modesto

## F6 · Internet: servidor dedicado y salas — Pendiente (0/1)

Servidor headless y servicio de salas. No se construye antes de validar las mecánicas y la LAN.

> Requiere decidir el alojamiento (D6).

- ⬜ **T-030** Servidor dedicado headless y servicio de salas — _Depende de D6._

## F7 · Publicación Android — Pendiente (1/2)

Clave de publicación propia, NDK, AAB y pruebas en varios dispositivos.

- ⬜ **T-031** Clave de publicación, NDK y AAB firmado
- ✅ **T-036** Identificador definitivo com.elizsoft.finalfire

## F8 · Exportación iOS — Bloqueada (0/1)

Exportar desde Godot y compilar con Xcode.

> Bloqueada: requiere un Mac con Xcode (ver D4).

- ⛔ **T-032** Exportar el proyecto Xcode y compilar en un Mac — _Requiere un Mac (ver docs/IOS.md)._

## F9 · Campaña — Pendiente (0/1)

Modo de un jugador reutilizando las reglas, la arena, las herramientas y los bots.

- ⬜ **T-033** Diseño de la campaña reutilizando las reglas
