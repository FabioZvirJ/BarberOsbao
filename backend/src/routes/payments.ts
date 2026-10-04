import { Router } from 'express';
import { body, param } from 'express-validator';
import { listPayments, getPayment, createPayment } from '../controllers/paymentsController';
import { validateRequest } from '../middleware/validate';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', listPayments);
router.get('/:id', [param('id').notEmpty()], validateRequest, getPayment);
router.post(
  '/',
  [
    body('appointmentId').notEmpty().withMessage('ID do agendamento é obrigatório'),
    body('amount').isFloat({ min: 0.01 }).withMessage('Valor do pagamento deve ser positivo'),
  ],
  validateRequest,
  createPayment,
);

export default router;
