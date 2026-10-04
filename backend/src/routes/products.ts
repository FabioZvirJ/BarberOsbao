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
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/', listProducts);
router.get('/movements', listStockMovements);
router.post(
  '/movements',
  [
    requireRole(['admin']),
    body('productId').trim().notEmpty().withMessage('ID do produto é obrigatório'),
    body('quantity').isInt({ min: 1 }).withMessage('Quantidade deve ser um número inteiro positivo maior que zero'),
  ],
  validateRequest,
  createStockMovement,
);
router.get('/:id', [param('id').notEmpty()], validateRequest, getProduct);
router.post(
  '/',
  [
    requireRole(['admin']),
    body('name').trim().notEmpty().withMessage('Nome é obrigatório'),
    body('price').isFloat({ min: 0 }).withMessage('Preço deve ser um número positivo'),
  ],
  validateRequest,
  createProduct,
);
router.put('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, updateProduct);
router.delete('/:id', [param('id').notEmpty(), requireRole(['admin'])], validateRequest, deleteProduct);

export default router;
