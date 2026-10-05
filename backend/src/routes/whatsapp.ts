import { Router } from 'express';
import { WhatsAppController } from '../controllers/whatsappController';

const router = Router();

// 1. Verificação oficial da Meta (GET)
router.get('/', WhatsAppController.verifyWebhook);

// 2. Recebimento de mensagens oficiais e de webhooks (POST)
router.post('/', WhatsAppController.handleIncomingWebhook);

// 3. Simulador síncrono para testes instantâneos (POST)
router.post('/simulate', WhatsAppController.simulateWebhook);

// 4. Status da integração (GET)
router.get('/status', WhatsAppController.getStatus);

export default router;

