# Revisión antes de publicar en GitHub

Revisión del 2026-10-14 sobre lo que quedaría expuesto al subir la rama `main` al repositorio
**público** <https://github.com/Gianluca0117/Final-Fire>.

> **Publicado** el 14-10-2026 tras esta revisión: el propietario decidió subir ahora, en público y con
> el correo institucional (D5 y D7). GitHub confirmó los 4 commits y 132 archivos, sin APK, claves ni `.godot/`.

Cómo repetirla: los comandos están al final.

## Resultado

| Qué | Resultado |
|---|---|
| Archivos que se publicarían | 129 (código, escenas, datos `.tres`, documentación, panel, 4 capturas PNG pequeñas) |
| Compilaciones (`*.apk`, `*.aab`, `*.ipa`) | **No** se publican (`builds/` y extensiones ignoradas) |
| Claves de firma (`*.keystore`, `*.jks`, `*.p12`…) | **Ninguna** en el repositorio. La clave de depuración está en `%APPDATA%\Godot\keystores\`, fuera del proyecto |
| Contraseñas, tokens, claves de API | **Ninguno** encontrado. El preset Android tiene los campos de contraseña vacíos |
| Caché del editor (`.godot/`) | Ignorada |
| Rutas absolutas del equipo (`C:\Users\…`) | **Ninguna**; la documentación usa `%LOCALAPPDATA%`, `%APPDATA%`, `%USERPROFILE%` |
| Archivos grandes (> 200 KB) | Ninguno |

## Datos personales o del equipo que SÍ quedarían visibles

1. **Tu nombre y correo en cada commit**: `Gianluca Ugalde <gugalde3775@utm.edu.ec>`.
   En un repositorio público cualquiera puede verlos (`git log`) y quedan en el historial aunque
   después se cambie la configuración. No aparece en el contenido de ningún archivo.
   - Decisión del propietario (D7): mantener el correo institucional. Para commits futuros se podría usar
     la dirección privada de GitHub (`…@users.noreply.github.com`), pero los ya publicados conservan el correo.
2. **Usuario de GitHub** `Gianluca0117` en README, `project-status.json` y `docs/ESTADO.md` (ya es público por ser el dueño del repositorio).
3. **Identificador** `com.elizsoft.finalfire` en `export_presets.cfg` y `tools/env.ps1` (normal: será público en Google Play).
4. **Datos del PC** en `docs/ENTORNO.md` y `project-status.json`: Windows 10, i5-6500, 7,9 GB de RAM,
   Intel HD 530, espacio libre en disco. Riesgo bajo; se pueden quitar si lo prefieres.
5. **Capturas** en `docs/previews/`: solo muestran el juego con gráficos provisionales.

## A tener en cuenta en próximas subidas

- La imagen de referencia (`docs/referencias/estilo-objetivo.png`) **no está** en el repositorio.
  Si la añades, al ser público, comprueba que tienes derecho a publicarla.
- Decidido el 14-10-2026: repositorio **público** (D5) y correo institucional en los commits (D7).

## Comandos usados

```bash
git ls-files                                   # qué se publicaría
git grep -nIiE "(api[_-]?key|secret|token|passw(or)?d|BEGIN (RSA|EC|OPENSSH|PRIVATE))"
git grep -nIoE "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}"
git grep -nIF "Users"
git log --format='%an <%ae>' | sort | uniq -c   # autores de los commits
```
