import { Router } from 'express';
import { getDashboardMetrics } from '../controllers/dashboardController';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

// Métricas de faturamento e desempenho restritas a administradores
router.use(requireAuth);
router.use(requireRole(['admin']));

router.get('/metrics', getDashboardMetrics);

export default router;
