"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listServices = listServices;
exports.getService = getService;
exports.createService = createService;
exports.updateService = updateService;
exports.updateServicesOrder = updateServicesOrder;
exports.deleteService = deleteService;
const app_1 = require("../app");
async function listServices(_req, res) {
    try {
        const services = await app_1.prisma.service.findMany({
            orderBy: [{ orderIndex: 'asc' }, { createdAt: 'desc' }],
        });
        res.json(services);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function getService(req, res) {
    try {
        const service = await app_1.prisma.service.findUnique({ where: { id: req.params.id } });
        if (!service)
            return res.status(404).json({ error: 'Serviço não encontrado' });
        res.json(service);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function createService(req, res) {
    try {
        const { name, title, category, description, price, durationMinutes, durationMin, imageUrl, colorHex, status, orderIndex, } = req.body;
        const serviceName = name || title;
        if (!serviceName || serviceName.trim() === '') {
            return res.status(400).json({ error: 'Nome do serviço é obrigatório' });
        }
        const finalPrice = price !== undefined ? Number(price) : 0.0;
        const finalDuration = durationMinutes !== undefined ? Number(durationMinutes) : (durationMin !== undefined ? Number(durationMin) : 30);
        const service = await app_1.prisma.service.create({
            data: {
                name: serviceName.trim(),
                category: category?.trim() || 'Geral',
                description: description?.trim() || null,
                price: finalPrice,
                durationMinutes: finalDuration,
                imageUrl: imageUrl?.trim() || null,
                colorHex: colorHex?.trim() || 'C89B3C',
                status: status !== undefined ? Boolean(status) : true,
                orderIndex: orderIndex !== undefined ? Number(orderIndex) : 0,
            },
        });
        res.status(201).json(service);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function updateService(req, res) {
    try {
        const { id } = req.params;
        const { name, title, category, description, price, durationMinutes, durationMin, imageUrl, colorHex, status, orderIndex, } = req.body;
        const data = {};
        const serviceName = name || title;
        if (serviceName !== undefined)
            data.name = serviceName.trim();
        if (category !== undefined)
            data.category = category.trim();
        if (description !== undefined)
            data.description = description?.trim() || null;
        if (price !== undefined)
            data.price = Number(price);
        if (durationMinutes !== undefined)
            data.durationMinutes = Number(durationMinutes);
        else if (durationMin !== undefined)
            data.durationMinutes = Number(durationMin);
        if (imageUrl !== undefined)
            data.imageUrl = imageUrl?.trim() || null;
        if (colorHex !== undefined)
            data.colorHex = colorHex.trim();
        if (status !== undefined)
            data.status = Boolean(status);
        if (orderIndex !== undefined)
            data.orderIndex = Number(orderIndex);
        const service = await app_1.prisma.service.update({
            where: { id },
            data,
        });
        res.json(service);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function updateServicesOrder(req, res) {
    try {
        const { services } = req.body;
        if (!Array.isArray(services)) {
            return res.status(400).json({ error: 'Array de serviços esperado' });
        }
        const updates = services.map((s, idx) => app_1.prisma.service.update({
            where: { id: s.id },
            data: { orderIndex: idx },
        }));
        await app_1.prisma.$transaction(updates);
        const updated = await app_1.prisma.service.findMany({
            orderBy: [{ orderIndex: 'asc' }, { createdAt: 'desc' }],
        });
        res.json(updated);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function deleteService(req, res) {
    try {
        await app_1.prisma.service.delete({ where: { id: req.params.id } });
        res.json({ message: 'Serviço removido com sucesso' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
