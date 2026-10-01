import { Router } from 'express';
import { body, param } from 'express-validator';
import { listPayments, getPayment, createPayment } from '../controllers/paymentsController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listPayments);
router.get('/:id', [param('id').notEmpty()], validateRequest, getPayment);
router.post('/', [body('appointmentId').notEmpty(), body('amount').isNumeric()], validateRequest, createPayment);

export default router;
