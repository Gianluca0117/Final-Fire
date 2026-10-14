# Ejecuta la prueba automática y exporta el APK de depuración.
#   powershell -ExecutionPolicy Bypass -File tools\export-android.ps1
. "$PSScriptRoot\env.ps1"
Set-Location $FF_ROOT

Write-Host "== Smoke test" -ForegroundColor Cyan
& $GODOT_CLI --headless --path . -s res://tools/smoke_test.gd
if ($LASTEXITCODE -ne 0) { Write-Host "La prueba automática falló; no se exporta." -ForegroundColor Red; exit 1 }

Write-Host "== Exportando APK de depuración" -ForegroundColor Cyan
New-Item -ItemType Directory -Force (Split-Path $FF_APK) | Out-Null
& $GODOT_CLI --headless --path . --export-debug Android $FF_APK
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $FF_APK)) { Write-Host "La exportación falló." -ForegroundColor Red; exit 1 }

Write-Host "== Verificando firma" -ForegroundColor Cyan
$env:JAVA_HOME = $FF_JDK
& "$FF_SDK\build-tools\35.0.1\apksigner.bat" verify $FF_APK
if ($LASTEXITCODE -ne 0) { Write-Host "La firma no es válida." -ForegroundColor Red; exit 1 }

$f = Get-Item $FF_APK
Write-Host ("APK: {0} ({1:N1} MB)" -f $f.FullName, ($f.Length / 1MB)) -ForegroundColor Green
Write-Host ("SHA-256: {0}" -f (Get-FileHash $FF_APK -Algorithm SHA256).Hash)
Write-Host "Recuerda registrar la compilación y sus pruebas en project-status.json."
