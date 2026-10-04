import { Router } from 'express';
import {
  listBenefits,
  createBenefit,
  updateBenefit,
  deleteBenefit,
  listMembers,
  createMember,
} from '../controllers/clubController';

const router = Router();

router.get('/benefits', listBenefits);
router.post('/benefits', createBenefit);
router.put('/benefits/:id', updateBenefit);
router.delete('/benefits/:id', deleteBenefit);

router.get('/members', listMembers);
router.post('/members', createMember);

export default router;

