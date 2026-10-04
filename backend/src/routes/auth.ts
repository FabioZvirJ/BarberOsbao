import { Router } from 'express';
import { register, login, googleLogin, phoneLogin, guestLogin, me } from '../controllers/authController';
import { requireAuth } from '../middleware/auth';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);
router.post('/phone', phoneLogin);
router.post('/guest', guestLogin);
router.get('/me', requireAuth, me);

export default router;
