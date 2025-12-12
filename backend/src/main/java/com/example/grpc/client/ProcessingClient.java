package com.example.grpc.client;

import com.example.grpc.processing.ProcessingRequest;
import com.example.grpc.processing.ProcessingResponse;
import com.example.grpc.processing.ProcessingServiceGrpc;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.stub.StreamObserver;

import java.time.Instant;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * Cliente gRPC de exemplo para testar o ProcessingService
 *
 * Este cliente:
 * - Conecta ao servidor gRPC na porta 8080
 * - Envia uma requisição com um request_id
 * - Recebe e processa o stream de respostas
 * - Exibe as mensagens recebidas em tempo real
 */
public class ProcessingClient {

    private final ManagedChannel channel;
    private final ProcessingServiceGrpc.ProcessingServiceStub asyncStub;

    /**
     * Construtor do cliente
     * @param host Host do servidor gRPC
     * @param port Porta do servidor gRPC
     */
    public ProcessingClient(String host, int port) {
        // Cria o canal de comunicação com o servidor
        this.channel = ManagedChannelBuilder.forAddress(host, port)
                .usePlaintext() // Sem TLS para desenvolvimento
                .build();

        // Cria o stub assíncrono para chamadas com streaming
        this.asyncStub = ProcessingServiceGrpc.newStub(channel);
    }

    /**
     * Fecha o canal de comunicação
     */
    public void shutdown() throws InterruptedException {
        channel.shutdown().awaitTermination(5, TimeUnit.SECONDS);
    }

    /**
     * Inicia o processamento e recebe o stream de respostas
     * @param requestId ID da requisição
     */
    public void startProcessing(String requestId) throws InterruptedException {
        System.out.println("=".repeat(80));
        System.out.println("INICIANDO TESTE DO CLIENTE GRPC");
        System.out.println("=".repeat(80));
        System.out.println("Request ID: " + requestId);
        System.out.println("Timestamp: " + Instant.now());
        System.out.println("=".repeat(80));
        System.out.println();

        // CountDownLatch para aguardar a conclusão do stream
        final CountDownLatch finishLatch = new CountDownLatch(1);

        // Cria a requisição
        ProcessingRequest request = ProcessingRequest.newBuilder()
                .setRequestId(requestId)
                .build();

        // Cria o observer para receber as respostas do stream
        StreamObserver<ProcessingResponse> responseObserver = new StreamObserver<ProcessingResponse>() {
            private int messageCount = 0;

            @Override
            public void onNext(ProcessingResponse response) {
                messageCount++;
                System.out.println("┌─ MENSAGEM RECEBIDA #" + messageCount + " " + "─".repeat(60));
                System.out.println("│ Status:    " + response.getStatus());
                System.out.println("│ Message:   " + response.getMessage());
                System.out.println("│ Payload:   " + (response.getPayload().isEmpty() ? "(vazio)" : response.getPayload()));
                System.out.println("│ Timestamp: " + Instant.ofEpochMilli(response.getTimestamp()));
                System.out.println("└" + "─".repeat(79));
                System.out.println();
            }

            @Override
            public void onError(Throwable t) {
                System.err.println("┌─ ERRO " + "─".repeat(73));
                System.err.println("│ Erro ao receber resposta do servidor:");
                System.err.println("│ " + t.getMessage());
                System.err.println("└" + "─".repeat(79));
                t.printStackTrace();
                finishLatch.countDown();
            }

            @Override
            public void onCompleted() {
                System.out.println("┌─ STREAM FINALIZADO " + "─".repeat(59));
                System.out.println("│ Total de mensagens recebidas: " + messageCount);
                System.out.println("│ Timestamp: " + Instant.now());
                System.out.println("└" + "─".repeat(79));
                finishLatch.countDown();
            }
        };

        // Envia a requisição e recebe o stream de respostas
        System.out.println("Enviando requisição para o servidor...");
        System.out.println();
        asyncStub.startProcessing(request, responseObserver);

        // Aguarda a conclusão do stream (com timeout de 30 segundos)
        if (!finishLatch.await(30, TimeUnit.SECONDS)) {
            System.err.println("TIMEOUT: O stream não foi concluído em 30 segundos");
        }
    }

    /**
     * Método main para executar o cliente
     */
    public static void main(String[] args) {
        String host = "localhost";
        int port = 9090; // Porta do servidor gRPC (acesso direto, sem Envoy)
        String requestId = "test-request-" + System.currentTimeMillis();

        // Permite passar host, porta e requestId como argumentos
        if (args.length >= 1) {
            host = args[0];
        }
        if (args.length >= 2) {
            port = Integer.parseInt(args[1]);
        }
        if (args.length >= 3) {
            requestId = args[2];
        }

        ProcessingClient client = new ProcessingClient(host, port);

        try {
            client.startProcessing(requestId);
        } catch (InterruptedException e) {
            System.err.println("Cliente interrompido: " + e.getMessage());
            Thread.currentThread().interrupt();
        } finally {
            try {
                client.shutdown();
            } catch (InterruptedException e) {
                System.err.println("Erro ao fechar o cliente: " + e.getMessage());
                Thread.currentThread().interrupt();
            }
        }
    }
}

