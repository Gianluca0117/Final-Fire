# Estado del proyecto

> Archivo **generado** por `node tools/status-doc.mjs` a partir de `project-status.json`. No lo edites a mano.

Datos del 2026-10-14T22:56:00-05:00.

## Resumen

- **Avance del desarrollo: 45%** = 25 tareas verificadas ÷ 55 tareas registradas. Las terminadas sin verificar (14) no cuentan.
- Tareas: 25 verificadas · 14 sin verificar · 1 en curso · 2 bloqueadas · 13 pendientes.
- **Pruebas · Automatizada (PC)**: 10/10 aprobadas · 0 fallidas · 0 requieren tu intervención · 0 sin ejecutar.
- **Pruebas · En dispositivo**: 0/2 aprobadas · 0 fallidas · 1 requieren tu intervención · 1 sin ejecutar.
- **Pruebas · Revisión manual**: 6/6 aprobadas · 0 fallidas · 0 requieren tu intervención · 0 sin ejecutar.
- Problemas abiertos: 8 · Decisiones pendientes: 3.

## Fases

| Fase | Estado | Tareas verificadas | Nota |
|---|---|---|---|
| F0 · Entorno y proyecto mínimo | En curso | 8/9 | Falta la prueba en un teléfono Android físico (TEST-05). |
| F1 · Arquitectura y mecánicas base (sin conexión) | En curso | 10/11 | Implementada y verificada con pruebas automáticas en el PC. Falta la prueba en un teléfono (TEST-05) y tu valoración del control y del ritmo. |
| F2 · Partida y herramienta compartida (sin conexión) | En curso | 5/8 | Ancla y Gancho implementados y verificados con pruebas automáticas. Faltan otras herramientas (escudo, tablón), la prueba en un teléfono y ajustar el equilibrio jugando. |
| F3 · Multijugador LAN (anfitrión-servidor) | Pendiente | 0/5 |  |
| F4 · Bots | Pendiente | 0/1 |  |
| F5 · Arte, animación y sonido | En curso | 1/16 | Propuesta de estilo v1 (procedural) en el juego, pendiente de tu aprobación (D8). Arte definitivo y sonido, pendientes (ver ASSETS.md). |
| F6 · Internet: servidor dedicado y salas | Pendiente | 0/1 | Requiere decidir el alojamiento (D6). |
| F7 · Publicación Android | Pendiente | 1/2 |  |
| F8 · Exportación iOS | Bloqueada | 0/1 | Bloqueada: requiere un Mac con Xcode (ver D4). |
| F9 · Campaña | Pendiente | 0/1 |  |

## Tareas

