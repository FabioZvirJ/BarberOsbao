import { Router } from 'express';
import { getDashboardMetrics } from '../controllers/dashboardController';

const router = Router();

router.get('/metrics', getDashboardMetrics);

export default router;

