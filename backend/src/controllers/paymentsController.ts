import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listPayments(_req: Request, res: Response) {
  const payments = await prisma.financialTransaction.findMany({ orderBy: { createdAt: 'desc' } });
  res.json(payments);
}

export async function getPayment(req: Request, res: Response) {
  const { id } = req.params;
  const payment = await prisma.financialTransaction.findUnique({ where: { id } });
  if (!payment) return res.status(404).json({ error: 'not found' });
  res.json(payment);
}

export async function createPayment(req: Request, res: Response) {
  const { description, amount, method, type } = req.body;
  if (!description || amount == null) return res.status(400).json({ error: 'missing fields' });
  const p = await prisma.financialTransaction.create({
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

