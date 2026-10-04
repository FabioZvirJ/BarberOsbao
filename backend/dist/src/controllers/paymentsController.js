"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listPayments = listPayments;
exports.getPayment = getPayment;
exports.createPayment = createPayment;
const app_1 = require("../app");
async function listPayments(_req, res) {
    const payments = await app_1.prisma.financialTransaction.findMany({ orderBy: { createdAt: 'desc' } });
    res.json(payments);
}
async function getPayment(req, res) {
    const { id } = req.params;
    const payment = await app_1.prisma.financialTransaction.findUnique({ where: { id } });
    if (!payment)
        return res.status(404).json({ error: 'not found' });
    res.json(payment);
}
async function createPayment(req, res) {
    const { description, amount, method, type } = req.body;
    if (!description || amount == null)
        return res.status(400).json({ error: 'missing fields' });
    const p = await app_1.prisma.financialTransaction.create({
        data: {
            description,
            amount: Number(amount),
            paymentMethod: method || 'Pix',
            type: type || 'Receita',
            category: 'Serviço',
        }
    });
    res.status(201).json(p);
}
