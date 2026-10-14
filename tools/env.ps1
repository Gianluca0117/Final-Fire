# Rutas del entorno de Final Fire. Se cargan con:  . .\tools\env.ps1
# Solo afectan a la sesión de PowerShell actual: no cambian el PATH ni las variables del sistema.
$FF_ROOT     = Split-Path -Parent $PSScriptRoot
$GODOT       = "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64.exe"
$GODOT_CLI   = "$env:LOCALAPPDATA\Programs\Godot\4.7.2-stable\Godot_v4.7.2-stable_win64_console.exe"
$FF_JDK      = "$env:LOCALAPPDATA\Programs\Java\jdk-17.0.20.1+1"
$FF_SDK      = "$env:LOCALAPPDATA\Android\Sdk"
$ADB         = "$FF_SDK\platform-tools\adb.exe"
$FF_APK      = Join-Path $FF_ROOT "builds\android\FinalFire-debug.apk"
$FF_PACKAGE  = "com.finalfire.game"
