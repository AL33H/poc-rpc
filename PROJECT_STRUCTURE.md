# ? Estrutura do Projeto

## ? Árvore de Diretórios

```
rpc/
?
??? ? README.md                          # Documentação principal
??? ? QUICKSTART.md                      # Guia rápido de início
??? ? ARCHITECTURE.md                    # Arquitetura detalhada
??? ? TESTING.md                         # Guia de testes
??? ? TROUBLESHOOTING.md                 # Solução de problemas
??? ? PROJECT_STRUCTURE.md               # Este arquivo
?
??? ? docker-compose.yml                 # Orquestração do Envoy
??? ? envoy.yaml                         # Configuração do Envoy Proxy
??? ? setup.bat                          # Script de setup (Windows)
??? ? setup.sh                           # Script de setup (Linux/Mac)
??? ? .gitignore                         # Arquivos ignorados pelo Git
?
??? ? proto/                             # Definições Protocol Buffers
?   ??? ? processing.proto               # Contrato gRPC (Server Streaming)
?
??? ? backend/                           # Spring Boot Application
?   ??? ? pom.xml                        # Dependências Maven
?   ??? ? .gitignore                     # Ignorar target/, .idea/, etc
?   ?
?   ??? ? src/
?       ??? ? main/
?       ?   ??? ? java/
?       ?   ?   ??? ? com/example/grpc/
?       ?   ?       ??? ? GrpcBackendApplication.java    # Main class
?       ?   ?       ?
?       ?   ?       ??? ? service/
?       ?   ?       ?   ??? ? ProcessingServiceImpl.java # Implementação gRPC
?       ?   ?       ?
?       ?   ?       ??? ? processing/                    # Gerado pelo protoc
?       ?   ?           ??? ? ProcessingProto.java
?       ?   ?           ??? ? ProcessingRequest.java
?       ?   ?           ??? ? ProcessingResponse.java
?       ?   ?           ??? ? ProcessingServiceGrpc.java
?       ?   ?
?       ?   ??? ? resources/
?       ?       ??? ? application.properties             # Configurações
?       ?
?       ??? ? test/                                      # Testes (opcional)
?
??? ? frontend/                          # Angular 19 Application
    ??? ? package.json                   # Dependências npm
    ??? ? tsconfig.json                  # Configuração TypeScript
    ??? ? tsconfig.app.json              # Config TS para app
    ??? ? angular.json                   # Configuração Angular CLI
    ??? ? proxy.conf.json                # Proxy para gRPC-Web
    ??? ? .gitignore                     # Ignorar node_modules/, dist/, etc
    ?
    ??? ? src/
        ??? ? index.html                 # HTML principal
        ??? ? main.ts                    # Bootstrap da aplicação
        ??? ? styles.css                 # Estilos globais
        ?
        ??? ? app/
        ?   ??? ? app.component.ts       # Componente principal (Signals)
        ?   ??? ? app.component.html     # Template
        ?   ??? ? app.component.css      # Estilos
        ?   ?
        ?   ??? ? services/
        ?       ??? ? processing.service.ts  # Serviço gRPC-Web
        ?
        ??? ? generated/                 # Gerado pelo protoc-gen-grpc-web
        ?   ??? ? processing_pb.js
        ?   ??? ? processing_pb.d.ts
        ?   ??? ? ProcessingServiceClientPb.js
        ?   ??? ? ProcessingServiceClientPb.d.ts
        ?
        ??? ? assets/                    # Recursos estáticos (imagens, etc)
```

## ? Descrição dos Arquivos Principais

### ? Proto (Contrato)

| Arquivo | Descrição |
|---------|-----------|
| `proto/processing.proto` | Define o contrato gRPC com Server Streaming |

### ? Backend (Spring Boot)

| Arquivo | Descrição | Linhas |
|---------|-----------|--------|
| `backend/pom.xml` | Dependências Maven (gRPC, Spring Boot, Protobuf) | ~110 |
| `backend/src/main/resources/application.properties` | Configurações (porta 9090, logs) | ~10 |
| `backend/src/main/java/.../GrpcBackendApplication.java` | Classe principal Spring Boot | ~12 |
| `backend/src/main/java/.../ProcessingServiceImpl.java` | **Implementação do Server Streaming** | ~95 |

**Pontos-chave do Backend:**
- `@GrpcService`: Registra o serviço gRPC
- `StreamObserver<T>`: Interface para enviar múltiplas respostas
- `responseObserver.onNext()`: Envia cada mensagem
- `responseObserver.onCompleted()`: Finaliza o stream

