package com.example.grpc.service;

import com.example.grpc.processing.ProcessingRequest;
import com.example.grpc.processing.ProcessingResponse;
import com.example.grpc.processing.ProcessingServiceGrpc;
import io.grpc.stub.StreamObserver;
import net.devh.boot.grpc.server.service.GrpcService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Instant;
import java.util.Random;
import java.util.concurrent.TimeUnit;


@GrpcService
public class ProcessingServiceImpl extends ProcessingServiceGrpc.ProcessingServiceImplBase {

    private static final Logger logger = LoggerFactory.getLogger(ProcessingServiceImpl.class);
    private final Random random = new Random();

    @Override
    public void startProcessing(ProcessingRequest request, StreamObserver<ProcessingResponse> responseObserver) {
        String requestId = request.getRequestId().isEmpty() ? "default-id" : request.getRequestId();
        
        logger.info("Recebida requisição de processamento. Request ID: {}", requestId);

        try {
            // PRIMEIRA MENSAGEM: Status imediato "Processando..."
            ProcessingResponse initialResponse = ProcessingResponse.newBuilder()
                    .setStatus("PROCESSING")
                    .setMessage("Processando...")
                    .setPayload("")
                    .setTimestamp(Instant.now().toEpochMilli())
                    .build();

            responseObserver.onNext(initialResponse);
            logger.info("Enviada resposta inicial: PROCESSING");

            // SIMULAÇÃO DE PROCESSAMENTO PESADO
            // Aguarda entre 15 e 20 segundos
            int delaySeconds = 15 + random.nextInt(6); // 15 a 20 segundos
            logger.info("Iniciando processamento pesado. Aguardando {} segundos...", delaySeconds);
            
            TimeUnit.SECONDS.sleep(delaySeconds);

            // SEGUNDA MENSAGEM: Status final "Processado com Sucesso"
            ProcessingResponse finalResponse = ProcessingResponse.newBuilder()
                    .setStatus("SUCCESS")
                    .setMessage("Processado com Sucesso")
                    .setPayload(String.format(
                            "{\"requestId\":\"%s\",\"processedAt\":\"%s\",\"duration\":\"%ds\"}",
                            requestId,
                            Instant.now().toString(),
                            delaySeconds
                    ))
                    .setTimestamp(Instant.now().toEpochMilli())
                    .build();

            responseObserver.onNext(finalResponse);
            logger.info("Enviada resposta final: SUCCESS");

            // Finaliza o stream
            responseObserver.onCompleted();
            logger.info("Stream finalizado para Request ID: {}", requestId);

        } catch (InterruptedException e) {
            logger.error("Processamento interrompido", e);
            
            // Em caso de erro, envia resposta de erro
            ProcessingResponse errorResponse = ProcessingResponse.newBuilder()
                    .setStatus("ERROR")
                    .setMessage("Erro durante o processamento: " + e.getMessage())
                    .setPayload("")
                    .setTimestamp(Instant.now().toEpochMilli())
                    .build();

            responseObserver.onNext(errorResponse);
            responseObserver.onError(e);
            
            Thread.currentThread().interrupt();
        } catch (Exception e) {
            logger.error("Erro inesperado durante o processamento", e);
            responseObserver.onError(e);
        }
    }
}

