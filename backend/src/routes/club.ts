import { Router } from 'express';
import {
  listBenefits,
  createBenefit,
  updateBenefit,
  deleteBenefit,
  listMembers,
  createMember,
} from '../controllers/clubController';
import { requireAuth, requireRole } from '../middleware/auth';

const router = Router();

router.use(requireAuth);

router.get('/benefits', listBenefits);
router.post('/benefits', requireRole(['admin']), createBenefit);
router.put('/benefits/:id', requireRole(['admin']), updateBenefit);
router.delete('/benefits/:id', requireRole(['admin']), deleteBenefit);

router.get('/members', listMembers);
router.post('/members', createMember);

export default router;
