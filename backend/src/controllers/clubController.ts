import { Request, Response } from 'express';
import { prisma } from '../app';

function formatBenefit(b: any) {
  return {
    id: b.id,
    name: b.title,
    description: b.description || '',
    pointsRequired: Math.round((b.discountPercent || 0) * 10),
    benefitValue: `${b.discountPercent || 0}% OFF`,
    imageUrl: '',
    expirationDate: '2026-12-31',
    active: b.active !== undefined ? b.active : true,
  };
}

export async function listBenefits(_req: Request, res: Response) {
  try {
    const benefits = await prisma.clubBenefit.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(benefits.map(formatBenefit));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createBenefit(req: Request, res: Response) {
  try {
    const { title, name, description, discountPercent, pointsRequired, active } = req.body;
    const finalTitle = (title || name || '').trim();
    if (!finalTitle) {
      return res.status(400).json({ error: 'Título do benefício é obrigatório' });
    }

    const discount = discountPercent !== undefined ? Number(discountPercent) : (pointsRequired ? Number(pointsRequired) / 10 : 10.0);

    const benefit = await prisma.clubBenefit.create({
      data: {
        title: finalTitle,
        description: description?.trim() || '',
        discountPercent: discount,
        active: active !== undefined ? Boolean(active) : true,
      },
    });
    res.status(201).json(formatBenefit(benefit));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateBenefit(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { title, name, description, discountPercent, pointsRequired, active } = req.body;

    const data: any = {};
    if (title !== undefined || name !== undefined) data.title = (title || name).trim();
    if (description !== undefined) data.description = description.trim();
    if (discountPercent !== undefined) data.discountPercent = Number(discountPercent);
    else if (pointsRequired !== undefined) data.discountPercent = Number(pointsRequired) / 10;
    if (active !== undefined) data.active = Boolean(active);

    const benefit = await prisma.clubBenefit.update({
      where: { id },
      data,
    });
    res.json(formatBenefit(benefit));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteBenefit(req: Request, res: Response) {
  try {
    await prisma.clubBenefit.delete({ where: { id: req.params.id } });
    res.json({ message: 'Benefício removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function listMembers(_req: Request, res: Response) {
  try {
    const members = await prisma.clubMember.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(members);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createMember(req: Request, res: Response) {
  try {
    const { name, email, phone, tier, points, since, status } = req.body;
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Nome do membro é obrigatório' });
    }
    const member = await prisma.clubMember.create({
      data: {
        name: name.trim(),
        email: email?.trim() || null,
        phone: phone?.trim() || null,
        tier: tier || 'Silver',
        points: points !== undefined ? Number(points) : 0,
        since: since || new Date().toLocaleDateString('pt-BR'),
        status: status || 'active',
      },
    });
    res.status(201).json(member);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

