@echo off
REM Script para verificar o status das portas

echo ========================================
echo Verificacao de Portas - gRPC Backend
echo ========================================
echo.

echo Verificando porta 9090 (Backend gRPC)...
netstat -ano | findstr :9090
if %ERRORLEVEL% EQU 0 (
    echo [OK] Porta 9090 esta em uso
) else (
    echo [AVISO] Porta 9090 esta livre - O servidor gRPC nao esta rodando?
)

echo.
echo Verificando porta 8080 (Envoy Proxy)...
netstat -ano | findstr :8080
if %ERRORLEVEL% EQU 0 (
    echo [OK] Porta 8080 esta em uso
) else (
    echo [AVISO] Porta 8080 esta livre - O Envoy nao esta rodando?
)

echo.
echo ========================================
echo Configuracao Esperada:
echo ========================================
echo Porta 9090: Backend gRPC (Spring Boot)
echo Porta 8080: Envoy Proxy
echo.
echo Cliente Java deve conectar na porta 9090
echo Frontend Angular deve conectar na porta 8080
echo ========================================
echo.
pause

