import { Router } from 'express';
import { body } from 'express-validator';
import { listAppointments, createAppointment } from '../controllers/appointmentsController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listAppointments);
router.post('/', [body('clientId').notEmpty(), body('serviceId').notEmpty(), body('startAt').notEmpty(), body('endAt').notEmpty()], validateRequest, createAppointment);

export default router;
