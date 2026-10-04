import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listProducts,
  getProduct,
  createProduct,
  updateProduct,
  deleteProduct,
  listStockMovements,
  createStockMovement,
} from '../controllers/productsController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listProducts);
router.get('/movements', listStockMovements);
router.post(
  '/movements',
  [
    body('productId').trim().notEmpty().withMessage('ID do produto é obrigatório'),
    body('quantity').isInt({ min: 1 }).withMessage('Quantidade deve ser um número inteiro positivo maior que zero'),
  ],
  validateRequest,
  createStockMovement,
);
router.get('/:id', [param('id').notEmpty()], validateRequest, getProduct);
router.post(
  '/',
  [body('name').trim().notEmpty().withMessage('Nome é obrigatório')],
  validateRequest,
  createProduct,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateProduct);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteProduct);

export default router;

