# Revisión antes de publicar en GitHub

Revisión del 2026-10-14 sobre lo que quedaría expuesto al subir la rama `main` al repositorio
**público** <https://github.com/Gianluca0117/Final-Fire>. **No se ha subido nada.**

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
   - Si prefieres no exponer el correo institucional: GitHub ofrece una dirección privada del tipo
     `ID+Gianluca0117@users.noreply.github.com` (GitHub → Settings → Emails → «Keep my email
     addresses private»). Como aún no se ha subido nada, se puede reescribir el autor de los commits
     locales antes del primer push (te lo hago si lo pides).
2. **Usuario de GitHub** `Gianluca0117` en README, `project-status.json` y `docs/ESTADO.md` (ya es público por ser el dueño del repositorio).
3. **Identificador** `com.elizsoft.finalfire` en `export_presets.cfg` y `tools/env.ps1` (normal: será público en Google Play).
4. **Datos del PC** en `docs/ENTORNO.md` y `project-status.json`: Windows 10, i5-6500, 7,9 GB de RAM,
   Intel HD 530, espacio libre en disco. Riesgo bajo; se pueden quitar si lo prefieres.
5. **Capturas** en `docs/previews/`: solo muestran el juego con gráficos provisionales.

## Pendiente de tu decisión

- La imagen de referencia (`docs/referencias/estilo-objetivo.png`) **no está** en el repositorio.
  Si la añades y el repositorio es público, comprueba que tienes derecho a publicarla.
- ¿Repositorio público o privado? Un repositorio privado evita casi todo lo anterior y se puede
  hacer público más tarde.

## Comandos usados

```bash
git ls-files                                   # qué se publicaría
git grep -nIiE "(api[_-]?key|secret|token|passw(or)?d|BEGIN (RSA|EC|OPENSSH|PRIVATE))"
git grep -nIoE "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}"
git grep -nIF "Users"
git log --format='%an <%ae>' | sort | uniq -c   # autores de los commits
```
