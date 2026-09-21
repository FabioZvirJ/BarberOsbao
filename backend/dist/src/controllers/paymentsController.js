"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listPayments = listPayments;
exports.getPayment = getPayment;
exports.createPayment = createPayment;
const app_1 = require("../app");
async function listPayments(_req, res) {
    const payments = await app_1.prisma.payment.findMany({ orderBy: { createdAt: 'desc' }, include: { appointment: { include: { client: true, service: true } } } });
    res.json(payments);
}
async function getPayment(req, res) {
    const { id } = req.params;
    const payment = await app_1.prisma.payment.findUnique({ where: { id }, include: { appointment: { include: { client: true, service: true } } } });
    if (!payment)
        return res.status(404).json({ error: 'not found' });
    res.json(payment);
}
async function createPayment(req, res) {
    const { appointmentId, amount, method } = req.body;
    if (!appointmentId || amount == null)
        return res.status(400).json({ error: 'missing fields' });
    // ensure appointment exists
    const appt = await app_1.prisma.appointment.findUnique({ where: { id: appointmentId } });
    if (!appt)
        return res.status(400).json({ error: 'appointment not found' });
    const p = await app_1.prisma.payment.create({ data: { appointmentId, amount: Number(amount), method } });
    res.status(201).json(p);
}
