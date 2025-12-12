# 🚀 Guia Rápido - Cliente gRPC

## 🏗️ Arquitetura

```
Cliente Java (gRPC)  ──────────────────────> Backend gRPC (porta 9090)

Frontend Angular (gRPC-Web) ──> Envoy (porta 8080) ──> Backend gRPC (porta 9090)
```

**Portas:**
- **9090**: Servidor gRPC (acesso direto para clientes Java/gRPC nativos)
- **8080**: Envoy Proxy (para frontend via gRPC-Web)

## Início Rápido (3 passos)

### 1️⃣ Inicie o Servidor
Em um terminal:
```bash
mvn spring-boot:run
```

Aguarde até ver a mensagem:
```
Started GrpcBackendApplication in X.XXX seconds
```

### 2️⃣ Execute o Cliente
Em outro terminal:

**Windows:**
```bash
test-client.bat
```

**Linux/Mac:**
```bash
chmod +x run-client.sh
./run-client.sh
```

### 3️⃣ Observe os Resultados
Você verá:
- ✅ Mensagem 1: "PROCESSING" (imediato)
- ⏳ Aguardando 15-20 segundos...
- ✅ Mensagem 2: "SUCCESS" (com payload JSON)

## 📁 Arquivos Criados

```
backend/
├── src/main/java/com/example/grpc/
│   └── client/
│       └── ProcessingClient.java          # Cliente Java
├── run-client.bat                          # Script Windows
├── run-client.sh                           # Script Linux/Mac
├── test-client.bat                         # Teste rápido Windows
├── CLIENT_README.md                        # Documentação completa
└── QUICK_START_CLIENT.md                   # Este arquivo

proto/
└── processing.proto                        # Definição do serviço (recriado)
```

## 🎯 Exemplo de Uso

### Teste Básico
```bash
# Windows
test-client.bat

# Linux/Mac
./run-client.sh
```

### Com Parâmetros Personalizados
```bash
# Windows
run-client.bat localhost 9090 meu-teste-123

# Linux/Mac
./run-client.sh localhost 9090 meu-teste-123
```

### Usando Maven Diretamente
```bash
mvn exec:java -Dexec.mainClass="com.example.grpc.client.ProcessingClient"
```

## 📊 Saída Esperada

```
================================================================================
INICIANDO TESTE DO CLIENTE GRPC
================================================================================
Request ID: test-request-1702389012345
Timestamp: 2025-12-12T10:30:12.345Z
================================================================================

Enviando requisição para o servidor...

┌─ MENSAGEM RECEBIDA #1 ────────────────────────────────────────────────────
│ Status:    PROCESSING
│ Message:   Processando...
│ Payload:   (vazio)
│ Timestamp: 2025-12-12T10:30:12.456Z
└───────────────────────────────────────────────────────────────────────────

[Aguardando 15-20 segundos...]

┌─ MENSAGEM RECEBIDA #2 ────────────────────────────────────────────────────
│ Status:    SUCCESS
│ Message:   Processado com Sucesso
│ Payload:   {"requestId":"test-request-1702389012345","processedAt":"...","duration":"18s"}
│ Timestamp: 2025-12-12T10:30:30.789Z
└───────────────────────────────────────────────────────────────────────────

┌─ STREAM FINALIZADO ───────────────────────────────────────────────────────
│ Total de mensagens recebidas: 2
│ Timestamp: 2025-12-12T10:30:30.800Z
└───────────────────────────────────────────────────────────────────────────
```

## 🔧 Troubleshooting

### ❌ "Connection refused"
**Problema:** Servidor não está rodando
**Solução:** Execute `mvn spring-boot:run` primeiro

### ❌ "TIMEOUT"
**Problema:** Servidor demorou mais de 30 segundos
**Solução:** Normal, o servidor aguarda 15-20 segundos por design

### ❌ "Maven not found"
**Problema:** Maven não instalado ou não está no PATH
**Solução:** Instale Maven e adicione ao PATH

## 📚 Documentação Completa

Para mais detalhes, consulte:
- `CLIENT_README.md` - Documentação completa do cliente
- `../proto/processing.proto` - Definição do serviço gRPC

## 🎓 Próximos Passos

1. ✅ Teste o cliente básico
2. 🔄 Modifique o `request_id` para testar diferentes requisições
3. 📝 Observe os logs do servidor enquanto o cliente executa
4. 🛠️ Personalize o cliente para suas necessidades

## 💡 Dicas

- Execute múltiplos clientes simultaneamente para testar concorrência
- Monitore os logs do servidor para ver o processamento
- Use diferentes `request_id` para identificar cada requisição
- O servidor aguarda aleatoriamente entre 15-20 segundos

## 🆘 Precisa de Ajuda?

Consulte a documentação completa em `CLIENT_README.md` ou os logs do servidor/cliente para mais informações.

