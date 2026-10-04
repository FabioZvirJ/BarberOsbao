import { Router } from 'express';
import { body, param } from 'express-validator';
import {
  listAppointments,
  getAppointment,
  createAppointment,
  updateAppointment,
  deleteAppointment,
} from '../controllers/appointmentsController';
import { validateRequest } from '../middleware/validate';

const router = Router();

router.get('/', listAppointments);
router.get('/:id', [param('id').notEmpty()], validateRequest, getAppointment);
router.post(
  '/',
  [
    body('clientName').trim().notEmpty().withMessage('Nome do cliente é obrigatório'),
    body('barberName').trim().notEmpty().withMessage('Nome do barbeiro é obrigatório'),
    body('serviceName').trim().notEmpty().withMessage('Serviço é obrigatório'),
    body('dateTime').notEmpty().withMessage('Data e hora são obrigatórios'),
  ],
  validateRequest,
  createAppointment,
);
router.put('/:id', [param('id').notEmpty()], validateRequest, updateAppointment);
router.delete('/:id', [param('id').notEmpty()], validateRequest, deleteAppointment);

export default router;
