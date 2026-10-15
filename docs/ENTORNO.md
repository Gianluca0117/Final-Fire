# Entorno de desarrollo

Registro de la configuración realizada el 2026-10-14. Comprobación rápida de todo:
`powershell -ExecutionPolicy Bypass -File tools\check-env.ps1`

## Equipo

| | |
|---|---|
| Sistema | Windows 10 Pro 22H2 (10.0.19045), 64 bits |
| CPU | Intel Core i5-6500 @ 3,2 GHz, 4 núcleos / 4 hilos |
| RAM | 7,9 GB (≈2,4 GB libres al revisar) |
| GPU | Intel HD Graphics 530 (driver 31.0.101.2111) |
| Disco C: | 77,5 GB libres antes de instalar |

Godot detecta que el driver OpenGL de la HD 530 es de baja calidad y usa **ANGLE (Direct3D 11)**
automáticamente para el renderizador Compatibility. Funciona correctamente (prueba de captura aprobada).

## Herramientas

| Herramienta | Versión | Ruta | Estado |
|---|---|---|---|
| Godot (estándar, GDScript) | 4.7.2-stable (`ed1daf0bf`) | `%LOCALAPPDATA%\Programs\Godot\4.7.2-stable\` | **Instalado** |
| Plantillas de exportación | 4.7.2.stable (solo Android) | `%APPDATA%\Godot\export_templates\4.7.2.stable\` | **Instalado** |
| OpenJDK (Eclipse Temurin) | 17.0.20.1+1 | `%LOCALAPPDATA%\Programs\Java\jdk-17.0.20.1+1\` | **Instalado** |
| Android cmdline-tools | 15859902 (latest) | `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\` | **Instalado** |
| Android build-tools | 35.0.1 | `%LOCALAPPDATA%\Android\Sdk\build-tools\35.0.1\` | **Instalado** |
| Android SDK | platforms 35, 36, 37.0; build-tools 34/35/36 | `%LOCALAPPDATA%\Android\Sdk\` | Reutilizado |
| Android platform-tools (adb) | 37.0.1 | `%LOCALAPPDATA%\Android\Sdk\platform-tools\` | Reutilizado |
| Android Studio | 262.9437 | `C:\Program Files\Android\Android Studio\` | Reutilizado (no es necesario abrirlo) |
| Git | 2.56.0.windows.2 | `C:\Program Files\Git\` | Reutilizado |
| Node.js (panel) | 24.21.0 | `C:\Program Files\nodejs\` | Reutilizado |
| Oracle JDK | 27 | `C:\Program Files\Java\jdk-27\` | Sin tocar (sigue en el PATH) |

Todo lo instalado está en el perfil del usuario: **no se necesitaron permisos de administrador**.
No se modificó el PATH ni se crearon variables de entorno globales (JAVA_HOME, ANDROID_HOME),
para no afectar a otros proyectos. Las rutas están guardadas en los ajustes del editor de Godot
(`%APPDATA%\Godot\editor_settings-4.7.tres`):

```
export/android/java_sdk_path    = %LOCALAPPDATA%\Programs\Java\jdk-17.0.20.1+1
export/android/android_sdk_path = %LOCALAPPDATA%\Android\Sdk
export/android/debug_keystore   = %APPDATA%\Godot\keystores\debug.keystore   (generada por Godot; alias androiddebugkey)
```

Para tener las rutas en una consola de PowerShell: `. .\tools\env.ps1` (solo afecta a esa sesión).

## Descargas y verificación

Todas desde fuentes oficiales, guardadas en `%USERPROFILE%\Downloads\FinalFire-setup\`
(se pueden borrar; el `.tpz` completo, de 1,2 GB, solo hace falta si quieres plantillas de otras plataformas).

| Archivo | Origen | Verificación |
|---|---|---|
| `Godot_v4.7.2-stable_win64.exe.zip` | github.com/godotengine/godot/releases (enlazado desde godotengine.org) | SHA-512 = `SHA512-SUMS.txt` ✔ |
| `Godot_v4.7.2-stable_export_templates.tpz` | ídem | SHA-512 = `SHA512-SUMS.txt` ✔ |
| `OpenJDK17U-jdk_x64_windows_hotspot_17.0.20.1_1.zip` | api.adoptium.net / GitHub de Adoptium | SHA-256 = API de Adoptium ✔ |
| `commandlinetools-win-15859902_latest.zip` | dl.google.com (developer.android.com/studio) | SHA-256 publicado en la página ✔ |
| `build-tools;35.0.1` | `sdkmanager` (repositorio oficial de Google) | verificado por sdkmanager |

La licencia del Android SDK ya estaba aceptada (desde Android Studio), así que no hubo que aceptar nada nuevo.

## Requisitos según la documentación de Godot 4.7

[Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html):
OpenJDK 17 · platform-tools ≥ 35.0.0 · build-tools 35.0.1 · platform 35 · cmdline-tools ·
NDK r28b y CMake 3.10.2 (**no instalados**: solo hacen falta para compilaciones Gradle/AAB o
plugins; ocupan ~2–3 GB). Cuando haga falta (fase de publicación):

```powershell
. .\tools\env.ps1; $env:JAVA_HOME = $FF_JDK
& "$FF_SDK\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="$FF_SDK" "ndk;28.1.13356709" "cmake;3.10.2.4988404"
```

Avisos conocidos e inofensivos de `sdkmanager`: indica que está obsoleto en favor de la nueva
CLI `android`, y que `platforms;android-35-ext15` está en la carpeta `android-35` (así lo instaló
Android Studio; no se tocó).

## Comandos de comprobación

```powershell
. .\tools\env.ps1
& $GODOT_CLI --version                                                     # 4.7.2.stable.official.ed1daf0bf
& "$FF_JDK\bin\java.exe" -version                                          # 17.0.20.1
& $ADB devices -l                                                          # teléfonos conectados
& $GODOT_CLI --headless --fixed-fps 60 --path . -s res://tests/run_tests.gd  # pruebas automáticas
& $GODOT_CLI --headless --path . --export-debug Android $FF_APK             # exportar APK
$env:JAVA_HOME = $FF_JDK; & "$FF_SDK\build-tools\35.0.1\apksigner.bat" verify --print-certs $FF_APK
& "$FF_SDK\build-tools\35.0.1\aapt.exe" dump badging $FF_APK                # paquete, SDK, ABIs
```

## Qué no se instaló (a propósito)

- Emuladores ni imágenes de sistema nuevas (se prioriza el teléfono físico). Ya existían imágenes de
  Android 29 y 37 de Android Studio; no se tocaron.
- Godot .NET/C#, NDK, CMake, plantillas de otras plataformas.
- Xcode (no existe para Windows).
