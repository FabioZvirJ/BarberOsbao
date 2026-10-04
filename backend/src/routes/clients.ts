import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listClients,
  getClient,
  createClient,
  updateClient,
  deleteClient,
} from '../controllers/clientsController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listClients);
router.get('/:id', [param('id').notEmpty()], validateRequest, getClient);
router.post(
  '/',
  [body('name').trim().notEmpty().withMessage('Nome é obrigatório')],
  validateRequest,
  createClient,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateClient);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteClient);

export default router;
