import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listPlans,
  getPlan,
  createPlan,
  updatePlan,
  deletePlan,
} from '../controllers/plansController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', listPlans);
router.get('/:id', [param('id').notEmpty()], validateRequest, getPlan);
router.post(
  '/',
  [
    requireRole(['admin']),
    body('name').trim().notEmpty().withMessage('Nome é obrigatório'),
    body('price').isFloat({ min: 0 }).withMessage('Preço deve ser um valor numérico positivo'),
  ],
  validateRequest,
  createPlan,
);
router.put('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, updatePlan);
router.delete('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, deletePlan);

export default router;
