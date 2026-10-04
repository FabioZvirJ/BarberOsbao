import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listUsers,
  getUser,
  createUser,
  updateUser,
  deleteUser,
} from '../controllers/usersController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// Apenas administradores podem gerenciar usuários do sistema
router.use(requireAuth);
router.use(requireRole(['admin']));

router.get('/', listUsers);
router.get('/:id', [param('id').notEmpty()], validateRequest, getUser);

router.post(
  '/',
  [
    body('name').trim().isLength({ min: 2 }).withMessage('Nome deve ter no mínimo 2 caracteres'),
    body('email').trim().isEmail().withMessage('E-mail informado é inválido'),
    body('password').isLength({ min: 6 }).withMessage('A senha deve ter no mínimo 6 caracteres'),
    body('role').optional().isIn(['admin', 'barber', 'client']).withMessage('Perfil deve ser admin, barber ou client'),
  ],
  validateRequest,
  createUser,
);

router.put(
  '/:id',
  [
    param('id').notEmpty(),
    body('name').optional().trim().isLength({ min: 2 }).withMessage('Nome deve ter no mínimo 2 caracteres'),
    body('email').optional().trim().isEmail().withMessage('E-mail informado é inválido'),
    body('password').optional().isLength({ min: 6 }).withMessage('A senha deve ter no mínimo 6 caracteres'),
    body('role').optional().isIn(['admin', 'barber', 'client']).withMessage('Perfil deve ser admin, barber ou client'),
  ],
  validateRequest,
  updateUser,
);

router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteUser);

export default router;

