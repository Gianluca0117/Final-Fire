# iOS: pasos pendientes (requieren un Mac)

Este equipo es Windows, así que **no se ha exportado ni compilado nada para iOS**. Godot exporta
un proyecto de Xcode, y Xcode solo funciona en macOS. No se ha contratado ningún servicio.

## Lo que ya está preparado

- Renderizador **Compatibility**, compatible con iOS.
- Orientación horizontal (`display/window/handheld/orientation = sensor_landscape`).
- Interfaz adaptable (`canvas_items` + `expand`) y margen de **área segura** (muesca / isla
  dinámica / barra de inicio) en `ui/safe_area_margin.gd`, activo en `OS.has_feature("mobile")`.
- Controles táctiles multitáctiles propios (`ui/touch/`), sin código específico de Android.
- Nada en el proyecto depende de APIs exclusivas de Android.

## Lo que necesitas

1. Un Mac con una versión de macOS compatible con la versión actual de Xcode.
2. **Xcode** (gratis en la Mac App Store).
3. Un **Apple ID**. Con una cuenta gratuita se puede instalar en tu propio iPhone para probar
   (la firma caduca a los 7 días). Para TestFlight o el App Store hace falta el
   **Apple Developer Program**, que es de pago: decisión tuya (D4 en el panel).
4. Godot **4.7.2-stable** para macOS (la misma versión que en Windows) y sus plantillas de exportación.

## Pasos en el Mac

1. Clona o copia el proyecto (sin `.godot/` ni `builds/`).
2. Abre Godot 4.7.2 → **Editor → Administrar plantillas de exportación → Descargar e instalar**.
3. Abre Xcode una vez y acepta la licencia. En **Settings → Accounts**, añade tu Apple ID.
   Anota tu **Team ID**.
4. En Godot: **Proyecto → Exportar → Añadir… → iOS**.
   - `Application → App Store Team ID`: tu Team ID.
   - `Application → Bundle Identifier`: **`com.elizsoft.finalfire`** (el mismo que en Android). Debe registrarse
     como App ID en tu cuenta de Apple Developer; Apple comprueba ahí que esté libre.
   - Iconos: Godot genera los tamaños a partir del icono del proyecto; revisa el aviso si falta alguno.
5. **Exportar proyecto** → se genera un `.xcodeproj`.
6. Abre el `.xcodeproj` en Xcode, conecta el iPhone, elige el dispositivo y pulsa **Run**.
   La primera vez, en el iPhone: **Ajustes → General → VPN y gestión de dispositivos** → confiar
   en tu certificado de desarrollador, y activa el **Modo desarrollador** si lo pide.
7. Comprueba: orientación horizontal, botones táctiles fuera de la muesca, movimiento y salto.
8. Registra el resultado en `project-status.json` (prueba TEST-06, tarea T-032).

## No intentar

- Instalar Xcode en Windows o usar máquinas virtuales de macOS no autorizadas.
- Simular una compilación iOS: hasta que se pruebe en un Mac, iOS figura como **no verificado**.
