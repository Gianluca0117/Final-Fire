# Final Fire

Juego 2D de supervivencia para 2–6 participantes (jugadores o bots): saltos, empujones,
plataformas inestables y suelo que se convierte en lava. En cada fase aparece una única
herramienta compartida que todos disputan. Primero se desarrolla el multijugador; la campaña, después.

**Estado actual:** proyecto mínimo para verificar el entorno, sin juego todavía.
El estado detallado está en [`project-status.json`](project-status.json) (fuente única),
en el [panel local](#panel-de-progreso) y en [`docs/ESTADO.md`](docs/ESTADO.md) (generado a partir del JSON).

| | |
|---|---|
| Motor | Godot **4.7.2-stable**, edición estándar (GDScript) |
| Renderizador | Compatibility (OpenGL ES 3 / WebGL 2; en este PC, mediante ANGLE) |
| Plataformas | Android (activa) · iOS (preparada, requiere Mac: [`docs/IOS.md`](docs/IOS.md)) |
| Orientación | Horizontal (gira entre ambos lados) |
| Resolución base | 1280×720, `canvas_items` + `expand`: se adapta a cualquier proporción |

Versiones, rutas y comandos de comprobación del entorno: [`docs/ENTORNO.md`](docs/ENTORNO.md).

---

## Abrir el proyecto

1. Ejecuta Godot:
   `%LOCALAPPDATA%\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64.exe`
2. En el administrador de proyectos: **Importar** → selecciona `project.godot` de esta carpeta.

O directamente desde PowerShell (en la carpeta del proyecto):

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64.exe" -e --path .
```

> Equipo con 8 GB de RAM: cierra Android Studio y el navegador mientras exportas.

## Ejecutar la escena de prueba

En el editor pulsa **F5**, o sin abrir el editor:

```powershell
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64.exe" --path .
```

| Acción | Teclado | Táctil |
|---|---|---|
| Mover | A / D o ← / → | botones `<` `>` (abajo a la izquierda) |
| Saltar | Espacio, W o ↑ (mantener = salto más alto) | botón `SALTO` (abajo a la derecha) |
| Reaparecer | R | (automático al caer) |
| Mostrar/ocultar controles táctiles | Tab | — |

En PC, el ratón emula toques, así que también puedes pulsar los botones táctiles con el clic.
Los botones son multitáctiles (se puede mantener la dirección y saltar a la vez) y respetan
el área segura de pantallas con muesca en Android e iOS.

## Pruebas automáticas

```powershell
powershell -ExecutionPolicy Bypass -File tools\check-env.ps1     # entorno (no modifica nada)
& "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://tools/smoke_test.gd
```

`smoke_test.gd` comprueba: acciones de teclado, gravedad y suelo, movimiento, salto, aterrizaje,
botón táctil, multitáctil y reaparición (12 comprobaciones). Devuelve código 0 si todo pasa.

## Exportar a Android (APK de depuración)

```powershell
powershell -ExecutionPolicy Bypass -File tools\export-android.ps1
```

Ejecuta la prueba automática, exporta con el preset **Android** y verifica la firma.
Resultado: `builds\android\FinalFire-debug.apk` (firmado con la clave de depuración de Godot;
no sirve para publicar). Desde el editor: **Proyecto → Exportar… → Android → Exportar proyecto**.

### Instalar en un teléfono

1. En el teléfono: **Ajustes → Información del teléfono →** pulsa 7 veces **Número de compilación**.
2. **Opciones de desarrollador →** activa **Depuración USB**.
3. Conéctalo por USB y acepta **Permitir depuración USB** en el teléfono.
4. Ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File tools\install-apk.ps1
```

Usa `adb install -r` (actualiza la app conservando sus datos; no borra nada más).
También puedes copiar el APK al teléfono y abrirlo (requiere permitir «instalar apps desconocidas»).

Desde el editor también funciona el botón **Ejecución remota** (icono de Android, arriba a la derecha)
con el teléfono conectado.

## Panel de progreso

```powershell
.\panel.cmd
```

(o `node dashboard\server.mjs --open`). Abre <http://127.0.0.1:8765/>, solo accesible desde este equipo.
Para verlo desde el móvil en tu Wi-Fi: `.\panel.cmd --lan` (Windows pedirá permiso en el
firewall la primera vez; no lo expone a internet).

El panel lee `project-status.json` cada 5 s y se actualiza sin recargar. **Solo muestra lo que
dice el archivo**: no marca tareas por la existencia de archivos ni de commits.
El **avance** = tareas *verificadas* ÷ tareas registradas. Las pruebas aprobadas y los
problemas abiertos se muestran aparte: avance no es lo mismo que estabilidad.

### En cada entrega

1. Actualizar en `project-status.json` las tareas, pruebas, compilaciones y recursos afectados.
   Una tarea solo pasa a `verified` con la comprobación descrita en `verification`.
2. Añadir una entrada a `history` con la fecha, los cambios y las pruebas realizadas.
3. Regenerar el resumen y validar el JSON: `node tools\status-doc.mjs`
4. Abrir el panel y comprobar que muestra la información.

Estados: fases `pending` · `in_progress` · `blocked` · `completed`;
tareas `pending` · `in_progress` · `blocked` · `done` (sin verificar) · `verified`;
pruebas `passed` · `failed` · `not_run` · `requires_user`.

## Estructura

```
FinalFire/
├─ project.godot            configuración (Compatibility, horizontal, entradas)
├─ export_presets.cfg       preset Android (sin contraseñas)
├─ project-status.json      fuente única del progreso
├─ panel.cmd                inicia el panel local
├─ scenes/                  test_level.tscn, player.tscn
├─ scripts/                 player.gd, touch_button.gd, hud.gd
├─ tools/                   pruebas y scripts (Godot + PowerShell + Node)
├─ dashboard/               panel (HTML/CSS/JS + servidor Node sin dependencias)
├─ docs/                    entorno, iOS, dirección visual, estado, capturas
└─ builds/                  compilaciones (ignoradas por Git)
```

## Git

Repositorio local en la rama `main`, con el remoto `origin` →
<https://github.com/Gianluca0117/Final-Fire> (público). **Todavía no se ha hecho ningún commit
ni push.** El `.gitignore` excluye `.godot/`, compilaciones (`*.apk`, `*.aab`, `*.ipa`…),
claves de firma (`*.keystore`, `*.jks`, `*.p12`…), credenciales (`.env`, `export_credentials.cfg`)
y archivos temporales.

Antes del primer commit hay que configurar tu identidad (solo para este repositorio):

```powershell
git config user.name "Tu nombre"
git config user.email "tu-correo@ejemplo.com"
```

> La clave de publicación (release) de Android **nunca** debe guardarse dentro del repositorio.
> Guárdala fuera (p. ej. `%USERPROFILE%\keys\`) con copia de seguridad: si se pierde, no se puede
> actualizar la app en Google Play.