### ? Frontend (Angular 19)

| Arquivo | Descrição | Linhas |
|---------|-----------|--------|
| `frontend/package.json` | Dependências npm (Angular, gRPC-Web) | ~35 |
| `frontend/angular.json` | Configuração do Angular CLI | ~70 |
| `frontend/proxy.conf.json` | Proxy para redirecionar gRPC-Web | ~8 |
| `frontend/src/main.ts` | Bootstrap standalone | ~5 |
| `frontend/src/app/app.component.ts` | **Componente com Signals** | ~95 |
| `frontend/src/app/app.component.html` | Template com @if/@for | ~60 |
| `frontend/src/app/app.component.css` | Estilos responsivos | ~200 |
| `frontend/src/app/services/processing.service.ts` | **Cliente gRPC-Web** | ~55 |

**Pontos-chave do Frontend:**
- `signal()`: Estado reativo do Angular 19
- `Observable`: Encapsula o stream gRPC-Web
- `stream.on('data')`: Callback para cada mensagem
- Standalone Components: Sem NgModules

### ? Infraestrutura

| Arquivo | Descrição | Linhas |
|---------|-----------|--------|
| `envoy.yaml` | Configuração do Envoy Proxy (CORS, routing) | ~60 |
| `docker-compose.yml` | Orquestração do Envoy | ~12 |

## ? Fluxo de Geração de Código

### Backend (Java)

```
proto/processing.proto
        ?
   protoc-maven-plugin
        ?
backend/src/main/java/com/example/grpc/processing/
    ??? ProcessingProto.java
    ??? ProcessingRequest.java
    ??? ProcessingResponse.java
    ??? ProcessingServiceGrpc.java
```

**Comando:**
```bash
cd backend
mvn clean compile
```

### Frontend (TypeScript)

```
proto/processing.proto
        ?
   protoc + protoc-gen-grpc-web
        ?
frontend/src/generated/
    ??? processing_pb.js
    ??? processing_pb.d.ts
    ??? ProcessingServiceClientPb.js
    ??? ProcessingServiceClientPb.d.ts
```

**Comando:**
```bash
cd frontend
npm run proto:generate
```

## ? Tamanho dos Arquivos

| Componente | Arquivos | Linhas de Código |
|------------|----------|------------------|
| Proto | 1 | ~25 |
| Backend | 4 | ~230 |
| Frontend | 8 | ~500 |
| Config | 5 | ~150 |
| Docs | 6 | ~1000 |
| **Total** | **24** | **~1905** |

## ? Arquivos Críticos (Não Deletar!)

1. ? `proto/processing.proto` - Contrato gRPC
2. ? `backend/pom.xml` - Dependências do backend
3. ? `backend/src/.../ProcessingServiceImpl.java` - Lógica de streaming
4. ? `frontend/package.json` - Dependências do frontend
5. ? `frontend/src/app/services/processing.service.ts` - Cliente gRPC
6. ? `frontend/src/app/app.component.ts` - Componente principal
7. ? `envoy.yaml` - Configuração do proxy

## ?? Arquivos Gerados (Podem ser Regenerados)

- `backend/target/` - Compilados Java
- `backend/src/main/java/.../processing/` - Stubs gRPC Java
- `frontend/node_modules/` - Dependências npm
- `frontend/dist/` - Build do Angular
- `frontend/src/generated/` - Stubs gRPC TypeScript

## ? Dependências Externas

### Backend
- Spring Boot 3.2.0
- gRPC Java 1.60.0
- Protobuf 3.25.1
- grpc-spring-boot-starter 3.1.0

### Frontend
- Angular 19.0.0
- gRPC-Web 1.5.0
- google-protobuf 3.21.2

### Infraestrutura
- Envoy Proxy 1.28
- Docker & Docker Compose

## ? Ordem de Execução

```
1. Backend (porta 9090)
   ?
2. Envoy (porta 8080)
   ?
3. Frontend (porta 4200)
```

## ? Convenções de Código

### Backend (Java)
- Package: `com.example.grpc`
- Estilo: CamelCase
- Logs: SLF4J

### Frontend (TypeScript)
- Estilo: camelCase
- Signals: `signal<T>()`
- Standalone: Sem NgModules

### Proto
- Estilo: snake_case
- Package: `processing`
- Syntax: proto3

