import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listAppointments(_req: Request, res: Response) {
  const appointments = await prisma.appointment.findMany({ orderBy: { startAt: 'asc' }, include: { client: true, service: true } });
  res.json(appointments);
}

export async function createAppointment(req: Request, res: Response) {
  const { clientId, serviceId, startAt, endAt } = req.body;
  if (!clientId || !serviceId || !startAt || !endAt) return res.status(400).json({ error: 'missing fields' });
  const appt = await prisma.appointment.create({ data: { clientId, serviceId, startAt: new Date(startAt), endAt: new Date(endAt) } });
  res.status(201).json(appt);
}
