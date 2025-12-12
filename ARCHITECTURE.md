# ?? Arquitetura da Solução

## ? Visão Geral

Esta PoC demonstra a implementação de **Server Streaming** usando gRPC entre um frontend Angular e um backend Spring Boot.

## ? Fluxo de Dados Detalhado

### 1. Definição do Contrato (Proto)

```protobuf
service ProcessingService {
  rpc StartProcessing(ProcessingRequest) returns (stream ProcessingResponse);
}
```

A palavra-chave `stream` antes de `ProcessingResponse` indica que o servidor pode enviar **múltiplas mensagens** em uma única chamada RPC.

### 2. Implementação Backend (Spring Boot)

```java
@GrpcService
public class ProcessingServiceImpl extends ProcessingServiceGrpc.ProcessingServiceImplBase {
    
    @Override
    public void startProcessing(ProcessingRequest request, 
                               StreamObserver<ProcessingResponse> responseObserver) {
        
        // Primeira mensagem - IMEDIATA
        responseObserver.onNext(initialResponse);
        
        // Processamento pesado
        Thread.sleep(15000);
        
        // Segunda mensagem - APÓS PROCESSAMENTO
        responseObserver.onNext(finalResponse);
        
        // Finaliza o stream
        responseObserver.onCompleted();
    }
}
```

**Pontos-chave:**
- `StreamObserver<T>`: Interface para enviar múltiplas respostas
- `onNext()`: Envia uma mensagem no stream (pode ser chamado N vezes)
- `onCompleted()`: Sinaliza o fim do stream
- `onError()`: Envia um erro e encerra o stream

### 3. Camada de Tradução (Envoy Proxy)

O Envoy Proxy atua como um **tradutor** entre gRPC-Web (navegador) e gRPC nativo (backend):

```
Browser (gRPC-Web) ? Envoy Proxy ? Backend (gRPC)
                    ? Envoy Proxy ?
```

**Por que é necessário?**
- Navegadores não suportam HTTP/2 bidirecional necessário para gRPC nativo
- gRPC-Web usa HTTP/1.1 ou HTTP/2 unidirecional
- Envoy faz a conversão entre os protocolos

### 4. Implementação Frontend (Angular)

```typescript
// Serviço
startProcessing(requestId: string): Observable<ProcessingResponse.AsObject> {
  return new Observable(observer => {
    const stream = this.client.startProcessing(request, {});
    
    stream.on('data', (response) => {
      observer.next(response.toObject());  // Cada mensagem do stream
    });
    
    stream.on('end', () => {
      observer.complete();  // Stream finalizado
    });
  });
}

// Componente com Signals
status = signal<string>('Aguardando');

this.processingService.startProcessing(requestId).subscribe({
  next: (response) => {
    this.status.set(response.status);  // Atualiza UI reativamente
  }
});
```

**Pontos-chave:**
- Observable encapsula o stream gRPC-Web
- `stream.on('data')`: Callback para cada mensagem recebida
- Signals garantem reatividade automática na UI

## ? Tipos de Streaming gRPC

### 1. Unary (Tradicional)
```protobuf
rpc GetUser(UserRequest) returns (UserResponse);
```
- 1 requisição ? 1 resposta
- Padrão REST-like

### 2. Server Streaming (Esta PoC)
```protobuf
rpc StartProcessing(Request) returns (stream Response);
```
- 1 requisição ? N respostas
- Útil para: progresso, notificações, dados em tempo real

### 3. Client Streaming
```protobuf
rpc UploadFile(stream FileChunk) returns (UploadResponse);
```
- N requisições ? 1 resposta
- Útil para: upload de arquivos, batch processing

### 4. Bidirectional Streaming
```protobuf
rpc Chat(stream Message) returns (stream Message);
```
- N requisições ? N respostas
- Útil para: chat, jogos multiplayer, colaboração em tempo real

## ? Componentes da Stack

### Backend
- **Spring Boot 3.2.0**: Framework base
- **grpc-spring-boot-starter**: Integração gRPC com Spring
- **protobuf-maven-plugin**: Geração de código Java a partir do .proto

### Frontend
- **Angular 19**: Framework frontend
- **grpc-web**: Cliente gRPC para navegadores
- **Signals**: Sistema de reatividade do Angular
- **Standalone Components**: Arquitetura moderna sem NgModules

### Infraestrutura
- **Envoy Proxy**: Tradução gRPC-Web ? gRPC
- **Docker Compose**: Orquestração do Envoy
- **Protocol Buffers**: Serialização de dados

## ? Comparação: REST vs gRPC Streaming

| Aspecto | REST (Polling) | gRPC Streaming |
|---------|---------------|----------------|
| **Conexões** | Múltiplas requisições | 1 conexão persistente |
| **Latência** | Alta (polling interval) | Baixa (push imediato) |
| **Overhead** | Alto (headers HTTP repetidos) | Baixo (binário compacto) |
| **Complexidade** | Simples | Moderada |
| **Suporte Browser** | Nativo | Requer gRPC-Web + Proxy |

## ? Casos de Uso Reais

### Server Streaming (como nesta PoC)
- ? Progresso de processamento em tempo real
- ? Notificações push
- ? Feeds de dados (preços, cotações)
- ? Logs em tempo real
- ? Monitoramento de status

### Quando NÃO usar
- ? Requisições simples e rápidas (use Unary)
- ? Upload de arquivos grandes (use Client Streaming)
- ? Chat bidirecional (use Bidirectional Streaming)

## ? Considerações de Produção

### Segurança
- Adicionar TLS/SSL (gRPCS)
- Implementar autenticação (JWT, OAuth2)
- Validar inputs no servidor

### Performance
- Configurar timeouts adequados
- Implementar backpressure
- Monitorar uso de memória (streams longos)

### Observabilidade
- Adicionar métricas (Prometheus)
- Implementar tracing distribuído (OpenTelemetry)
- Logs estruturados

### Escalabilidade
- Load balancing no Envoy
- Múltiplas instâncias do backend
- Circuit breaker para resiliência

## ? Referências Técnicas

- [gRPC Concepts](https://grpc.io/docs/what-is-grpc/core-concepts/)
- [gRPC-Web Protocol](https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-WEB.md)
- [Angular Signals Deep Dive](https://angular.io/guide/signals)
- [Envoy gRPC Bridge](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/other_protocols/grpc)