| Id | Fase | Tarea | Estado |
|---|---|---|---|
| T-001 | F0 | Revisar el equipo y las herramientas existentes | Verificada |
| T-002 | F0 | Instalar Godot 4.7.2 estable (estándar) y las plantillas de exportación Android | Verificada |
| T-003 | F0 | Instalar JDK 17 y completar el Android SDK (cmdline-tools y build-tools 35.0.1) | Verificada |
| T-004 | F0 | Crear el proyecto (Compatibility, horizontal, interfaz adaptable) | Verificada |
| T-005 | F0 | Escena mínima: personaje, movimiento, salto, plataforma, controles táctiles y teclado | Verificada |
| T-006 | F0 | Repositorio Git local con .gitignore | Verificada |
| T-007 | F0 | Preset Android y APK de depuración firmado | Verificada |
| T-008 | F0 | Instalar y ejecutar el APK en un teléfono Android físico | Bloqueada |
| T-009 | F0 | Documentación (README, entorno, iOS) y panel de progreso local | Verificada |
| T-010 | F1 | Documentar la arquitectura (ARCHITECTURE.md) | Verificada |
| T-011 | F1 | Migrar el prototipo a la estructura de módulos (core, game, controllers, presentation, ui, data) | Verificada |
| T-012 | F1 | InputFrame y HumanController (mismo contrato para bots y red) | Verificada |
| T-013 | F1 | Fighter: movimiento, salto, empujón/agarre y protección con CharacterStats | Verificada |
| T-014 | F1 | Arena: plataformas con inclinación y desgaste | Verificada |
| T-015 | F1 | Lava y avisos de peligro | Verificada |
| T-016 | F1 | Vista separada de la simulación (animaciones y efectos por señales) | Verificada |
| T-017 | F1 | Controles táctiles: joystick + salto, empujar y protección | Terminada sin verificar |
| T-018 | F1 | Pruebas headless de las reglas (tests/) | Verificada |
| T-019 | F2 | MatchController: participantes, fases, eliminaciones y ganador | Verificada |
| T-020 | F2 | Herramienta única compartida por fase (aviso, recogida, caducidad, portador eliminado) | Verificada |
| T-021 | F2 | HUD: VIVOS n/6, cronómetro, pausa y resultados | Verificada |
| T-022 | F3 | Conexión ENet anfitrión/cliente con IP manual y permiso INTERNET | Pendiente |
| T-023 | F3 | Lobby y descubrimiento en LAN | Pendiente |
| T-024 | F3 | Snapshots e interpolación | Pendiente |
| T-025 | F3 | Desconexiones v1 (cliente y anfitrión) | Pendiente |
| T-026 | F3 | Prueba con varios teléfonos en la misma Wi-Fi | Pendiente |
| T-027 | F4 | Bots básicos en la autoridad | Pendiente |
| T-028 | F5 | Estilo artístico: 6 personajes y cueva de lava (v2 provisional) | En curso |
| T-029 | F5 | Sonidos y música | Pendiente |
| T-030 | F6 | Servidor dedicado headless y servicio de salas | Pendiente |
| T-031 | F7 | Clave de publicación, NDK y AAB firmado | Pendiente |
| T-032 | F8 | Exportar el proyecto Xcode y compilar en un Mac | Bloqueada |
| T-033 | F9 | Diseño de la campaña reutilizando las reglas | Pendiente |
| T-034 | F1 | Partida local mínima: menú, cuenta atrás, eliminación, ganador, empate y revancha | Verificada |
| T-035 | F1 | Maniquí de pruebas (rival provisional hasta los bots de F4) | Verificada |
| T-036 | F7 | Identificador definitivo com.elizsoft.finalfire | Verificada |
| T-037 | F2 | Ancla: estabiliza temporalmente una plataforma inestable | Verificada |
| T-038 | F2 | Gancho: desplazamiento a una superficie válida con alcance limitado | Verificada |
| T-039 | F2 | Apuntado táctil (mantener, arrastrar, soltar) con vista previa del destino | Terminada sin verificar |
| T-040 | F2 | Indicadores de posesión, uso y caducidad | Terminada sin verificar |
| T-041 | F2 | Más herramientas (candidatas de la referencia: escudo, tablón) | Pendiente |
| T-042 | F5 | Personaje base animado con 6 variantes (color + detalle) y 32 fotogramas (v2) | Terminada sin verificar |
| T-043 | F5 | Sección de arena: plataformas normales, frágiles e inclinables con estados visuales | Terminada sin verificar |
| T-044 | F5 | Efectos breves: aterrizaje, empujón, recogida de herramienta y eliminación | Terminada sin verificar |
| T-045 | F5 | HUD, menú y controles táctiles coherentes con el estilo | Terminada sin verificar |
| T-046 | F5 | Arte definitivo pintado (recursos listados en ASSETS.md) | Pendiente |
| T-047 | F5 | Rendimiento del estilo en equipo modesto | Verificada |
| T-048 | F5 | Revisión gráfica v2: personajes más grandes y legibles sin cambiar colisiones | Terminada sin verificar |
| T-049 | F5 | Superficies ilustradas con volumen, textura y deterioro visible | Terminada sin verificar |
| T-050 | F5 | Cueva de lava en 5 niveles con rutas de salto alcanzables | Terminada sin verificar |
| T-051 | F5 | Controles táctiles discretos, flotantes y ajustables (tamaño y opacidad) | Terminada sin verificar |
| T-052 | F5 | Estilo unificado (fuente Lilita One OFL), fondo por capas y avisos breves | Terminada sin verificar |
| T-053 | F5 | Animaciones de movimiento, impacto y aterrizaje con peso | Terminada sin verificar |
| T-054 | F5 | Comparación antes/después a igual tamaño de pantalla | Terminada sin verificar |
| T-055 | F5 | Encargar u obtener las ilustraciones externas de ASSETS.md §3 antes de extender el estilo | Pendiente |

