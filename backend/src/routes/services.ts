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

const router = Router();

router.get('/', listServices);
router.put('/reorder', updateServicesOrder);
router.get('/:id', [param('id').notEmpty()], validateRequest, getService);
router.post(
  '/',
  [
    body('price').isNumeric().withMessage('Preço deve ser numérico'),
  ],
  validateRequest,
  createService,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateService);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteService);

export default router;
