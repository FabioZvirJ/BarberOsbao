import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listTransactions,
  createTransaction,
  getSummary,
  listBills,
  createBill,
  updateBill,
  deleteBill,
  listCashShifts,
  getActiveCashShift,
  openCashShift,
  closeCashShift,
  addCashMovement,
  getCashMovements,
} from '../controllers/financialController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// Módulo financeiro e controle de caixa restrito exclusivamente a administradores
router.use(requireAuth);
router.use(requireRole(['admin']));

// Summary
router.get('/summary', getSummary);

// Transactions
router.get('/transactions', listTransactions);
router.post(
  '/transactions',
  [
    body('description').trim().notEmpty().withMessage('Descrição é obrigatória'),
    body('amount').isFloat({ min: 0.01 }).withMessage('Valor deve ser numérico e maior que zero'),
  ],
  validateRequest,
  createTransaction,
);

// Bills
router.get('/bills', listBills);
router.post(
  '/bills',
  createBill,
);
router.put('/bills/:id', updateBill);
router.delete('/bills/:id', [param('id').notEmpty()], validateRequest, deleteBill);

// Cash shifts
router.get('/cash-shifts', listCashShifts);
router.get('/cash-shifts/active', getActiveCashShift);
router.post('/cash-shifts/open', openCashShift);
router.post('/cash-shifts/close', closeCashShift);
router.put('/cash-shifts/:id/close', closeCashShift);
router.post('/cash-shifts/movements', addCashMovement);
router.get('/cash-shifts/:id/movements', getCashMovements);

export default router;
