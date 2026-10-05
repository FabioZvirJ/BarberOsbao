import { Request, Response } from 'express';
import { WhatsAppService } from '../services/whatsappService';
import { WhatsAppBotService } from '../services/whatsappBotService';

export class WhatsAppController {
  /**
   * Validação de Webhook oficial da Meta (GET /webhook/whatsapp)
   */
  public static verifyWebhook(req: Request, res: Response) {
    const mode = req.query['hub.mode'];
    const token = req.query['hub.verify_token'];
    const challenge = req.query['hub.challenge'];

    const expectedToken = process.env.WHATSAPP_VERIFY_TOKEN || 'barberosbao_verify_token';

    if (mode === 'subscribe' && token === expectedToken) {
      console.log('[WhatsApp Webhook]: Handshake com a Meta validado com sucesso!');
      return res.status(200).send(challenge);
    }

    console.warn('[WhatsApp Webhook]: Tentativa inválida de validação de token', { mode, token });
    return res.status(403).json({ error: 'Token de verificação inválido' });
  }

  /**
   * Recebe notificações e mensagens do WhatsApp (POST /webhook/whatsapp)
   */
  public static async handleIncomingWebhook(req: Request, res: Response) {
    // Responde 200 OK imediatamente para a Meta não reenviar a mesma mensagem
    res.status(200).json({ status: 'received' });

    try {
      let fromPhone = '';
      let messageText = '';

      // 1. Formato oficial Meta WhatsApp Cloud API
      const entry = req.body?.entry?.[0];
      const changes = entry?.changes?.[0];
      const value = changes?.value;
      const message = value?.messages?.[0];

      if (message) {
        fromPhone = message.from;
        if (message.type === 'text') {
          messageText = message.text?.body || '';
        } else if (message.type === 'button') {
          messageText = message.button?.text || message.button?.payload || '';
        } else if (message.type === 'interactive') {
          messageText =
            message.interactive?.button_reply?.title ||
            message.interactive?.list_reply?.title ||
            message.interactive?.list_reply?.id ||
            '';
        }
      }

      // 2. Formato Simplificado (Evolution API / Baileys / simulador direto)
      if (!fromPhone && (req.body?.phone || req.body?.from)) {
        fromPhone = req.body.phone || req.body.from;
        messageText = req.body.text || req.body.message || '';
      }

      if (!fromPhone || !messageText) {
        return;
      }

      console.log(`[WhatsApp Webhook In] de ${fromPhone}: "${messageText}"`);

      // Processa mensagem na máquina de estados
      const replyText = await WhatsAppBotService.processMessage(fromPhone, messageText);

      // Envia resposta de volta para o cliente
      await WhatsAppService.sendMessage(fromPhone, replyText);
    } catch (err) {
      console.error('[WhatsApp Webhook Handler Error]:', err);
    }
  }

  /**
   * Simulador síncrono para testar fluxos pelo frontend, terminal ou testes
   * POST /webhook/whatsapp/simulate
   * Body: { "phone": "41999999999", "text": "Olá" }
   */
  public static async simulateWebhook(req: Request, res: Response) {
    try {
      const { phone, text } = req.body;

      if (!phone || typeof phone !== 'string' || !text || typeof text !== 'string') {
        return res.status(400).json({
          error: 'Parâmetros "phone" e "text" são obrigatórios (ambos strings).',
        });
      }

      const reply = await WhatsAppBotService.processMessage(phone, text);

      return res.json({
        success: true,
        phone,
        input: text,
        reply,
      });
    } catch (err: any) {
      console.error('[WhatsApp Simulator Error]:', err);
      return res.status(500).json({ error: err.message || 'Erro ao processar simulação' });
    }
  }

  /**
   * Status e instruções da configuração do Bot (GET /webhook/whatsapp/status)
   */
  public static getStatus(_req: Request, res: Response) {
    const isConfigured = Boolean(
      process.env.WHATSAPP_TOKEN && process.env.WHATSAPP_PHONE_NUMBER_ID,
    );

    return res.json({
      status: 'online',
      provider: isConfigured ? 'Meta WhatsApp Cloud API (Ativo)' : 'Modo Simulação / Desenvolvimento',
      metaConfigured: isConfigured,
      webhookVerifyToken: process.env.WHATSAPP_VERIFY_TOKEN ? 'Configurado' : 'Padrão (barberosbao_verify_token)',
      webhookUrl: 'https://barberosbao-api.onrender.com/webhook/whatsapp',
    });
  }
}

