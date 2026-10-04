import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listClients(_req: Request, res: Response) {
  try {
    const clients = await prisma.client.findMany({ orderBy: { createdAt: 'desc' } });
    res.json(clients);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getClient(req: Request, res: Response) {
  try {
    const client = await prisma.client.findUnique({ where: { id: req.params.id } });
    if (!client) return res.status(404).json({ error: 'Cliente não encontrado' });
    res.json(client);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createClient(req: Request, res: Response) {
  try {
    const { name, phone, email, avatarUrl, nascimento, plano, observacoes, status } = req.body;
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Nome do cliente é obrigatório' });
    }
    const client = await prisma.client.create({
      data: {
        name: name.trim(),
        phone: phone?.trim() || null,
        email: email?.trim() || null,
        avatarUrl: avatarUrl?.trim() || null,
        nascimento: nascimento?.trim() || null,
        plano: plano?.trim() || 'Nenhum',
        observacoes: observacoes?.trim() || null,
        status: status || 'active',
      },
    });
    res.status(201).json(client);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateClient(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { name, phone, email, avatarUrl, nascimento, plano, observacoes, status, totalGasto, ultimaVisita } = req.body;
    const client = await prisma.client.update({
      where: { id },
      data: {
        ...(name !== undefined && { name: name.trim() }),
        ...(phone !== undefined && { phone: phone?.trim() || null }),
        ...(email !== undefined && { email: email?.trim() || null }),
        ...(avatarUrl !== undefined && { avatarUrl: avatarUrl?.trim() || null }),
        ...(nascimento !== undefined && { nascimento: nascimento?.trim() || null }),
        ...(plano !== undefined && { plano: plano?.trim() || 'Nenhum' }),
        ...(observacoes !== undefined && { observacoes: observacoes?.trim() || null }),
        ...(status !== undefined && { status }),
        ...(totalGasto !== undefined && { totalGasto: Number(totalGasto) }),
        ...(ultimaVisita !== undefined && { ultimaVisita }),
      },
    });
    res.json(client);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteClient(req: Request, res: Response) {
  try {
    await prisma.client.delete({ where: { id: req.params.id } });
    res.json({ message: 'Cliente removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}
