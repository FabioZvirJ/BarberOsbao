@echo off
title BarberOsbao - Inicializador do Sistema
echo ===================================================
echo       INICIANDO BARBER OSBAO (BACKEND + FRONTEND)
echo ===================================================
echo.

echo [1/2] Iniciando Backend API (Node.js + SQLite em http://localhost:3000)...
start "BarberOsbao Backend API" cmd /k "cd /d %~dp0backend && npm start"

echo Aguardando inicializacao da API...
timeout /t 3 /nobreak > nul

echo [2/2] Iniciando Frontend Flutter (Chrome)...
start "BarberOsbao Flutter App" cmd /k "cd /d %~dp0 && flutter run -d chrome"

echo.
echo ===================================================
echo  Tudo pronto! As duas janelas foram inicializadas.
echo  Mantenha as janelas abertas durante o uso.
echo ===================================================

