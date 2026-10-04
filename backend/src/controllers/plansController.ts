import { Request, Response } from 'express';
import { prisma } from '../app';

function serializePlan(plan: any) {
  return {
    ...plan,
    benefits: typeof plan.benefits === 'string' ? JSON.parse(plan.benefits || '[]') : plan.benefits,
  };
}

export async function listPlans(_req: Request, res: Response) {
  try {
    const plans = await prisma.plan.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(plans.map(serializePlan));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getPlan(req: Request, res: Response) {
  try {
    const plan = await prisma.plan.findUnique({ where: { id: req.params.id } });
    if (!plan) return res.status(404).json({ error: 'Plano não encontrado' });
    res.json(serializePlan(plan));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createPlan(req: Request, res: Response) {
  try {
    const {
      name,
      price,
      period,
      benefits,
      cutsCount,
      productDiscount,
      status,
      recommended,
    } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Nome do plano é obrigatório' });
    }

    const plan = await prisma.plan.create({
      data: {
        name: name.trim(),
        price: price !== undefined ? Number(price) : 0.0,
        period: period?.trim() || 'mensal',
        benefits: JSON.stringify(Array.isArray(benefits) ? benefits : []),
        cutsCount: cutsCount !== undefined ? Number(cutsCount) : 4,
        productDiscount: productDiscount !== undefined ? Number(productDiscount) : 0.0,
        status: status !== undefined ? Boolean(status) : true,
        recommended: recommended !== undefined ? Boolean(recommended) : false,
      },
    });

    res.status(201).json(serializePlan(plan));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updatePlan(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const {
      name,
      price,
      period,
      benefits,
      cutsCount,
      productDiscount,
      status,
      recommended,
    } = req.body;

    const data: any = {};
    if (name !== undefined) data.name = name.trim();
    if (price !== undefined) data.price = Number(price);
    if (period !== undefined) data.period = period.trim();
    if (benefits !== undefined) {
      data.benefits = JSON.stringify(Array.isArray(benefits) ? benefits : []);
    }
    if (cutsCount !== undefined) data.cutsCount = Number(cutsCount);
    if (productDiscount !== undefined) data.productDiscount = Number(productDiscount);
    if (status !== undefined) data.status = Boolean(status);
    if (recommended !== undefined) data.recommended = Boolean(recommended);

    const plan = await prisma.plan.update({
      where: { id },
      data,
    });

    res.json(serializePlan(plan));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deletePlan(req: Request, res: Response) {
  try {
    await prisma.plan.delete({ where: { id: req.params.id } });
    res.json({ message: 'Plano removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

