# ? Troubleshooting Guide

## ? Problemas Comuns e Soluções

### 1. Backend não inicia

#### Erro: "Port 9090 already in use"

**Causa:** Outra aplicação está usando a porta 9090.

**Solução Windows:**
```bash
netstat -ano | findstr :9090
taskkill /PID <PID> /F
```

**Solução Linux/Mac:**
```bash
lsof -ti:9090 | xargs kill -9
```

#### Erro: "Cannot find symbol ProcessingServiceGrpc"

**Causa:** Stubs gRPC não foram gerados.

**Solução:**
```bash
cd backend
mvn clean compile
```

#### Erro: "Java version mismatch"

**Causa:** Versão do Java incorreta.

**Solução:**
```bash
java -version  # Deve ser 17+
```

Se necessário, configure `JAVA_HOME`:
```bash
# Windows
set JAVA_HOME=C:\Program Files\Java\jdk-17

# Linux/Mac
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
```

### 2. Envoy Proxy não inicia

#### Erro: "Port 8080 already in use"

**Solução:**
```bash
# Parar containers
docker-compose down

# Verificar portas
netstat -an | grep 8080

# Matar processo
# Windows: taskkill /PID <PID> /F
# Linux/Mac: kill -9 <PID>

# Reiniciar
docker-compose up
```

#### Erro: "Cannot connect to Docker daemon"

**Causa:** Docker Desktop não está rodando.

**Solução:**
- Windows/Mac: Inicie o Docker Desktop
- Linux: `sudo systemctl start docker`

#### Erro: "host.docker.internal not found"

**Causa:** Docker em Linux não suporta `host.docker.internal` por padrão.

**Solução:** Edite `envoy.yaml`:
```yaml
# Troque
address: host.docker.internal

# Por
address: 172.17.0.1  # IP do host no Docker Linux
```

### 3. Frontend não compila

#### Erro: "Cannot find module 'generated/...'"

**Causa:** Stubs gRPC-Web não foram gerados.

**Solução:**
```bash
cd frontend
npm run proto:generate
```

#### Erro: "protoc: command not found"

**Causa:** Protocol Buffers Compiler não instalado.

**Solução:**
```bash
# Windows (Chocolatey)
choco install protoc

# macOS
brew install protobuf

# Linux (Ubuntu/Debian)
sudo apt install protobuf-compiler

# Verificar instalação
protoc --version
```

#### Erro: "protoc-gen-grpc-web: program not found"

**Causa:** Plugin gRPC-Web não instalado.

**Solução:**
```bash
# Opção 1: Via npm
npm install -g protoc-gen-grpc-web

# Opção 2: Download manual
# https://github.com/grpc/grpc-web/releases
# Baixe o binário e adicione ao PATH
```

#### Erro: "Module not found: Error: Can't resolve 'google-protobuf'"

**Causa:** Dependências não instaladas.

**Solução:**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### 4. Erros de Comunicação

#### Erro: "Failed to fetch" ou "net::ERR_CONNECTION_REFUSED"

**Causa:** Envoy Proxy não está rodando ou backend está offline.

**Checklist:**
1. Backend rodando? `netstat -an | grep 9090`
2. Envoy rodando? `docker ps`
3. Frontend apontando para proxy correto? Verifique `proxy.conf.json`

**Solução:**
```bash
# Terminal 1
cd backend && mvn spring-boot:run

# Terminal 2
docker-compose up

# Terminal 3
cd frontend && npm start
```

#### Erro: "CORS policy blocked"

**Causa:** Configuração CORS incorreta no Envoy.

**Solução:** Verifique `envoy.yaml`:
```yaml
cors:
  allow_origin_string_match:
  - prefix: "*"
```

#### Erro: "Stream timeout"

**Causa:** Processamento muito longo ou timeout configurado.

**Solução:** Aumente o timeout no `envoy.yaml`:
```yaml
route:
  timeout: 60s  # Aumentar de 0s para 60s
```

### 5. Problemas de Streaming

#### Problema: Recebe apenas 1 mensagem

**Causa:** Stream sendo fechado prematuramente.

**Debug Backend:**
```java
// Adicione logs
logger.info("Enviando primeira mensagem");
responseObserver.onNext(initialResponse);

logger.info("Aguardando processamento");
Thread.sleep(15000);

logger.info("Enviando segunda mensagem");
responseObserver.onNext(finalResponse);

logger.info("Finalizando stream");
responseObserver.onCompleted();
```

