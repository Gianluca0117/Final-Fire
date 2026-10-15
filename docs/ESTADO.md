# Estado del proyecto

> Archivo **generado** por `node tools/status-doc.mjs` a partir de `project-status.json`. No lo edites a mano.

Datos del 2026-10-14T19:19:18-05:00.

## Resumen

- **Avance del desarrollo: 56%** = 20 tareas verificadas ÷ 36 tareas registradas. Las terminadas sin verificar (1) no cuentan.
- Tareas: 20 verificadas · 1 sin verificar · 1 en curso · 2 bloqueadas · 12 pendientes.
- **Pruebas · Automatizada (PC)**: 8/8 aprobadas · 0 fallidas · 0 requieren tu intervención · 0 sin ejecutar.
- **Pruebas · En dispositivo**: 0/2 aprobadas · 0 fallidas · 1 requieren tu intervención · 1 sin ejecutar.
- **Pruebas · Revisión manual**: 3/3 aprobadas · 0 fallidas · 0 requieren tu intervención · 0 sin ejecutar.
- Problemas abiertos: 7 · Decisiones pendientes: 4.

## Fases

| Fase | Estado | Tareas verificadas | Nota |
|---|---|---|---|
| F0 · Entorno y proyecto mínimo | En curso | 8/9 | Falta la prueba en un teléfono Android físico (TEST-05). |
| F1 · Arquitectura y mecánicas base (sin conexión) | En curso | 10/11 | Implementada y verificada con pruebas automáticas en el PC. Falta la prueba en un teléfono (TEST-05) y tu valoración del control y del ritmo. |
| F2 · Partida y herramienta compartida (sin conexión) | Pendiente | 1/3 |  |
| F3 · Multijugador LAN (anfitrión-servidor) | Pendiente | 0/5 |  |
| F4 · Bots | Pendiente | 0/1 |  |
| F5 · Arte, animación y sonido | Pendiente | 0/2 |  |
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
| T-019 | F2 | MatchController: participantes, fases, eliminaciones y ganador | En curso |
| T-020 | F2 | Herramienta compartida: una por fase (candidatas: escudo, tablón, gancho) | Pendiente |
| T-021 | F2 | HUD: VIVOS n/6, cronómetro, pausa y resultados | Verificada |
| T-022 | F3 | Conexión ENet anfitrión/cliente con IP manual y permiso INTERNET | Pendiente |
| T-023 | F3 | Lobby y descubrimiento en LAN | Pendiente |
| T-024 | F3 | Snapshots e interpolación | Pendiente |
| T-025 | F3 | Desconexiones v1 (cliente y anfitrión) | Pendiente |
| T-026 | F3 | Prueba con varios teléfonos en la misma Wi-Fi | Pendiente |
| T-027 | F4 | Bots básicos en la autoridad | Pendiente |
| T-028 | F5 | Estilo artístico: 6 personajes encapuchados y cueva de lava | Pendiente |
| T-029 | F5 | Sonidos y música | Pendiente |
| T-030 | F6 | Servidor dedicado headless y servicio de salas | Pendiente |
| T-031 | F7 | Clave de publicación, NDK y AAB firmado | Pendiente |
| T-032 | F8 | Exportar el proyecto Xcode y compilar en un Mac | Bloqueada |
| T-033 | F9 | Diseño de la campaña reutilizando las reglas | Pendiente |
| T-034 | F1 | Partida local mínima: menú, cuenta atrás, eliminación, ganador, empate y revancha | Verificada |
| T-035 | F1 | Maniquí de pruebas (rival provisional hasta los bots de F4) | Verificada |
| T-036 | F7 | Identificador definitivo com.elizsoft.finalfire | Verificada |

## Última compilación

- Android · debug · 0.2.0 (2) · 2026-10-14T19:12:59-05:00
- `builds/android/FinalFire-debug.apk` (57720626 bytes) · SHA-256 `FFB00622736E0437657CC31F1F6B6418163A769BEA54FC86A73A8E6B07C0D443`
- Probada en dispositivo: **no**. Primera partida local (F1). Nuevo identificador: no actualiza a las versiones com.finalfire.game, que nunca se instalaron. Pendiente: probarla en un teléfono (docs/PRUEBA_DISPOSITIVO.md).

## Pruebas

| Id | Tipo | Prueba | Resultado | Última ejecución |
|---|---|---|---|---|
| TEST-01 | Automatizada (PC) | Entradas y controles táctiles (suite automatizada) | Aprobada | 2026-10-14T19:16:18-05:00 |
| TEST-02 | Revisión manual | Renderizado Compatibility en este PC (capturas revisadas) | Aprobada | 2026-10-14T19:12:19-05:00 |
| TEST-03 | Automatizada (PC) | Exportación del APK de depuración | Aprobada | 2026-10-14T19:12:59-05:00 |
| TEST-04 | Automatizada (PC) | Firma y manifiesto del APK | Aprobada | 2026-10-14T19:13:00-05:00 |
| TEST-05 | En dispositivo | Instalación y ejecución en un teléfono Android | Requiere tu intervención | 2026-10-14T19:13:11-05:00 |
| TEST-06 | En dispositivo | Exportación y compilación para iOS | Sin ejecutar | — |
| TEST-07 | Revisión manual | Panel de progreso: visualización y actualización en vivo | Aprobada | 2026-10-14T19:19:18-05:00 |
| TEST-08 | Automatizada (PC) | Personaje (suite automatizada) | Aprobada | 2026-10-14T19:16:18-05:00 |
| TEST-09 | Automatizada (PC) | Arena (suite automatizada) | Aprobada | 2026-10-14T19:16:18-05:00 |
| TEST-10 | Automatizada (PC) | Partida (suite automatizada) | Aprobada | 2026-10-14T19:16:18-05:00 |
| TEST-11 | Automatizada (PC) | Partidas completas con maniquíes (suite automatizada) | Aprobada | 2026-10-14T19:16:18-05:00 |
| TEST-12 | Automatizada (PC) | Validez del identificador com.elizsoft.finalfire | Aprobada | 2026-10-14 |
| TEST-13 | Revisión manual | Revisión de exposición antes de publicar | Aprobada | 2026-10-14T19:14:04-05:00 |

## Problemas abiertos

- **ISS-01** (Alto) Nunca se ha probado en un teléfono
- **ISS-02** (Bajo) El driver OpenGL de la Intel HD 530 no se usa directamente
- **ISS-04** (Info) NDK y CMake no instalados
- **ISS-05** (Info) Godot firma con apksigner de build-tools 36.0.0
- **ISS-06** (Medio) Tu correo quedaría público en los commits
- **ISS-08** (Bajo) Ajuste de jugabilidad sin probar con personas
- **ISS-09** (Info) Sin sonido

## Decisiones pendientes

- **D4** ¿Tendrás acceso a un Mac para la versión de iOS? (no bloquea F1)
- **D5** ¿Subo el proyecto al repositorio de GitHub Gianluca0117/Final-Fire?
- **D6** ¿Dónde se alojarán los servidores para jugar por internet? (no urgente, fase F6)
- **D7** ¿Qué correo debe aparecer en los commits públicos?

## Historial

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
