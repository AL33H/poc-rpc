# ? Quick Start Guide

Guia rápido para executar a PoC em 5 minutos!

## ? Comandos Rápidos

### Terminal 1 - Backend
```bash
cd backend
mvn clean compile
mvn spring-boot:run
```
? Backend rodando em `localhost:9090`

### Terminal 2 - Envoy Proxy
```bash
docker-compose up
```
? Envoy rodando em `localhost:8080`

### Terminal 3 - Frontend
```bash
cd frontend
npm install
npm run proto:generate
npm start
```
? Frontend rodando em `http://localhost:4200`

## ? Testar

1. Abra: `http://localhost:4200`
2. Clique em **"Iniciar Processamento"**
3. Observe o streaming em tempo real!

## ? Verificar Serviços

```bash
# Backend gRPC
netstat -an | grep 9090

# Envoy Proxy
curl http://localhost:9901/stats

# Frontend
curl http://localhost:4200
```

## ? Problemas Comuns

### "protoc: command not found"
```bash
# Windows
choco install protoc

# Linux
sudo apt install protobuf-compiler

# macOS
brew install protobuf
```

### "Cannot find module 'generated/...'"
```bash
cd frontend
npm run proto:generate
```

### "Port 9090 already in use"
```bash
# Windows
netstat -ano | findstr :9090
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:9090 | xargs kill -9
```

## ? Ordem de Inicialização

1. **Backend** (porta 9090) - Servidor gRPC
2. **Envoy** (porta 8080) - Proxy gRPC-Web
3. **Frontend** (porta 4200) - Cliente Angular

?? **Importante:** Inicie nesta ordem para evitar erros de conexão!

## ? Pronto!

Agora você tem um sistema completo de gRPC Server Streaming funcionando!

