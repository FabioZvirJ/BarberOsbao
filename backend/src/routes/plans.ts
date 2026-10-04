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

// Rotas públicas (Clientes podem ver planos e assinaturas da barbearia)
router.get('/', listPlans);
router.get('/:id', [param('id').notEmpty()], validateRequest, getPlan);

// Rotas administrativas (Apenas administradores podem cadastrar ou editar planos)
router.use(requireAuth);
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
