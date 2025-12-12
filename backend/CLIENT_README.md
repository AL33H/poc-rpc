# Cliente gRPC Java - ProcessingService

Este documento descreve como usar o cliente Java de exemplo para testar o serviço gRPC `ProcessingService`.

## 🏗️ Arquitetura

```
Cliente Java (gRPC)  ──────────────────────> Backend gRPC (porta 9090)

Frontend Angular (gRPC-Web) ──> Envoy (porta 8080) ──> Backend gRPC (porta 9090)
```

**Importante:**
- O cliente Java conecta **diretamente** ao servidor gRPC na porta **9090**
- O frontend Angular usa **Envoy** na porta **8080** (que converte gRPC-Web para gRPC)

## 📋 Pré-requisitos

- Java 17 ou superior
- Maven 3.6 ou superior
- Servidor gRPC rodando na porta 9090

## 🚀 Como Executar

### Opção 1: Usando os Scripts (Recomendado)

#### Windows
```bash
run-client.bat
```

#### Linux/Mac
```bash
chmod +x run-client.sh
./run-client.sh
```

### Opção 2: Usando Maven Diretamente

```bash
# Compilar o projeto
mvn clean compile

# Executar o cliente
mvn exec:java -Dexec.mainClass="com.example.grpc.client.ProcessingClient"
```

### Opção 3: Com Parâmetros Personalizados

Você pode passar parâmetros personalizados para o cliente:

```bash
# Windows
run-client.bat localhost 9090 meu-request-id

# Linux/Mac
./run-client.sh localhost 9090 meu-request-id

# Maven
mvn exec:java -Dexec.mainClass="com.example.grpc.client.ProcessingClient" -Dexec.args="localhost 9090 meu-request-id"
```

**Parâmetros:**
1. `host` - Host do servidor gRPC (padrão: localhost)
2. `port` - Porta do servidor gRPC (padrão: 9090)
3. `requestId` - ID da requisição (padrão: test-request-{timestamp})

## 📊 Saída Esperada

Quando você executar o cliente, verá uma saída similar a esta:

```
================================================================================
INICIANDO TESTE DO CLIENTE GRPC
================================================================================
Request ID: test-request-1234567890
Timestamp: 2025-12-12T10:30:00Z
================================================================================

Enviando requisição para o servidor...

┌─ MENSAGEM RECEBIDA #1 ────────────────────────────────────────────────────
│ Status:    PROCESSING
│ Message:   Processando...
│ Payload:   (vazio)
│ Timestamp: 2025-12-12T10:30:00.123Z
└───────────────────────────────────────────────────────────────────────────

┌─ MENSAGEM RECEBIDA #2 ────────────────────────────────────────────────────
│ Status:    SUCCESS
│ Message:   Processado com Sucesso
│ Payload:   {"requestId":"test-request-1234567890","processedAt":"2025-12-12T10:30:18.456Z","duration":"18s"}
│ Timestamp: 2025-12-12T10:30:18.456Z
└───────────────────────────────────────────────────────────────────────────

┌─ STREAM FINALIZADO ───────────────────────────────────────────────────────
│ Total de mensagens recebidas: 2
│ Timestamp: 2025-12-12T10:30:18.500Z
└───────────────────────────────────────────────────────────────────────────
```

## 🔍 Como Funciona

O cliente realiza as seguintes etapas:

1. **Conexão**: Estabelece uma conexão com o servidor gRPC
2. **Requisição**: Envia uma requisição com um `request_id`
3. **Stream**: Recebe um stream de respostas do servidor:
   - **Primeira mensagem**: Status `PROCESSING` (imediato)
   - **Segunda mensagem**: Status `SUCCESS` (após 15-20 segundos)
4. **Finalização**: Fecha a conexão após receber todas as mensagens

## 🧪 Testando o Servidor

Para testar o servidor completo:

1. **Inicie o servidor**:
   ```bash
   mvn spring-boot:run
   ```

2. **Em outro terminal, execute o cliente**:
   ```bash
   run-client.bat  # Windows
   ./run-client.sh # Linux/Mac
   ```

3. **Observe os logs**:
   - No terminal do servidor, você verá os logs de processamento
   - No terminal do cliente, você verá as mensagens recebidas

## 📝 Código do Cliente

O cliente está localizado em:
```
src/main/java/com/example/grpc/client/ProcessingClient.java
```

### Principais Componentes:

- **ManagedChannel**: Canal de comunicação com o servidor
- **ProcessingServiceStub**: Stub assíncrono para chamadas com streaming
- **StreamObserver**: Observer para receber as respostas do stream
- **CountDownLatch**: Sincronização para aguardar a conclusão do stream

## 🛠️ Personalização

Você pode modificar o cliente para:

- Adicionar mais lógica de processamento das respostas
- Implementar retry logic
- Adicionar autenticação/autorização
- Modificar o timeout (padrão: 30 segundos)
- Adicionar métricas e logging

## 🐛 Troubleshooting

### Erro: "Connection refused"
- Verifique se o servidor está rodando
- Confirme que a porta 9090 está correta (porta do servidor gRPC)
- **Não use a porta 8080** (essa é a porta do Envoy, não do servidor gRPC direto)

### Erro: "TIMEOUT"
- O servidor pode estar demorando mais de 30 segundos
- Aumente o timeout no código do cliente

### Erro: "Maven not found"
- Instale o Maven e adicione ao PATH
- Verifique com: `mvn --version`

## 📚 Referências

- [gRPC Java Documentation](https://grpc.io/docs/languages/java/)
- [Protocol Buffers](https://developers.google.com/protocol-buffers)
- [Spring Boot gRPC](https://github.com/yidongnan/grpc-spring-boot-starter)

