import { Router } from 'express';
import { listPayments, getPayment, createPayment } from '../controllers/paymentsController';

const router = Router();

router.get('/', listPayments);
router.get('/:id', getPayment);
router.post('/', createPayment);

export default router;
