@echo off
REM Script de teste rápido do cliente gRPC

echo ========================================
echo TESTE RAPIDO - Cliente gRPC
echo ========================================
echo.
echo Este script ira:
echo 1. Verificar se o servidor esta rodando
echo 2. Compilar o projeto
echo 3. Executar o cliente de teste
echo.
echo IMPORTANTE: O servidor deve estar rodando na porta 9090!
echo.

echo Verificando se o servidor esta rodando na porta 9090...
netstat -ano | findstr :9090 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Servidor gRPC nao encontrado na porta 9090!
    echo.
    echo Por favor, inicie o servidor primeiro:
    echo   mvn spring-boot:run
    echo.
    pause
    exit /b 1
)
echo [OK] Servidor encontrado na porta 9090
echo.
pause

echo.
echo Compilando o projeto...
call mvn clean compile

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERRO: Falha na compilacao!
    pause
    exit /b 1
)

echo.
echo Executando o cliente...
echo.

call mvn exec:java -Dexec.mainClass="com.example.grpc.client.ProcessingClient"

echo.
echo ========================================
echo Teste finalizado!
echo ========================================
pause

