"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const appointmentsController_1 = require("../controllers/appointmentsController");
const validate_1 = require("../middleware/validate");
const router = (0, express_1.Router)();
router.get('/', appointmentsController_1.listAppointments);
router.get('/:id', [(0, express_validator_1.param)('id').notEmpty()], validate_1.validateRequest, appointmentsController_1.getAppointment);
router.post('/', [
    (0, express_validator_1.body)('clientName').trim().notEmpty().withMessage('Nome do cliente é obrigatório'),
    (0, express_validator_1.body)('barberName').trim().notEmpty().withMessage('Nome do barbeiro é obrigatório'),
    (0, express_validator_1.body)('serviceName').trim().notEmpty().withMessage('Serviço é obrigatório'),
    (0, express_validator_1.body)('dateTime').notEmpty().withMessage('Data e hora são obrigatórios'),
], validate_1.validateRequest, appointmentsController_1.createAppointment);
router.put('/:id', [(0, express_validator_1.param)('id').notEmpty()], validate_1.validateRequest, appointmentsController_1.updateAppointment);
router.delete('/:id', [(0, express_validator_1.param)('id').notEmpty()], validate_1.validateRequest, appointmentsController_1.deleteAppointment);
exports.default = router;
