"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listServices = listServices;
exports.getService = getService;
exports.createService = createService;
exports.updateService = updateService;
exports.deleteService = deleteService;
const app_1 = require("../app");
async function listServices(_req, res) {
    const services = await app_1.prisma.service.findMany({ orderBy: { title: 'asc' } });
    res.json(services);
}
async function getService(req, res) {
    const { id } = req.params;
    const service = await app_1.prisma.service.findUnique({ where: { id } });
    if (!service)
        return res.status(404).json({ error: 'not found' });
    res.json(service);
}
async function createService(req, res) {
    const { title, price, durationMin } = req.body;
    if (!title || price == null || durationMin == null)
        return res.status(400).json({ error: 'missing fields' });
    const s = await app_1.prisma.service.create({ data: { title, price: Number(price), durationMin: Number(durationMin) } });
    res.status(201).json(s);
}
async function updateService(req, res) {
    const { id } = req.params;
    const { title, price, durationMin } = req.body;
    const exists = await app_1.prisma.service.findUnique({ where: { id } });
    if (!exists)
        return res.status(404).json({ error: 'not found' });
    const updated = await app_1.prisma.service.update({ where: { id }, data: { title: title ?? exists.title, price: price != null ? Number(price) : exists.price, durationMin: durationMin != null ? Number(durationMin) : exists.durationMin } });
    res.json(updated);
}
async function deleteService(req, res) {
    const { id } = req.params;
    const exists = await app_1.prisma.service.findUnique({ where: { id } });
    if (!exists)
        return res.status(404).json({ error: 'not found' });
    await app_1.prisma.service.delete({ where: { id } });
    res.status(204).send();
}
