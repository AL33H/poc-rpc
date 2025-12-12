#!/bin/bash
# Script para executar o cliente gRPC de teste

echo "========================================"
echo "Cliente gRPC - ProcessingService"
echo "========================================"
echo ""

# Verifica se o Maven está instalado
if ! command -v mvn &> /dev/null; then
    echo "ERRO: Maven não encontrado. Instale o Maven e adicione ao PATH."
    exit 1
fi

# Compila o projeto (se necessário)
echo "Compilando o projeto..."
mvn clean compile
if [ $? -ne 0 ]; then
    echo "ERRO: Falha na compilação."
    exit 1
fi

echo ""
echo "Executando o cliente..."
echo ""

# Executa o cliente
mvn exec:java -Dexec.mainClass="com.example.grpc.client.ProcessingClient" -Dexec.args="$*"

echo ""
echo "========================================"
echo "Cliente finalizado"
echo "========================================"

