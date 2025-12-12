@echo off
echo ========================================
echo   gRPC Server Streaming PoC - Setup
echo ========================================
echo.

echo [1/4] Verificando pre-requisitos...
echo.

where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Java nao encontrado! Instale Java 17+
    exit /b 1
)

where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Maven nao encontrado! Instale Maven 3.8+
    exit /b 1
)

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Node.js nao encontrado! Instale Node.js 18+
    exit /b 1
)

where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Docker nao encontrado! Instale Docker Desktop
    exit /b 1
)

where protoc >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] protoc nao encontrado! Instale: choco install protoc
    echo Continuando...
)

echo [OK] Pre-requisitos verificados!
echo.

echo [2/4] Compilando Backend (Spring Boot)...
cd backend
call mvn clean compile
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao compilar backend!
    cd ..
    exit /b 1
)
cd ..
echo [OK] Backend compilado!
echo.

echo [3/4] Instalando dependencias do Frontend...
cd frontend
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao instalar dependencias!
    cd ..
    exit /b 1
)
echo [OK] Dependencias instaladas!
echo.

echo [4/4] Gerando stubs gRPC para o Frontend...
call npm run proto:generate
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Falha ao gerar stubs. Execute manualmente: npm run proto:generate
)
cd ..
echo.

echo ========================================
echo   Setup concluido com sucesso!
echo ========================================
echo.
echo Proximos passos:
echo.
echo Terminal 1: cd backend ^&^& mvn spring-boot:run
echo Terminal 2: docker-compose up
echo Terminal 3: cd frontend ^&^& npm start
echo.
echo Depois acesse: http://localhost:4200
echo.
pause