## Última compilación

- Android · debug · 0.4.0 (4) · 2026-10-14T22:50:45-05:00
- `builds/android/FinalFire-debug.apk` (57861754 bytes) · SHA-256 `2C9662091A2FCDEDA6EE1AAF1BC841DBCA60E27AF3FCBC4B0337DAA8C8D72EA0`
- Probada en dispositivo: **no**. Revisión gráfica v2 (provisional). Actualiza a la 0.3.0 si estuviera instalada. Pendiente: probarla en un teléfono (docs/PRUEBA_DISPOSITIVO.md).

## Pruebas

| Id | Tipo | Prueba | Resultado | Última ejecución |
|---|---|---|---|---|
| TEST-01 | Automatizada (PC) | Entradas y controles táctiles (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-02 | Revisión manual | Renderizado Compatibility en este PC (capturas revisadas) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-03 | Automatizada (PC) | Exportación del APK de depuración | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-04 | Automatizada (PC) | Firma y manifiesto del APK | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-05 | En dispositivo | Instalación y ejecución en un teléfono Android | Requiere tu intervención | 2026-10-14T22:08:25-05:00 |
| TEST-06 | En dispositivo | Exportación y compilación para iOS | Sin ejecutar | — |
| TEST-07 | Revisión manual | Panel de progreso: visualización y actualización en vivo | Aprobada | 2026-10-14T22:14:45-05:00 |
| TEST-08 | Automatizada (PC) | Personaje (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-09 | Automatizada (PC) | Arena (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-10 | Automatizada (PC) | Partida (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-11 | Automatizada (PC) | Partidas completas con maniquíes (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-12 | Automatizada (PC) | Validez del identificador com.elizsoft.finalfire | Aprobada | 2026-10-14 |
| TEST-13 | Revisión manual | Revisión de exposición antes de publicar | Aprobada | 2026-10-14T22:15:16-05:00 |
| TEST-14 | Revisión manual | Publicación en GitHub verificada | Aprobada | 2026-10-14T20:01:25-05:00 |
| TEST-15 | Automatizada (PC) | Herramientas (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-16 | Automatizada (PC) | Presentación (suite automatizada) | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-17 | Revisión manual | Rendimiento del estilo v2 en este PC | Aprobada | 2026-10-14T22:50:45-05:00 |
| TEST-18 | Revisión manual | Comparación antes/después (v1 → v2) a igual tamaño | Aprobada | 2026-10-14T22:50:45-05:00 |

## Problemas abiertos

- **ISS-01** (Alto) Nunca se ha probado en un teléfono
- **ISS-02** (Bajo) El driver OpenGL de la Intel HD 530 no se usa directamente
- **ISS-04** (Info) NDK y CMake no instalados
- **ISS-05** (Info) Godot firma con apksigner de build-tools 36.0.0
- **ISS-08** (Bajo) Ajuste de jugabilidad sin probar con personas
- **ISS-09** (Info) Sin sonido
- **ISS-11** (Info) Bajadas puntuales a ≈ 31 FPS en la Intel HD 530
- **ISS-13** (Info) El arte actual es una propuesta procedural, no el definitivo

## Decisiones pendientes

- **D4** ¿Tendrás acceso a un Mac para la versión de iOS? (no bloquea F1)
- **D6** ¿Dónde se alojarán los servidores para jugar por internet? (no urgente, fase F6)
- **D8** ¿Apruebas el estilo v2 (provisional) y cómo seguimos con el arte?

## Equilibrio provisional

Valores de juego aún sin probar jugando; pueden cambiar.

| Id | Área | Parámetro | Valor | Archivo |
|---|---|---|---|---|
| BAL-01 | Fases | Duración de cada fase | 20 s | `data/phases/standard_phase.tres` |
| BAL-02 | Fases | Aviso antes de aparecer / aviso de caducidad | 1 s + 2,5 s / 3 s | `data/phases/standard_phase.tres` |
| BAL-03 | Herramientas | Radio de recogida | 40 px | `data/rules/local_match.tres` |
| BAL-04 | Herramientas | Portador eliminado | reaparece con 1,5 s de aviso si quedan ≥ 5 s de fase | `data/rules/local_match.tres` |
| BAL-05 | Ancla | Duración / aviso / alcance | 6 s / 1,5 s / 260 px | `data/tools/anchor.tres` |
| BAL-06 | Gancho | Alcance / cono / velocidad / impulso final | 380 px / ±24° / 1150 px/s / −520 | `data/tools/hook.tres` |
| BAL-07 | Plataformas | Frágil: desgaste por persona; caída tras aviso | 0,1/s; 1 s; reaparece a los 7 s | `data/platforms/fragile_platform.tres` |
| BAL-08 | Plataformas | Inclinable: inclinación máxima y por carga | 16° / 12° por persona en el borde | `data/platforms/tilting_platform.tres` |
| BAL-09 | Personaje | Empujón / protección | 640 de fuerza, 0,55 s de espera / 0,7 s, reduce al 15 %, espera 2,4 s | `data/characters/default_stats.tres` |
| BAL-10 | Lava | Oleadas de suelo / subidas / muerte súbita | cada 8 s con 2 s de aviso / 45 s y 75 s / 100 s | `data/hazards/lava_cave.tres` |
| BAL-11 | Presentación | Zoom de cámara / escala visual del personaje | 1,2 (centrada en 640, 374) / 1,12 | `scenes/match.tscn, presentation/fighter_view.gd` |
| BAL-12 | Controles | Tamaño / opacidad táctil por defecto; área táctil | 100 % (75–130 %) / 60 % (25–100 %); 1,4× el dibujo | `ui/ui_settings.gd, ui/touch/touch_style.gd` |
| BAL-13 | Arena | Niveles de la cueva y subidas de la lava | 5 niveles (suelo y = 560 … atalaya y = 165); lava 642 → 548 → 412 | `game/arena/arenas/lava_cave.tscn, data/hazards/lava_cave.tres` |

## Historial

### 2026-10-14 · Revisión gráfica v2 de la cueva de lava

Revisión concreta de una sección jugable: dibujo, composición y animación (no solo efectos). Comparación antes/después a igual tamaño. Sigue siendo provisional; las ilustraciones externas que faltan están en ASSETS.md §3.

- Personajes ≈ 80 px en pantalla (cámara 1,2 + escala visual 1,12) con colisión 40×56 intacta
- Superficies con volumen, textura y deterioro visible (piedra, losa, rejilla, madera en 3 estados)
- Arena en 5 niveles con rutas comprobadas
- Joystick flotante; botones discretos con área táctil 1,4×; tamaño y opacidad ajustables
- Fuente Lilita One (OFL), iconos y HUD unificados; fondo en 5 capas más apagado
- Avisos breves bajo el marcador en lugar de mensajes centrales
- 32 fotogramas: derrape, despegue, ápice, aterrizaje con aplastamiento, golpe con congelación y destello
- Rendimiento: 64 FPS de media (v1 55–59); APK 0.4.0

Pruebas: Automatizadas: 152/152 (rutas de la arena, clips, vistas sin efecto en la simulación) (Aprobada) · Manual: comparación antes/después a igual tamaño (Aprobada) · Manual: rendimiento 64 FPS en este PC (Aprobada) · En dispositivo: tacto, legibilidad y rendimiento en un teléfono (Requiere tu intervención) · Tu aprobación del estilo v2 (D8) (Requiere tu intervención)

### 2026-10-14 · Identidad gráfica: propuesta de estilo v1

Estilo 2D cartoon procedural para revisar en el juego: personaje base con 6 variantes y 8 animaciones, arena con estados visuales claros, lava animada y avisos, efectos breves, HUD, menú y controles coherentes. Optimizado para equipos modestos. No es arte definitivo: lo que falta está en ASSETS.md.

- Personaje: rig vectorial con contorno grueso → hojas de sprites de 24 fotogramas por variante al arrancar
- Arena: piedra segura, madera frágil, losa inclinable con pivote; estados segura / agrietada / crítica / a punto de caer / anclada
- Lava con shader, suelo que avisa con señal y cuenta atrás en una capa que nada tapa, aviso de subida de la lava
- Fondo de cueva horneado una vez; efectos de polvo, impacto, recogida y humo
- HUD y menú con tema propio; VIVOS con cabezas; controles táctiles semitransparentes en reposo
- Rendimiento en Intel HD 530: 31 → 55–59 FPS de media
- ASSETS.md, galería de estilo y APK 0.3.0

Pruebas: Automatizadas: Presentación 10/10 (el arte no altera simulación ni colisiones) (Aprobada) · Manual: capturas reales del estilo v1 (Aprobada) · Manual: rendimiento 55–59 FPS en este PC (Aprobada) · En dispositivo: legibilidad y rendimiento en un teléfono (Requiere tu intervención) · Tu aprobación del estilo (D8) (Requiere tu intervención) · Manual: panel con los datos nuevos (Aprobada)

### 2026-10-14 · F2: herramienta única compartida (Ancla y Gancho)

La partida se divide en fases con una sola herramienta compartida, anunciada antes de aparecer. Implementados el Ancla y el Gancho con reglas en la autoridad, separadas de gráficos y controles, y apuntado táctil con vista previa.

- Calendario de lava separado de las fases (HazardSchedule / PhaseDefinition)
- ToolSystem: aviso, una herramienta a la vez, recogida única (empates por semilla), caducidad, portador eliminado
- Ancla (estabiliza una plataforma, avisa antes de soltarse) y Gancho (rayos en cono, no atraviesa, no sale del escenario, no se gasta si no hay destino)
- Apuntado táctil: mantener, arrastrar, soltar; teclas E (J1) y , (J2); modo de 2 jugadores conservado
- Corregido: ciclo de referencias que retenía el ToolSystem (ISS-15)
- Maniquíes que disputan la herramienta

Pruebas: Automatizadas: Herramientas 45/45 (Aprobada) · Automatizadas: Entradas 27/27 (incluye el botón de herramienta) (Aprobada) · Automatizadas: partidas completas con herramienta 16/16 (Aprobada) · En dispositivo: probar F1 y herramientas en un teléfono (Requiere tu intervención)

### 2026-10-14 · Publicación en GitHub

Primera subida de la rama main al repositorio público Gianluca0117/Final-Fire, tras la revisión de exposición y las decisiones D5 (subir ahora, público) y D7 (correo institucional).

- git push de 4 commits (entorno, F1, identificador, documentación)
- README y revisión de publicación actualizados: el proyecto ya está publicado

Pruebas: Manual: rama remota = local y archivos verificados con la API de GitHub (Aprobada) · Manual: sin APK, claves ni .godot/ en GitHub (Aprobada)

### 2026-10-14 · F1: primera partida local

Prototipo reorganizado por módulos según ARCHITECTURE.md y primera partida local jugable con gráficos provisionales contra maniquíes de prueba. Nuevo identificador com.elizsoft.finalfire y APK 0.2.0. Identidad de Git local y commits; nada subido.

- Módulos: core (InputFrame), game (personaje, arena, partida), controllers (humano, maniquí), presentation (vistas), ui (menú, HUD, táctil), data (.tres), scenes, tests
- Personaje: movimiento, salto variable, empujón con autoría y enfriamiento, protección con rebote
- Arena: plataformas que se inclinan y se derrumban con aviso, suelo que avisa y se vuelve lava, lava inferior que sube, muerte súbita
- Partida: cuenta atrás, eliminaciones, ganador o empate, resultados, revancha, pausa (también con el botón atrás de Android)
- Controles táctiles como la referencia: joystick, salto, empujar y protección (multitáctil)
- Corregido: pérdida del apoyo en plataformas giratorias (ISS-07)
- Identificador com.elizsoft.finalfire, versión 0.2.0 (2); APK B-0003
- Git: identidad local (Gianluca Ugalde) y commits; revisión de exposición antes de publicar
- Panel: pruebas separadas en automatizadas, en dispositivo y revisiones manuales

Pruebas: Automatizadas: 83/83 (entradas, personaje, arena, partida, partidas completas) (Aprobada) · Automatizada: exportación, firma y manifiesto del APK 0.2.0 (Aprobada) · Automatizada: validez del identificador (Aprobada) · Manual: capturas reales con el renderizador Compatibility (Aprobada) · Manual: revisión de exposición antes de publicar (Aprobada) · En dispositivo: instalar y jugar en un teléfono (Requiere tu intervención) · Manual: panel con los datos de F1 (Aprobada)

### 2026-10-14 · Arquitectura definida

ARCHITECTURE.md: módulos, capas y dependencias, multijugador cliente-servidor con autoridad, evaluación de ENet, LAN frente a internet, desconexiones v1, Resources y plan por etapas. Roadmap reorganizado en F0–F9 según ese plan.

- ARCHITECTURE.md (nuevo)
- Fases F1–F9 y tareas T-010 a T-033 reorganizadas por módulo
- D3 respondida por las instrucciones de arquitectura; nuevas decisiones D5 (GitHub) y D6 (alojamiento)
- Remoto origin → github.com/Gianluca0117/Final-Fire (sin push)
- APK regenerado con tools/export-android.ps1 (B-0002); horas del registro corregidas con las marcas de tiempo reales de los archivos

Pruebas: Requisitos de red contrastados con la documentación oficial de Godot 4.7 (Aprobada) · Validación del JSON y regeneración de docs/ESTADO.md (Aprobada) · Revisión de la arquitectura por tu parte (Requiere tu intervención)

### 2026-10-14 · Entorno de desarrollo y proyecto mínimo

Instalación de Godot 4.7.2, JDK 17 y las herramientas de Android que faltaban; creación del proyecto FinalFire con una escena de comprobación; generación del APK de depuración, la documentación y el panel de progreso.

- Godot 4.7.2-stable + plantillas Android en el perfil de usuario (sin permisos de administrador)
- Temurin JDK 17.0.20.1+1, Android cmdline-tools y build-tools 35.0.1
- Proyecto FinalFire: Compatibility, horizontal, interfaz adaptable y área segura
- Escena de comprobación con teclado y controles táctiles multitáctiles
- Preset Android y APK de depuración firmado
- README, docs/ENTORNO.md, docs/IOS.md, docs/ESTADO.md y panel local
- Referencia visual registrada (docs/DIRECCION_VISUAL.md) y tareas derivadas añadidas al roadmap

Pruebas: Checksums de todas las descargas (Aprobada) · Smoke test 12/12 (Aprobada) · Renderizado Compatibility (ANGLE) (Aprobada) · Exportación y firma del APK (Aprobada) · Prueba en un teléfono Android (Requiere tu intervención) · Panel: escritorio, móvil y actualización en vivo (Aprobada)
