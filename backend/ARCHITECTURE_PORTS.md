# 🏗️ Arquitetura e Configuração de Portas

## 📊 Diagrama da Arquitetura

```
┌─────────────────────┐
│  Cliente Java       │
│  (gRPC nativo)      │
└──────────┬──────────┘
           │
           │ gRPC (HTTP/2)
           │ Porta 9090
           ▼
┌─────────────────────┐
│  Backend gRPC       │
│  (Spring Boot)      │
│  Porta 9090         │
└─────────────────────┘
           ▲
           │ gRPC (HTTP/2)
           │ Porta 9090
           │
┌──────────┴──────────┐
│  Envoy Proxy        │
│  Porta 8080         │
└──────────▲──────────┘
           │
           │ gRPC-Web (HTTP/1.1)
           │ Porta 8080
           │
┌──────────┴──────────┐
│  Frontend Angular   │
│  (gRPC-Web)         │
└─────────────────────┘
```

## 🔌 Configuração de Portas

### Porta 9090 - Servidor gRPC (Backend)
- **Protocolo**: gRPC (HTTP/2)
- **Uso**: Acesso direto para clientes gRPC nativos (Java, Go, Python, etc.)
- **Configuração**: `application.properties` → `grpc.server.port=9090`
- **Clientes**: 
  - ✅ Cliente Java (ProcessingClient.java)
  - ✅ Envoy Proxy (roteamento interno)

### Porta 8080 - Envoy Proxy
- **Protocolo**: gRPC-Web (HTTP/1.1) → gRPC (HTTP/2)
- **Uso**: Proxy para frontend web (navegadores não suportam gRPC nativo)
- **Configuração**: `envoy.yaml` → listener na porta 8080, roteia para backend:9090
- **Clientes**:
  - ✅ Frontend Angular (via gRPC-Web)
  - ✅ Navegadores web

## ❌ Erro Anterior: "Unexpected HTTP/1.x request"

### Causa do Erro
O erro ocorria porque:

1. **Backend gRPC** estava configurado na porta **8080**
2. **Envoy Proxy** também tentava usar a porta **8080**
3. **Conflito de portas**: Ambos competiam pela mesma porta
4. **Roteamento incorreto**: Envoy tentava rotear para porta 9090, mas o backend estava em 8080

### Mensagem de Erro
```
io.grpc.netty.shaded.io.netty.handler.codec.http2.Http2Exception: 
Unexpected HTTP/1.x request: POST /processing.ProcessingService/StartProcessing
```

Isso acontecia porque o servidor gRPC (HTTP/2) recebia requisições HTTP/1.x do Envoy ou do frontend.

## ✅ Solução Implementada

### Mudanças Realizadas

1. **application.properties**
   ```properties
   # Antes
   grpc.server.port=8080
   
   # Depois
   grpc.server.port=9090
   ```

2. **ProcessingClient.java**
   ```java
   // Antes
   int port = 8080;
   
   // Depois
   int port = 9090; // Porta do servidor gRPC (acesso direto, sem Envoy)
   ```

3. **envoy.yaml** (já estava correto)
   ```yaml
   # Envoy escuta na porta 8080
   socket_address: { address: 0.0.0.0, port_value: 8080 }
   
   # Envoy roteia para o backend na porta 9090
   socket_address:
     address: host.docker.internal
     port_value: 9090
   ```

## 🧪 Como Testar

### Teste 1: Cliente Java (Acesso Direto)
```bash
# Inicia o servidor na porta 9090
mvn spring-boot:run

# Em outro terminal, executa o cliente
./run-client.sh  # ou test-client.bat no Windows
```

**Resultado esperado**: Cliente conecta diretamente ao servidor gRPC na porta 9090

### Teste 2: Frontend Angular (via Envoy)
```bash
# Terminal 1: Inicia o servidor na porta 9090
cd backend
mvn spring-boot:run

# Terminal 2: Inicia o Envoy na porta 8080
cd ..
docker-compose up envoy

# Terminal 3: Inicia o frontend
cd frontend
npm start
```

**Resultado esperado**: Frontend acessa via Envoy (porta 8080), que roteia para o backend (porta 9090)

## 🔍 Verificação de Portas

### Windows
```bash
# Verifica se a porta 9090 está em uso (backend)
netstat -ano | findstr :9090

# Verifica se a porta 8080 está em uso (Envoy)
netstat -ano | findstr :8080
```

### Linux/Mac
```bash
# Verifica se a porta 9090 está em uso (backend)
lsof -i :9090

# Verifica se a porta 8080 está em uso (Envoy)
lsof -i :8080
```

## 📝 Resumo

| Componente | Porta | Protocolo | Uso |
|------------|-------|-----------|-----|
| Backend gRPC | 9090 | gRPC (HTTP/2) | Servidor principal |
| Envoy Proxy | 8080 | gRPC-Web → gRPC | Proxy para frontend |
| Cliente Java | - | gRPC (HTTP/2) | Conecta na porta 9090 |
| Frontend Angular | - | gRPC-Web (HTTP/1.1) | Conecta na porta 8080 |

## 🎯 Boas Práticas

1. ✅ **Separar portas**: Backend (9090) e Proxy (8080)
2. ✅ **Cliente nativo**: Conecta diretamente ao backend (9090)
3. ✅ **Cliente web**: Conecta via Envoy (8080)
4. ✅ **Documentar**: Sempre documente as portas usadas
5. ✅ **Testar**: Verifique se as portas estão corretas antes de executar

