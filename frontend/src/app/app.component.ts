import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProcessingService } from './services/processing.service';

/**
 * Componente principal que demonstra o uso de gRPC Server Streaming
 * com Angular 19 Signals para gerenciamento de estado reativo
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  // Signals para gerenciamento de estado reativo
  status = signal<string>('Aguardando');
  message = signal<string>('Clique no botão para iniciar o processamento');
  payload = signal<string>('');
  isProcessing = signal<boolean>(false);
  logs = signal<string[]>([]);

  constructor(private processingService: ProcessingService) {}

  /**
   * Inicia o processamento via gRPC Server Streaming
   * Demonstra como receber múltiplas respostas em uma única chamada
   */
  startProcessing(): void {
    if (this.isProcessing()) {
      return; // Evita múltiplas chamadas simultâneas
    }

    // Reseta o estado
    this.isProcessing.set(true);
    this.status.set('Conectando...');
    this.message.set('Estabelecendo conexão com o servidor...');
    this.payload.set('');
    this.logs.set([]);
    this.addLog('? Iniciando requisição gRPC...');

    const requestId = `req-${Date.now()}`;
    this.addLog(`? Request ID: ${requestId}`);

    // Subscreve ao Observable que receberá múltiplas respostas
    this.processingService.startProcessing(requestId).subscribe({
      next: (response) => {
        // Cada resposta do stream atualiza os Signals
        this.status.set(response.status);
        this.message.set(response.message);
        this.payload.set(response.payload);
        
        const timestamp = new Date(response.timestamp).toLocaleTimeString('pt-BR');
        this.addLog(`? [${timestamp}] ${response.status}: ${response.message}`);

        if (response.payload) {
          this.addLog(`? Payload: ${response.payload}`);
        }
      },
      error: (error) => {
        this.status.set('ERRO');
        this.message.set('Erro na comunicação com o servidor');
        this.isProcessing.set(false);
        this.addLog(`? Erro: ${error.message || 'Erro desconhecido'}`);
        console.error('Erro no stream:', error);
      },
      complete: () => {
        this.isProcessing.set(false);
        this.addLog('? Stream finalizado com sucesso');
      }
    });
  }

  /**
   * Adiciona uma entrada ao log
   */
  private addLog(message: string): void {
    this.logs.update(logs => [...logs, message]);
  }

  /**
   * Retorna a classe CSS baseada no status atual
   */
  getStatusClass(): string {
    const statusValue = this.status();
    switch (statusValue) {
      case 'PROCESSING':
        return 'status-processing';
      case 'SUCCESS':
        return 'status-success';
      case 'ERRO':
        return 'status-error';
      default:
        return 'status-waiting';
    }
  }
}

