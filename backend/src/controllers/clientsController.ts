import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listClients(_req: Request, res: Response) {
  const clients = await prisma.client.findMany({ orderBy: { createdAt: 'desc' } });
  res.json(clients);
}

export async function createClient(req: Request, res: Response) {
  const { name, phone, email } = req.body;
  if (!name) return res.status(400).json({ error: 'name required' });
  const client = await prisma.client.create({ data: { name, phone, email } });
  res.status(201).json(client);
}
