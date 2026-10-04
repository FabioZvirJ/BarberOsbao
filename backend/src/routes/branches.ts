import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listBranches,
  getBranch,
  createBranch,
  updateBranch,
  deleteBranch,
} from '../controllers/branchesController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', listBranches);
router.get('/:idOrSlug', [param('idOrSlug').notEmpty()], validateRequest, getBranch);
router.post(
  '/',
  [
    requireRole(['admin']),
    body('name').trim().notEmpty().withMessage('Nome da filial é obrigatório'),
    body('address').trim().notEmpty().withMessage('Endereço da filial é obrigatório'),
  ],
  validateRequest,
  createBranch,
);
router.put('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, updateBranch);
router.delete('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, deleteBranch);

export default router;
