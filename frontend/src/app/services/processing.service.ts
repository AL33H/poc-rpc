import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ProcessingServiceClient } from '../../generated/ProcessingServiceClientPb';
import { ProcessingRequest, ProcessingResponse } from '../../generated/processing_pb';

/**
 * Serviço Angular que encapsula a comunicação gRPC-Web
 * com o backend Spring Boot usando Server Streaming
 */
@Injectable({
  providedIn: 'root'
})
export class ProcessingService {
  private client: ProcessingServiceClient;

  constructor() {
    // OPÇÃO 1: Usar o proxy do Angular (requer proxy.conf.json configurado)
    // this.client = new ProcessingServiceClient('http://localhost:4200', null, null);

    // OPÇÃO 2: Conectar diretamente ao Envoy (porta 8080)
    // Requer CORS configurado no Envoy (já está configurado no envoy.yaml)
    this.client = new ProcessingServiceClient('http://localhost:8080', null, null);
  }

  /**
   * Inicia o processamento e retorna um Observable que emite
   * múltiplas respostas via Server Streaming
   */
  startProcessing(requestId: string): Observable<ProcessingResponse.AsObject> {
    return new Observable(observer => {
      const request = new ProcessingRequest();
      request.setRequestId(requestId);

      // Inicia a chamada gRPC com streaming
      const stream = this.client.startProcessing(request, {});

      // Listener para cada mensagem recebida do stream
      stream.on('data', (response: ProcessingResponse) => {
        console.log('Resposta recebida do stream:', response.toObject());
        observer.next(response.toObject());
      });

      // Listener para erros
      stream.on('error', (error: any) => {
        console.error('Erro no stream gRPC:', error);
        observer.error(error);
      });

      // Listener para finalização do stream
      stream.on('end', () => {
        console.log('Stream finalizado');
        observer.complete();
      });

      // Cleanup quando o Observable for cancelado
      return () => {
        stream.cancel();
      };
    });
  }
}

