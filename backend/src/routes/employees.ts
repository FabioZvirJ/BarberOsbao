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
import { optionalAuth, requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// Rotas públicas (Clientes podem ver a lista de barbeiros/funcionários da unidade)
router.get('/', optionalAuth, listEmployees);
router.get('/:id', [param('id').notEmpty()], validateRequest, optionalAuth, getEmployee);

// Rotas administrativas (Apenas administradores podem cadastrar ou editar funcionários)
router.use(requireAuth);
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
