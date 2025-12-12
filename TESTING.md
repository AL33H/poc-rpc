# ? Guia de Testes

## ? Testes Manuais

### 1. Teste Básico de Streaming

**Objetivo:** Verificar se o servidor envia duas mensagens no stream.

**Passos:**
1. Acesse `http://localhost:4200`
2. Clique em "Iniciar Processamento"
3. **Esperado:**
   - Status muda imediatamente para "Processando..."
   - Após 15-20 segundos, status muda para "Processado com Sucesso"
   - Payload JSON é exibido
   - Logs mostram 2 mensagens recebidas

### 2. Teste de Múltiplas Requisições

**Objetivo:** Verificar se o sistema suporta múltiplas chamadas sequenciais.

**Passos:**
1. Clique em "Iniciar Processamento"
2. Aguarde a conclusão
3. Clique novamente em "Iniciar Processamento"
4. **Esperado:**
   - Segunda requisição funciona normalmente
   - Logs são resetados
   - Novo Request ID é gerado

### 3. Teste de Desabilitação do Botão

**Objetivo:** Verificar se o botão é desabilitado durante o processamento.

**Passos:**
1. Clique em "Iniciar Processamento"
2. Tente clicar novamente enquanto processa
3. **Esperado:**
   - Botão fica desabilitado
   - Texto muda para "Processando..."
   - Spinner é exibido

### 4. Teste de Logs em Tempo Real

**Objetivo:** Verificar se os logs são atualizados em tempo real.

**Passos:**
1. Clique em "Iniciar Processamento"
2. Observe a seção de logs
3. **Esperado:**
   - Log "? Iniciando requisição gRPC..." aparece imediatamente
   - Log "? [timestamp] PROCESSING: Processando..." aparece em seguida
   - Log "? [timestamp] SUCCESS: Processado com Sucesso" aparece após 15-20s
   - Log "? Stream finalizado com sucesso" aparece ao final

## ? Testes de Backend

### Teste 1: Verificar Servidor gRPC

```bash
# Windows
netstat -an | findstr :9090

# Linux/Mac
lsof -i :9090
```

**Esperado:** Porta 9090 em LISTENING

### Teste 2: Logs do Backend

```bash
cd backend
mvn spring-boot:run
```

**Esperado nos logs:**
```
Started GrpcBackendApplication in X seconds
gRPC Server started, listening on address: *, port: 9090
```

### Teste 3: Verificar Processamento

Ao fazer uma requisição, os logs devem mostrar:
```
Recebida requisição de processamento. Request ID: req-1234567890
Enviada resposta inicial: PROCESSING
Iniciando processamento pesado. Aguardando 17 segundos...
Enviada resposta final: SUCCESS
Stream finalizado para Request ID: req-1234567890
```

## ? Testes de Envoy Proxy

### Teste 1: Verificar Status do Envoy

```bash
curl http://localhost:9901/stats | grep grpc
```

**Esperado:** Estatísticas do gRPC

### Teste 2: Verificar Logs do Envoy

```bash
docker-compose logs -f envoy
```

**Esperado:** Logs de requisições gRPC-Web sendo traduzidas

### Teste 3: Health Check

```bash
curl http://localhost:9901/ready
```

**Esperado:** `LIVE`

## ? Testes de Frontend

### Teste 1: Verificar Geração de Stubs

```bash
cd frontend
ls -la src/generated/
```

**Esperado:**
- `processing_pb.js`
- `processing_pb.d.ts`
- `ProcessingServiceClientPb.js`
- `ProcessingServiceClientPb.d.ts`

### Teste 2: Console do Navegador

Abra DevTools (F12) e observe o console durante uma requisição.

**Esperado:**
```
Resposta recebida do stream: {status: "PROCESSING", message: "Processando...", ...}
Resposta recebida do stream: {status: "SUCCESS", message: "Processado com Sucesso", ...}
Stream finalizado
```

### Teste 3: Network Tab

Abra DevTools ? Network ? Filtro: XHR

**Esperado:**
- 1 requisição para `/processing.ProcessingService/StartProcessing`
- Status: 200 OK
- Type: grpc-web-text

## ? Testes de Erro

### Teste 1: Backend Offline

**Passos:**
1. Pare o backend (Ctrl+C)
2. Tente fazer uma requisição no frontend
3. **Esperado:**
   - Status muda para "ERRO"
   - Mensagem de erro é exibida
   - Log mostra erro de conexão

### Teste 2: Envoy Offline

**Passos:**
1. Pare o Envoy (`docker-compose down`)
2. Tente fazer uma requisição
3. **Esperado:**
   - Erro de conexão
   - Status "ERRO"

### Teste 3: Timeout

**Modificação temporária no backend:**
```java
// Aumentar o sleep para 60 segundos
TimeUnit.SECONDS.sleep(60);
```

**Esperado:**
- Timeout após 30 segundos (configuração padrão do Envoy)
- Erro exibido no frontend

## ? Testes de Performance

### Teste 1: Tempo de Primeira Resposta

**Objetivo:** Verificar se a primeira resposta é imediata.

**Método:**
1. Abra DevTools ? Network
2. Clique em "Iniciar Processamento"
3. Observe o timestamp do primeiro log

**Esperado:** < 500ms

### Teste 2: Tempo Total

**Esperado:** Entre 15 e 20 segundos (conforme configurado)

### Teste 3: Uso de Memória

**Método:**
```bash
# Backend
jconsole # Conecte ao processo Java

# Frontend
# DevTools ? Performance ? Memory
```

**Esperado:** Sem vazamentos de memória após múltiplas requisições

## ? Checklist de Validação

- [ ] Backend inicia sem erros
- [ ] Envoy inicia sem erros
- [ ] Frontend compila sem erros
- [ ] Primeira resposta é imediata
- [ ] Segunda resposta chega após 15-20s
- [ ] Payload JSON é válido
- [ ] Logs são exibidos corretamente
- [ ] Botão é desabilitado durante processamento
- [ ] Múltiplas requisições funcionam
- [ ] Erros são tratados adequadamente
- [ ] UI é responsiva e atualiza em tempo real

## ? Testes Avançados

### Teste com grpcurl (Opcional)

Se você tiver `grpcurl` instalado:

```bash
grpcurl -plaintext \
  -d '{"request_id": "test-123"}' \
  localhost:9090 \
  processing.ProcessingService/StartProcessing
```

**Esperado:** Duas mensagens JSON no output

### Teste de Carga (Opcional)

Use `ghz` para teste de carga:

```bash
ghz --insecure \
  --proto ../proto/processing.proto \
  --call processing.ProcessingService.StartProcessing \
  -d '{"request_id":"load-test"}' \
  -n 10 \
  localhost:9090
```

## ? Relatório de Bugs

Se encontrar problemas, documente:

1. **Passos para reproduzir**
2. **Comportamento esperado**
3. **Comportamento observado**
4. **Logs relevantes** (backend, envoy, frontend console)
5. **Ambiente** (SO, versões de Java/Node/Docker)

## ? Conclusão

Se todos os testes passarem, sua PoC está funcionando perfeitamente! ?

