import { Router } from 'express';
import { body, param } from 'express-validator';
import { listServices, getService, createService, updateService, deleteService } from '../controllers/servicesController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listServices);
router.get('/:id', [param('id').notEmpty()], validateRequest, getService);
router.post('/', [body('title').notEmpty().withMessage('title required'), body('price').isNumeric().withMessage('price numeric'), body('durationMin').isInt().withMessage('durationMin integer')], validateRequest, createService);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateService);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteService);

export default router;
