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

router.use(requireAuth);

router.get('/', listServices);
router.put('/reorder', requireRole(['admin']), updateServicesOrder);
router.get('/:id', [param('id').notEmpty()], validateRequest, getService);
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
