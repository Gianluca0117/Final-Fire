# Final Fire

Juego 2D de supervivencia para 2–6 participantes (jugadores o bots): saltos, empujones,
plataformas inestables y suelo que se convierte en lava. En cada fase aparece una única
herramienta compartida que todos disputan. Primero se desarrolla el multijugador; la campaña, después.

**Estado actual (F2 + estilo v1):** partida local con movimiento, salto, empujón, protección,
plataformas frágiles e inclinables, suelo de lava con aviso previo, lava que sube, eliminación y
ganador, y la **herramienta única compartida por fase** (Ancla y Gancho). Gráficos con la
**propuesta de estilo v1** (cartoon, procedural, **pendiente de aprobación**; ver [ASSETS.md](ASSETS.md)).
Los rivales son **maniquíes de prueba** (no son los bots de F4). Sin red todavía. El estado detallado está en [`project-status.json`](project-status.json) (fuente única),
en el [panel local](#panel-de-progreso) y en [`docs/ESTADO.md`](docs/ESTADO.md) (generado a partir del JSON).

| | |
|---|---|
| Motor | Godot **4.7.2-stable**, edición estándar (GDScript) |
| Renderizador | Compatibility (OpenGL ES 3; en este PC, mediante ANGLE) |
| Identificador | **`com.elizsoft.finalfire`** (Android e iOS) · versión 0.3.0 (código 3) |
| Plataformas | Android (activa) · iOS (preparada, requiere Mac: [`docs/IOS.md`](docs/IOS.md)) |
| Orientación | Horizontal (gira entre ambos lados) |
| Resolución base | 1280×720, `canvas_items` + `expand`: se adapta a cualquier proporción |

Arquitectura y plan por etapas: [`ARCHITECTURE.md`](ARCHITECTURE.md).
Versiones, rutas y comandos del entorno: [`docs/ENTORNO.md`](docs/ENTORNO.md).

---

## Abrir el proyecto

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64.exe" -e --path .
```

O abre Godot → **Importar** → `project.godot`. Con 8 GB de RAM, cierra Android Studio mientras exportas.

## Jugar en el PC

En el editor pulsa **F5**, o sin abrir el editor:

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64.exe" --path .
```

En el menú eliges cuántos maniquíes (1–5) y **Jugar**, o **2 jugadores (mismo teclado)**.

| Acción | J1 (teclado) | J2 (teclado) | Táctil (J1) |
|---|---|---|---|
| Moverse | A / D | ← / → | joystick (abajo izquierda) |
| Saltar (mantener = más alto) | W o Espacio | ↑ | flecha (abajo derecha) |
| Empujar | F | tecla `.` o 1 del teclado numérico | mano |
| Protección (corta, con enfriamiento) | G | tecla `-` o 2 del teclado numérico | escudo |
| Herramienta: **mantener = apuntar** (ves el destino), **soltar = usar** | E | tecla `,` o 3 del teclado numérico | ranura (arrastra para apuntar) |
| Pausa | Esc / P | | botón II · botón «atrás» de Android |

Con un solo jugador valen las dos combinaciones de teclas. **Tab** muestra/oculta los controles
táctiles en el PC (el ratón emula toques).

**Reglas de la partida** (valores en `data/`; los de equilibrio son **provisionales** hasta probarlos jugando):
- Si caes a la lava (abajo o en un tramo de suelo encendido) o sales del escenario, quedas eliminado.
  Si alguien te empujó en los 3 s anteriores, la eliminación cuenta para él.
- Cada 8 s un tramo del suelo **avisa durante 2 s** (parpadeo y cuenta atrás) y se vuelve lava 4,5 s.
- Las plataformas colgantes se **inclinan** hacia donde hay peso (te resbalas) y se **desgastan**
  con gente encima: se agrietan, **tiemblan como aviso** y caen; reaparecen después.
- La lava inferior **avisa y sube** a los 45 s y 75 s; desde los 100 s, **muerte súbita** (sube sin parar).
- Gana el último en pie; si los últimos caen a la vez, empate.
- **Herramienta compartida:** la partida avanza por fases de 20 s. En cada fase aparece **una sola**
  herramienta: primero se **anuncia** dónde y cuál (2,5 s), luego aparece en un pedestal. La recoge
  el primero que la toca (si llegan a la vez, el más cercano; en empate exacto, sorteo). Cada uno lleva
  como mucho una. 3 s antes del final de la fase avisa de que caduca; al acabar la fase desaparece.
  Si eliminan al portador, la herramienta vuelve a su pedestal (con aviso) si quedan ≥ 5 s de fase.
- **Ancla** (1 uso): estabiliza 6 s la plataforma donde estás (o la más cercana): no se inclina ni se
  rompe, para todos. 1,5 s antes de soltarse avisa («¡SE SUELTA!»).
- **Gancho** (1 uso): te lanza hacia la superficie apuntada (alcance 380 px). No atraviesa paredes,
  no se engancha fuera del escenario ni a la lava. Si no hay destino válido, **no se gasta**.

## Pruebas automáticas

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe" --headless --fixed-fps 60 --path . -s res://tests/run_tests.gd
```

148 comprobaciones sin pantalla (≈3 s): entradas y controles táctiles, personaje, arena, partida,
herramientas, presentación (el arte no altera la simulación ni las colisiones) y partidas
completas con maniquíes. Código de salida 0 si todo pasa.
Son **pruebas automatizadas en el PC**; no sustituyen la prueba en un teléfono.

```powershell
powershell -ExecutionPolicy Bypass -File tools\check-env.ps1     # entorno (no modifica nada)
```

## Estilo gráfico y rendimiento

- Galería de estilo con las vistas reales del juego (solo desarrollo, no se exporta): `scenes/dev/style_gallery.tscn`.
- Capturas reales: `docs/previews/` (galería, hojas de sprites, partida, menú).
- Medir rendimiento en este equipo (6 maniquíes, sin vsync):

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe" --path . --resolution 1280x720 -s res://tools/bench_render.gd -- 20 6
```

Resultado actual en la Intel HD 530: ≈ 57 FPS de media (31 con los gráficos de F1). Detalles en [ASSETS.md](ASSETS.md).

## Exportar a Android (APK de depuración)

```powershell
powershell -ExecutionPolicy Bypass -File tools\export-android.ps1
```

Ejecuta las pruebas, exporta con el preset **Android** y verifica la firma.
Resultado: `builds\android\FinalFire-debug.apk`. **Cómo probarlo en el teléfono y qué revisar:
[`docs/PRUEBA_DISPOSITIVO.md`](docs/PRUEBA_DISPOSITIVO.md).**

## Panel de progreso

```powershell
.\panel.cmd
```

Abre <http://127.0.0.1:8765/> (solo este equipo; `.\panel.cmd --lan` para verlo desde el móvil en tu Wi-Fi).
Lee `project-status.json` cada 5 s y se actualiza sin recargar. **Solo muestra lo que dice el
archivo**: no marca tareas por la existencia de archivos ni de commits. El avance = tareas
*verificadas* ÷ tareas registradas; las pruebas automatizadas, las pruebas en dispositivo y los
problemas abiertos se muestran por separado.

### En cada entrega

1. Actualizar en `project-status.json` tareas, pruebas, compilaciones y recursos afectados.
   Una tarea solo pasa a `verified` con la comprobación descrita en `verification`.
2. Añadir una entrada a `history` con fecha, cambios y pruebas realizadas.
3. Validar y regenerar el resumen: `node tools\status-doc.mjs`
4. Abrir el panel y comprobar que muestra la información.

## Estructura

```
FinalFire/
├─ project.godot · export_presets.cfg · project-status.json · ARCHITECTURE.md
├─ core/          InputFrame (contrato de acciones) y capas de colisión
├─ game/          SIMULACIÓN sin gráficos: character/ arena/ match/
├─ controllers/   humano, maniquí de pruebas (y en el futuro bots y red)
├─ presentation/  vistas (estilo v1): personaje (rig → hoja de sprites), arena, lava (shaders), efectos
├─ ui/            menú, HUD, controles táctiles, área segura
├─ data/          parámetros (.tres): personaje, plataformas, fase, reglas
├─ scenes/        main.tscn (menú ↔ partida), match.tscn (composición), dev/ (galería de estilo)
├─ tests/         pruebas automáticas headless
├─ tools/         scripts de desarrollo (no se exportan)
├─ dashboard/     panel de progreso (no se exporta)
├─ docs/          entorno, iOS, prueba en dispositivo, revisión de publicación, estado, capturas
└─ builds/        compilaciones (ignoradas por Git)
```

## Git

Rama `main` publicada en <https://github.com/Gianluca0117/Final-Fire> (**público**) desde el 14-10-2026.
Commits firmados como **Gianluca Ugalde** (identidad configurada solo en este repositorio; el correo
institucional es visible en el historial por decisión del propietario).
Antes de cada subida conviene repetir la revisión de [`docs/REVISION_PUBLICACION.md`](docs/REVISION_PUBLICACION.md).

El `.gitignore` excluye `.godot/`, compilaciones, claves de firma, credenciales y temporales.

> La clave de publicación (release) de Android **nunca** debe guardarse dentro del repositorio.
> Guárdala fuera (p. ej. `%USERPROFILE%\keys\`) con copia de seguridad: si se pierde, no se puede
> actualizar la app en Google Play.
