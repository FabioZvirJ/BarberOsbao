import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listEmployees,
  getEmployee,
  createEmployee,
  updateEmployee,
  deleteEmployee,
} from '../controllers/employeesController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', listEmployees);
router.get('/:id', [param('id').notEmpty()], validateRequest, getEmployee);
router.post(
  '/',
  [
    requireRole(['admin']),
    body('name').trim().notEmpty().withMessage('Nome é obrigatório'),
    body('cargo').trim().notEmpty().withMessage('Cargo é obrigatório'),
  ],
  validateRequest,
  createEmployee,
);
router.put('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, updateEmployee);
router.delete('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, deleteEmployee);

export default router;
