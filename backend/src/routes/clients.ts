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
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// Todas as rotas de clientes exigem autenticação
router.use(requireAuth);

router.get('/', listClients);
router.get('/:id', [param('id').notEmpty()], validateRequest, getClient);
router.post(
  '/',
  [body('name').trim().notEmpty().withMessage('Nome é obrigatório')],
  validateRequest,
  createClient,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateClient);
router.delete('/:id', [param('id').notEmpty()], validateRequest, requireRole(['admin']), deleteClient);

export default router;
