import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listServices,
  getService,
  createService,
  updateService,
  updateServicesOrder,
  deleteService,
} from '../controllers/servicesController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// Rotas públicas (Clientes podem ver a lista e detalhes de serviços)
router.get('/', listServices);
router.get('/:id', [param('id').notEmpty()], validateRequest, getService);

// Rotas administrativas (Apenas administradores podem cadastrar, reordenar ou editar serviços)
router.use(requireAuth);
router.put('/reorder', requireRole(['admin']), updateServicesOrder);
router.post(
  '/',
  [
    requireRole(['admin']),
    body('name').trim().notEmpty().withMessage('Nome é obrigatório'),
    body('price').isFloat({ min: 0 }).withMessage('Preço deve ser um número positivo'),
  ],
  validateRequest,
  createService,
);
router.put('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, updateService);
router.delete('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, deleteService);

export default router;
