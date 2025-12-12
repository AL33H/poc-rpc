# ? gRPC Server Streaming PoC

Prova de Conceito completa demonstrando **Server Streaming** com gRPC entre Angular 19 e Spring Boot 3.

## ? Stack Tecnológica

- **Frontend:** Angular 19 (Standalone Components + Signals)
- **Backend:** Java 17 + Spring Boot 3.2.0
- **Protocolo:** gRPC + gRPC-Web
- **Proxy:** Envoy Proxy (para tradução gRPC-Web ? gRPC)

## ? Funcionalidade

O sistema implementa um padrão de **Server Streaming** onde:

1. Frontend envia uma requisição com um ID
2. Backend **imediatamente** retorna: `"Processando..."`
3. Backend simula processamento pesado (15-20 segundos)
4. Backend envia segunda mensagem: `"Processado com Sucesso"` + payload
5. Stream é encerrado

## ? Estrutura do Projeto

```
rpc/
??? proto/                      # Definições Protocol Buffers
?   ??? processing.proto
??? backend/                    # Spring Boot Application
?   ??? pom.xml
?   ??? src/
??? frontend/                   # Angular 19 Application
?   ??? package.json
?   ??? src/
??? envoy.yaml                  # Configuração do Envoy Proxy
??? docker-compose.yml          # Docker Compose para Envoy
??? README.md
```

## ? Pré-requisitos

- **Java 17+**
- **Maven 3.8+**
- **Node.js 18+** e **npm**
- **Docker** e **Docker Compose**
- **Protocol Buffers Compiler** (`protoc`)
- **protoc-gen-grpc-web** plugin

### Instalação do protoc e protoc-gen-grpc-web

#### Windows (via Chocolatey):
```bash
choco install protoc
# Baixe protoc-gen-grpc-web de: https://github.com/grpc/grpc-web/releases
# Adicione ao PATH
```

#### Linux/Mac:
```bash
# protoc
sudo apt install -y protobuf-compiler  # Ubuntu/Debian
brew install protobuf                   # macOS

# protoc-gen-grpc-web
npm install -g protoc-gen-grpc-web
```

## ? Instruções de Execução

### 1?? Gerar Stubs do Proto (Backend)

```bash
cd backend
mvn clean compile
```

Isso irá:
- Gerar classes Java a partir do `.proto`
- Compilar o projeto Spring Boot

### 2?? Iniciar o Backend (Spring Boot)

```bash
cd backend
mvn spring-boot:run
```

O servidor gRPC estará rodando na porta **9090**.

### 3?? Iniciar o Envoy Proxy

Em outro terminal:

```bash
docker-compose up
```

O Envoy Proxy estará rodando na porta **8080** (traduz gRPC-Web para gRPC).

### 4?? Gerar Stubs do Proto (Frontend)

```bash
cd frontend

# Instalar dependências
npm install

# Gerar código TypeScript a partir do .proto
npm run proto:generate
```

Isso criará os arquivos em `frontend/src/generated/`.

### 5?? Iniciar o Frontend (Angular)

```bash
cd frontend
npm start
```

O Angular estará rodando em **http://localhost:4200**.

## ? Como Usar

1. Abra o navegador em `http://localhost:4200`
2. Clique no botão **"Iniciar Processamento"**
3. Observe:
   - Status muda imediatamente para **"Processando..."**
   - Após 15-20 segundos, status muda para **"Processado com Sucesso"**
   - Logs mostram todas as mensagens recebidas do stream
   - Payload JSON é exibido com detalhes do processamento

## ? Fluxo de Comunicação

```
???????????         ???????????         ???????????         ???????????
? Angular ? gRPC-Web?  Envoy  ?  gRPC   ? Spring  ?
?   19    ???????????  Proxy  ???????????  Boot   ?
?         ?         ?         ?         ?    3    ?
???????????         ???????????         ???????????
     ?                   ?                   ?
     ? 1. StartProcessing Request            ?
     ?????????????????????????????????????????
     ?                   ?                   ?
     ? 2. Stream Response: "Processando..."  ?
     ?????????????????????????????????????????
     ?                   ?                   ?
     ?                   ?    (15-20s delay) ?
     ?                   ?                   ?
     ? 3. Stream Response: "Sucesso" + Data  ?
     ?????????????????????????????????????????
     ?                   ?                   ?
     ? 4. Stream Complete                    ?
     ?????????????????????????????????????????
```

## ? Pontos-Chave da Implementação

### Backend (Spring Boot)

- **`@GrpcService`**: Anotação do `grpc-spring-boot-starter`
- **`StreamObserver<T>`**: Interface para enviar múltiplas respostas
- **`responseObserver.onNext()`**: Envia cada mensagem do stream
- **`responseObserver.onCompleted()`**: Finaliza o stream

### Frontend (Angular)

- **Signals**: Gerenciamento de estado reativo (`signal()`, `.set()`, `.update()`)
- **Standalone Components**: Sem módulos, apenas imports diretos
- **Observable**: Encapsula o stream gRPC-Web
- **`stream.on('data')`**: Recebe cada mensagem do servidor

## ?? Troubleshooting

### Erro: "Cannot find module 'generated/...'"
```bash
cd frontend
npm run proto:generate
```

### Erro: "Connection refused" no frontend
Verifique se o Envoy Proxy está rodando:
```bash
docker-compose ps
```

### Erro: "gRPC server not available"
Verifique se o backend Spring Boot está rodando na porta 9090:
```bash
netstat -an | grep 9090
```

### Logs do Envoy
```bash
docker-compose logs -f envoy
```

## ? Referências

- [gRPC Official](https://grpc.io/)
- [gRPC-Web](https://github.com/grpc/grpc-web)
- [Angular Signals](https://angular.io/guide/signals)
- [Spring Boot gRPC Starter](https://github.com/yidongnan/grpc-spring-boot-starter)

## ? Licença

MIT License - Sinta-se livre para usar este código como base para seus projetos!

