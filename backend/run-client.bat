@echo off
REM Script para executar o cliente gRPC de teste

echo ========================================
echo Cliente gRPC - ProcessingService
echo ========================================
echo.

REM Verifica se o Maven está instalado
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: Maven nao encontrado. Instale o Maven e adicione ao PATH.
    exit /b 1
)

REM Compila o projeto (se necessário)
echo Compilando o projeto...
call mvn clean compile
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: Falha na compilacao.
    exit /b 1
)

echo.
echo Executando o cliente...
echo.

REM Executa o cliente
call mvn exec:java -Dexec.mainClass="com.example.grpc.client.ProcessingClient" -Dexec.args="%*"

echo.
echo ========================================
echo Cliente finalizado
echo ========================================

