# Instala y abre el APK de depuración en un teléfono Android conectado por USB.
# Usa "adb install -r" (reemplaza la app si ya existe CONSERVANDO sus datos).
# No desinstala nada ni borra datos de otras aplicaciones.
#   powershell -ExecutionPolicy Bypass -File tools\install-apk.ps1
. "$PSScriptRoot\env.ps1"

if (-not (Test-Path $FF_APK)) { Write-Host "No existe $FF_APK. Ejecuta antes tools\export-android.ps1" -ForegroundColor Red; exit 1 }

$lines = & $ADB devices | Select-Object -Skip 1 | Where-Object { $_.Trim() }
$ready = @($lines | Where-Object { $_ -match "\tdevice$" })
$unauth = @($lines | Where-Object { $_ -match "\tunauthorized$" })

if ($unauth.Count) { Write-Host "Hay un teléfono sin autorizar: acepta el aviso 'Permitir depuración USB' en su pantalla y vuelve a ejecutar." -ForegroundColor Yellow }
if ($ready.Count -eq 0) { Write-Host "No hay ningún teléfono conectado y autorizado (adb devices)." -ForegroundColor Red; exit 1 }
if ($ready.Count -gt 1) { Write-Host "Hay varios dispositivos; se usará el primero: $($ready[0])" -ForegroundColor Yellow }
$serial = ($ready[0] -split "\t")[0]

Write-Host "Dispositivo: $serial  ($(& $ADB -s $serial shell getprop ro.product.model) / Android $(& $ADB -s $serial shell getprop ro.build.version.release))"
& $ADB -s $serial install -r $FF_APK
if ($LASTEXITCODE -ne 0) { Write-Host "La instalación falló." -ForegroundColor Red; exit 1 }

& $ADB -s $serial shell monkey -p $FF_PACKAGE -c android.intent.category.LAUNCHER 1 | Out-Null
Write-Host "App instalada y abierta. Comprueba en el teléfono: orientación horizontal, botones táctiles, movimiento y salto." -ForegroundColor Green
Write-Host "Registro de Godot (Ctrl+C para salir):"
& $ADB -s $serial logcat -s godot:V
