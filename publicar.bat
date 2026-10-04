@echo off
chcp 65001 > nul
cls
echo ================================================================
echo        BARBEROSBAO - PUBLICACAO AUTOMATICA EM PRODUCAO
echo ================================================================
echo.

echo [1/4] Verificando e compilando o Backend...
cd backend
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Falha na compilação do Backend. Operação abortada.
    cd ..
    pause
    exit /b %ERRORLEVEL%
)
cd ..
echo [OK] Backend compilado com sucesso!
echo.

echo [2/4] Validando codigo Flutter...
call flutter analyze lib
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] O analisador do Flutter encontrou problemas. Operação abortada.
    pause
    exit /b %ERRORLEVEL%
)
echo [OK] Flutter 100%% limpo, sem erros!
echo.

echo [3/4] Enviando alterações para o GitHub...
git add .
set /p COMMIT_MSG="Digite a descrição da alteração (ou pressione Enter para usar padrão): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=feat: atualizacoes e melhorias do sistema
git commit -m "%COMMIT_MSG%"
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Falha ao enviar para o GitHub. Verifique sua conexão.
    pause
    exit /b %ERRORLEVEL%
)
echo [OK] Codigo sincronizado no GitHub!
echo.

echo [4/4] Deploy em andamento na Nuvem!
echo - Render detectou o push e esta atualizando o Backend automaticamente.
echo - GitHub Actions esta gerando a nova versao do Web App.
echo.
echo ================================================================
echo   SUCESSO! O sistema foi atualizado e ja esta indo para o ar.
echo ================================================================
echo.
pause
