# Estado del proyecto

> Archivo **generado** por `node tools/status-doc.mjs` a partir de `project-status.json`. No lo edites a mano.

Datos del 2026-10-14T18:40:00-05:00.

## Resumen

- **Avance del desarrollo: 21%** = 7 tareas verificadas ÷ 33 tareas registradas. Las terminadas sin verificar (2) no cuentan.
- Tareas: 7 verificadas · 2 sin verificar · 0 en curso · 2 bloqueadas · 22 pendientes.
- **Pruebas** (estabilidad, aparte del avance): 5 aprobadas · 0 fallidas · 1 requieren tu intervención · 1 sin ejecutar.
- Problemas abiertos: 5 · Decisiones pendientes: 5.

## Fases

| Fase | Estado | Tareas verificadas | Nota |
|---|---|---|---|
| F0 · Entorno y proyecto mínimo | En curso | 7/9 | Falta la prueba en un teléfono Android físico. |
| F1 · Arquitectura y mecánicas base (sin conexión) | En curso | 0/9 | Arquitectura documentada; implementación sin empezar. |
| F2 · Partida y herramienta compartida (sin conexión) | Pendiente | 0/3 |  |
| F3 · Multijugador LAN (anfitrión-servidor) | Pendiente | 0/5 |  |
| F4 · Bots | Pendiente | 0/1 |  |
| F5 · Arte, animación y sonido | Pendiente | 0/2 |  |
| F6 · Internet: servidor dedicado y salas | Pendiente | 0/1 | Requiere decidir el alojamiento (D6). |
| F7 · Publicación Android | Pendiente | 0/1 |  |
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
| T-006 | F0 | Repositorio Git local con .gitignore | Terminada sin verificar |
| T-007 | F0 | Preset Android y APK de depuración firmado | Verificada |
| T-008 | F0 | Instalar y ejecutar el APK en un teléfono Android físico | Bloqueada |
| T-009 | F0 | Documentación (README, entorno, iOS) y panel de progreso local | Verificada |
| T-010 | F1 | Documentar la arquitectura (ARCHITECTURE.md) | Terminada sin verificar |
| T-011 | F1 | Migrar el prototipo a la estructura de módulos (core, game, controllers, presentation, ui, data) | Pendiente |
| T-012 | F1 | InputFrame y HumanController (mismo contrato para bots y red) | Pendiente |
| T-013 | F1 | Fighter: movimiento, salto, empujón/agarre y protección con CharacterStats | Pendiente |
| T-014 | F1 | Arena: plataformas con inclinación y desgaste | Pendiente |
| T-015 | F1 | Lava y avisos de peligro | Pendiente |
| T-016 | F1 | Vista separada de la simulación (animaciones y efectos por señales) | Pendiente |
| T-017 | F1 | Controles táctiles definitivos: joystick + salto, empujar, herramienta y ranura | Pendiente |
| T-018 | F1 | Pruebas headless de las reglas (tests/) | Pendiente |
| T-019 | F2 | MatchController: participantes, fases, eliminaciones y ganador | Pendiente |
| T-020 | F2 | Herramienta compartida: una por fase (candidatas: escudo, tablón, gancho) | Pendiente |
| T-021 | F2 | HUD: VIVOS n/6, cronómetro, pausa y resultados | Pendiente |
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

## Última compilación

- Android · debug · 0.1.0 (1) · 2026-10-14T18:38:31-05:00
- `builds/android/FinalFire-debug.apk` (57632194 bytes) · SHA-256 `85DC2D4829C4A5BA76CD895F20A4C24510A79D244CB38441AF411A3640BE3B92`
- Probada en dispositivo: **no**. Generada con tools/export-android.ps1 tras excluir dashboard/ y project-status.json de la exportación. Pendiente: instalarla en un teléfono (TEST-05).

## Pruebas

| Id | Prueba | Resultado | Última ejecución |
|---|---|---|---|
| TEST-01 | Prueba automática de la escena (smoke test) | Aprobada | 2026-10-14T18:38:00-05:00 |
| TEST-02 | Renderizado Compatibility en este PC | Aprobada | 2026-10-14T18:24:18-05:00 |
| TEST-03 | Exportación del APK de depuración | Aprobada | 2026-10-14T18:38:31-05:00 |
| TEST-04 | Firma y manifiesto del APK | Aprobada | 2026-10-14T18:38:31-05:00 |
| TEST-05 | Instalación y ejecución en un teléfono Android | Requiere tu intervención | 2026-10-14T18:38:55-05:00 |
| TEST-06 | Exportación y compilación para iOS | Sin ejecutar | — |
| TEST-07 | Panel de progreso: visualización y actualización en vivo | Aprobada | 2026-10-14T18:38:00-05:00 |

## Problemas abiertos

- **ISS-01** (Alto) APK no probado en un dispositivo
- **ISS-02** (Bajo) El driver OpenGL de la Intel HD 530 no se usa directamente
- **ISS-03** (Bajo) Sin commit inicial en Git
- **ISS-04** (Info) NDK y CMake no instalados
- **ISS-05** (Info) Godot firma con apksigner de build-tools 36.0.0

## Decisiones pendientes

- **D1** ¿Con qué nombre y correo quieres firmar los commits de Git?
- **D2** ¿Qué identificador de paquete definitivo usará el juego?
- **D4** ¿Tendrás acceso a un Mac para la versión de iOS?
- **D5** ¿Subo el proyecto al repositorio de GitHub Gianluca0117/Final-Fire?
- **D6** ¿Dónde se alojarán los servidores para jugar por internet? (no urgente, fase F6)

## Historial

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
