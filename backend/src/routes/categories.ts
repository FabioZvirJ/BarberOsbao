import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listCategories,
  createCategory,
  updateCategory,
  updateCategoriesOrder,
  deleteCategory,
} from '../controllers/categoriesController';
import { validateRequest } from '../middleware/validate';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', listCategories);
router.put('/reorder', requireRole(['admin']), updateCategoriesOrder);
router.post(
  '/',
  [
    requireRole(['admin']),
    body('name').trim().notEmpty().withMessage('Nome é obrigatório'),
  ],
  validateRequest,
  createCategory,
);
router.put('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, updateCategory);
router.delete('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, deleteCategory);

export default router;
