import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listPayments(_req: Request, res: Response) {
  const payments = await prisma.payment.findMany({ orderBy: { createdAt: 'desc' }, include: { appointment: { include: { client: true, service: true } } } });
  res.json(payments);
}

export async function getPayment(req: Request, res: Response) {
  const { id } = req.params;
  const payment = await prisma.payment.findUnique({ where: { id }, include: { appointment: { include: { client: true, service: true } } } });
  if (!payment) return res.status(404).json({ error: 'not found' });
  res.json(payment);
}

export async function createPayment(req: Request, res: Response) {
  const { appointmentId, amount, method } = req.body;
  if (!appointmentId || amount == null) return res.status(400).json({ error: 'missing fields' });
  // ensure appointment exists
  const appt = await prisma.appointment.findUnique({ where: { id: appointmentId } });
  if (!appt) return res.status(400).json({ error: 'appointment not found' });
  const p = await prisma.payment.create({ data: { appointmentId, amount: Number(amount), method } });
  res.status(201).json(p);
}