#### Problema: Mensagens chegam fora de ordem

**Causa:** Improvável com gRPC (garante ordem), mas pode ser problema de UI.

**Solução:** Verifique se os Signals estão sendo atualizados corretamente:
```typescript
next: (response) => {
  console.log('Ordem:', response.timestamp);
  this.status.set(response.status);
}
```

### 6. Problemas de Build

#### Erro: "Maven build failed"

**Solução:**
```bash
cd backend
mvn clean install -U  # Força atualização de dependências
```

#### Erro: "npm install failed"

**Solução:**
```bash
cd frontend
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### 7. Problemas de Performance

#### Problema: Primeira resposta demora muito

**Causa:** Cold start do backend ou rede lenta.

**Debug:**
```bash
# Verifique latência
ping localhost

# Verifique logs do backend
# Deve mostrar "Enviada resposta inicial" imediatamente
```

#### Problema: Alto uso de memória

**Causa:** Vazamento de memória ou muitas conexões abertas.

**Solução:**
```typescript
// Certifique-se de cancelar streams
return () => {
  stream.cancel();
};
```

## ? Ferramentas de Debug

### 1. Verificar Serviços

```bash
# Backend
curl http://localhost:9090

# Envoy Admin
curl http://localhost:9901/stats

# Frontend
curl http://localhost:4200
```

### 2. Logs Detalhados

**Backend:**
```properties
# application.properties
logging.level.io.grpc=DEBUG
logging.level.com.example.grpc=TRACE
```

**Envoy:**
```bash
docker-compose logs -f envoy
```

**Frontend:**
```typescript
// app.component.ts
console.log('Request:', request);
console.log('Response:', response);
```

### 3. Network Analysis

**Chrome DevTools:**
1. F12 ? Network
2. Filtro: XHR
3. Clique na requisição gRPC
4. Verifique Headers, Payload, Response

### 4. gRPC Tools

**grpcurl (teste direto no backend):**
```bash
grpcurl -plaintext \
  -d '{"request_id": "debug-test"}' \
  localhost:9090 \
  processing.ProcessingService/StartProcessing
```

## ? Checklist de Diagnóstico

Quando algo não funcionar, verifique na ordem:

- [ ] Java 17+ instalado e configurado
- [ ] Maven 3.8+ instalado
- [ ] Node.js 18+ instalado
- [ ] Docker rodando
- [ ] protoc instalado
- [ ] protoc-gen-grpc-web instalado
- [ ] Backend compilado (`mvn clean compile`)
- [ ] Backend rodando (porta 9090)
- [ ] Envoy rodando (porta 8080)
- [ ] Frontend compilado (`npm install`)
- [ ] Stubs gerados (`npm run proto:generate`)
- [ ] Frontend rodando (porta 4200)
- [ ] Sem erros no console do navegador
- [ ] Sem erros nos logs do backend
- [ ] Sem erros nos logs do Envoy

## ? Ainda com Problemas?

### Resetar Tudo

```bash
# Parar tudo
docker-compose down
# Matar processos Java
# Matar processos Node

# Limpar
cd backend
mvn clean
cd ../frontend
rm -rf node_modules dist src/generated

# Reinstalar
cd ..
./setup.sh  # ou setup.bat no Windows
```

### Coletar Informações para Debug

```bash
# Versões
java -version
mvn -version
node -version
npm -version
docker -version
protoc --version

# Portas em uso
netstat -an | grep -E "9090|8080|4200"

# Logs
cd backend && mvn spring-boot:run > backend.log 2>&1
docker-compose logs > envoy.log
cd frontend && npm start > frontend.log 2>&1
```

## ? Suporte

Se nenhuma solução funcionou:

1. Verifique os logs completos
2. Documente o erro exato
3. Liste as versões de todas as ferramentas
4. Descreva o ambiente (SO, arquitetura)
5. Abra uma issue no repositório

## ? Dicas Gerais

- **Sempre inicie na ordem:** Backend ? Envoy ? Frontend
- **Verifique logs em tempo real** durante testes
- **Use o modo debug** do navegador (F12)
- **Teste cada camada isoladamente** (backend com grpcurl, depois frontend)
- **Mantenha as versões atualizadas** mas compatíveis

