@echo off
rem Inicia el panel de progreso local de Final Fire y lo abre en el navegador.
rem Uso: panel.cmd            (solo este equipo)
rem      panel.cmd --lan      (también desde el móvil en tu Wi-Fi)
cd /d "%~dp0"
node dashboard\server.mjs --open %*
