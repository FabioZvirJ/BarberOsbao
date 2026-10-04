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

const router = Router();

router.get('/', listPlans);
router.get('/:id', [param('id').notEmpty()], validateRequest, getPlan);
router.post(
  '/',
  [body('name').trim().notEmpty().withMessage('Nome é obrigatório')],
  validateRequest,
  createPlan,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updatePlan);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deletePlan);

export default router;

