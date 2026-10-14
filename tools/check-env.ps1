# Comprueba el entorno de Final Fire. No instala ni modifica nada.
#   powershell -ExecutionPolicy Bypass -File tools\check-env.ps1
. "$PSScriptRoot\env.ps1"
$fail = 0
function Check($name, [scriptblock]$test) {
    try { $r = & $test; if ($r) { Write-Host "[OK]    $name -> $r" -ForegroundColor Green } else { throw "sin resultado" } }
    catch { $script:fail++; Write-Host "[FALLO] $name -> $_" -ForegroundColor Red }
}

Check "Godot 4.7.2"            { (& $GODOT_CLI --version | Select-Object -Last 1) }
Check "Plantillas Android"     { $d = "$env:APPDATA\Godot\export_templates\4.7.2.stable"; if ((Test-Path "$d\android_debug.apk") -and (Test-Path "$d\android_release.apk")) { $d } }
Check "JDK 17"                 { (& "$FF_JDK\bin\java.exe" -version 2>&1 | Select-Object -First 1).ToString() }
Check "Android SDK"            { if (Test-Path "$FF_SDK\platforms\android-35") { $FF_SDK } }
Check "build-tools 35.0.1"     { if (Test-Path "$FF_SDK\build-tools\35.0.1\apksigner.bat") { "apksigner presente" } }
Check "cmdline-tools"          { if (Test-Path "$FF_SDK\cmdline-tools\latest\bin\sdkmanager.bat") { "sdkmanager presente" } }
Check "adb"                    { (& $ADB version | Select-Object -First 1) }
Check "Git"                    { (git --version) }
Check "Node (panel)"           { (node --version) }
Check "Keystore de depuración" { $k = "$env:APPDATA\Godot\keystores\debug.keystore"; if (Test-Path $k) { $k } }
Check "Ajustes del editor"     {
    $s = Get-Content "$env:APPDATA\Godot\editor_settings-4.7.tres" -Raw
    if ($s -match 'java_sdk_path = ".*jdk-17' -and $s -match 'android_sdk_path = ".*Android\\\\Sdk') { "rutas de Java y Android configuradas" }
}

Write-Host ""
Write-Host "Dispositivos Android conectados:"
& $ADB devices -l
if ($fail) { Write-Host "$fail comprobación(es) fallida(s)." -ForegroundColor Red; exit 1 }
Write-Host "Entorno correcto." -ForegroundColor Green
