import { Router } from 'express';
import { body } from 'express-validator';
import { listClients, createClient } from '../controllers/clientsController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listClients);
router.post('/', [body('name').notEmpty().withMessage('name is required')], validateRequest, createClient);

export default router;
