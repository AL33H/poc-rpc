#!/bin/bash

echo "========================================"
echo "  gRPC Server Streaming PoC - Setup"
echo "========================================"
echo ""

echo "[1/4] Verificando pré-requisitos..."
echo ""

# Verifica Java
if ! command -v java &> /dev/null; then
    echo "[ERRO] Java não encontrado! Instale Java 17+"
    exit 1
fi

# Verifica Maven
if ! command -v mvn &> /dev/null; then
    echo "[ERRO] Maven não encontrado! Instale Maven 3.8+"
    exit 1
fi

# Verifica Node.js
if ! command -v node &> /dev/null; then
    echo "[ERRO] Node.js não encontrado! Instale Node.js 18+"
    exit 1
fi

# Verifica Docker
if ! command -v docker &> /dev/null; then
    echo "[ERRO] Docker não encontrado! Instale Docker"
    exit 1
fi

# Verifica protoc (opcional)
if ! command -v protoc &> /dev/null; then
    echo "[AVISO] protoc não encontrado! Instale: brew install protobuf (macOS) ou apt install protobuf-compiler (Linux)"
    echo "Continuando..."
fi

echo "[OK] Pré-requisitos verificados!"
echo ""

echo "[2/4] Compilando Backend (Spring Boot)..."
cd backend
mvn clean compile
if [ $? -ne 0 ]; then
    echo "[ERRO] Falha ao compilar backend!"
    cd ..
    exit 1
fi
cd ..
echo "[OK] Backend compilado!"
echo ""

echo "[3/4] Instalando dependências do Frontend..."
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo "[ERRO] Falha ao instalar dependências!"
    cd ..
    exit 1
fi
echo "[OK] Dependências instaladas!"
echo ""

echo "[4/4] Gerando stubs gRPC para o Frontend..."
npm run proto:generate
if [ $? -ne 0 ]; then
    echo "[AVISO] Falha ao gerar stubs. Execute manualmente: npm run proto:generate"
fi
cd ..
echo ""

echo "========================================"
echo "  Setup concluído com sucesso!"
echo "========================================"
echo ""
echo "Próximos passos:"
echo ""
echo "Terminal 1: cd backend && mvn spring-boot:run"
echo "Terminal 2: docker-compose up"
echo "Terminal 3: cd frontend && npm start"
echo ""
echo "Depois acesse: http://localhost:4200"
echo ""

