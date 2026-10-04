"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const servicesController_1 = require("../controllers/servicesController");
const validate_1 = require("../middleware/validate");
const router = (0, express_1.Router)();
router.get('/', servicesController_1.listServices);
router.put('/reorder', servicesController_1.updateServicesOrder);
router.get('/:id', [(0, express_validator_1.param)('id').notEmpty()], validate_1.validateRequest, servicesController_1.getService);
router.post('/', [
    (0, express_validator_1.body)('price').isNumeric().withMessage('Preço deve ser numérico'),
], validate_1.validateRequest, servicesController_1.createService);
router.put('/:id', [(0, express_validator_1.param)('id').notEmpty()], validate_1.validateRequest, servicesController_1.updateService);
router.delete('/:id', [(0, express_validator_1.param)('id').notEmpty()], validate_1.validateRequest, servicesController_1.deleteService);
exports.default = router;
