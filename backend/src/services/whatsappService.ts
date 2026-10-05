import dotenv from 'dotenv';
dotenv.config();

export interface WhatsAppSendMessageResult {
  success: boolean;
  messageId?: string;
  error?: string;
  simulated?: boolean;
}

/**
 * Serviço de integração com o WhatsApp Cloud API oficial da Meta.
 * Também suporta modo simulado quando as chaves não estão configuradas.
 */
export class WhatsAppService {
  private static get token(): string {
    return process.env.WHATSAPP_TOKEN || '';
  }

  private static get phoneNumberId(): string {
    return process.env.WHATSAPP_PHONE_NUMBER_ID || '';
  }

  /**
   * Limpa o telefone para o padrão internacional sem caracteres especiais (ex: 5541999999999)
   */
  public static cleanPhoneNumber(phone: string): string {
    let cleaned = phone.replace(/\D/g, '');
    if (cleaned.startsWith('55') && (cleaned.length === 12 || cleaned.length === 13)) {
      return cleaned;
    }
    // Se digitou sem DDI (55), adiciona 55 se for DDD brasileiro (10 ou 11 dígitos)
    if (cleaned.length === 10 || cleaned.length === 11) {
      return `55${cleaned}`;
    }
    return cleaned;
  }

  /**
   * Envia uma mensagem de texto via Meta WhatsApp Cloud API.
   * Se WHATSAPP_TOKEN e WHATSAPP_PHONE_NUMBER_ID não estiverem configurados,
   * a mensagem é registrada em log (modo de simulação/desenvolvimento).
   */
  public static async sendMessage(to: string, messageText: string): Promise<WhatsAppSendMessageResult> {
    const formattedPhone = this.cleanPhoneNumber(to);

    // Modo simulação se não tiver credenciais da Meta configuradas
    if (!this.token || !this.phoneNumberId) {
      console.log(`[WhatsApp Simulator -> ${formattedPhone}]:\n${messageText}\n${'='.repeat(40)}`);
      return {
        success: true,
        simulated: true,
        messageId: `mock_${Date.now()}`,
      };
    }

    try {
      const url = `https://graph.facebook.com/v19.0/${this.phoneNumberId}/messages`;
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          recipient_type: 'individual',
          to: formattedPhone,
          type: 'text',
          text: {
            preview_url: false,
            body: messageText,
          },
        }),
      });

      const data = (await response.json()) as any;

      if (!response.ok) {
        console.error('[WhatsApp Cloud API Error]:', data);
        return {
          success: false,
          error: data?.error?.message || 'Falha ao enviar mensagem no WhatsApp',
        };
      }

      return {
        success: true,
        messageId: data?.messages?.[0]?.id,
      };
    } catch (err: any) {
      console.error('[WhatsApp Service Exception]:', err);
      return {
        success: false,
        error: err.message || 'Erro inesperado ao conectar com a Meta Cloud API',
      };
    }
  }
}

