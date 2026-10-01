import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listServices(_req: Request, res: Response) {
  const services = await prisma.service.findMany({ orderBy: { title: 'asc' } });
  res.json(services);
}

export async function getService(req: Request, res: Response) {
  const { id } = req.params;
  const service = await prisma.service.findUnique({ where: { id } });
  if (!service) return res.status(404).json({ error: 'not found' });
  res.json(service);
}

export async function createService(req: Request, res: Response) {
  const { title, price, durationMin } = req.body;
  if (!title || price == null || durationMin == null) return res.status(400).json({ error: 'missing fields' });
  const s = await prisma.service.create({ data: { title, price: Number(price), durationMin: Number(durationMin) } });
  res.status(201).json(s);
}

export async function updateService(req: Request, res: Response) {
  const { id } = req.params;
  const { title, price, durationMin } = req.body;
  const exists = await prisma.service.findUnique({ where: { id } });
  if (!exists) return res.status(404).json({ error: 'not found' });
  const updated = await prisma.service.update({ where: { id }, data: { title: title ?? exists.title, price: price != null ? Number(price) : exists.price, durationMin: durationMin != null ? Number(durationMin) : exists.durationMin } });
  res.json(updated);
}

export async function deleteService(req: Request, res: Response) {
  const { id } = req.params;
  const exists = await prisma.service.findUnique({ where: { id } });
  if (!exists) return res.status(404).json({ error: 'not found' });
  await prisma.service.delete({ where: { id } });
  res.status(204).send();
}
