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

const router = Router();

router.get('/', listCategories);
router.put('/reorder', updateCategoriesOrder);
router.post(
  '/',
  [body('name').trim().notEmpty().withMessage('Nome é obrigatório')],
  validateRequest,
  createCategory,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateCategory);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteCategory);

export default router;

