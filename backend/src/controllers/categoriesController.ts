import { Request, Response } from 'express';
import { prisma } from '../app';

function formatCategory(c: any) {
  return {
    ...c,
    nome: c.name,
    tipo: c.iconName || 'servicos',
  };
}

export async function listCategories(_req: Request, res: Response) {
  try {
    const categories = await prisma.category.findMany({
      orderBy: [{ orderIndex: 'asc' }, { createdAt: 'desc' }],
    });
    res.json(categories.map(formatCategory));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createCategory(req: Request, res: Response) {
  try {
    const { name, nome, iconName, tipo, colorHex, active, orderIndex } = req.body;
    const finalName = (name || nome || '').trim();
    if (!finalName) {
      return res.status(400).json({ error: 'Nome da categoria é obrigatório' });
    }

    const category = await prisma.category.create({
      data: {
        name: finalName,
        iconName: (iconName || tipo)?.trim() || null,
        colorHex: colorHex?.trim() || 'C89B3C',
        active: active !== undefined ? Boolean(active) : true,
        orderIndex: orderIndex !== undefined ? Number(orderIndex) : 0,
      },
    });

    res.status(201).json(formatCategory(category));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateCategory(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { name, nome, iconName, tipo, colorHex, active, orderIndex } = req.body;

    const data: any = {};
    if (name !== undefined || nome !== undefined) data.name = (name || nome).trim();
    if (iconName !== undefined || tipo !== undefined) data.iconName = (iconName || tipo)?.trim() || null;
    if (colorHex !== undefined) data.colorHex = colorHex.trim();
    if (active !== undefined) data.active = Boolean(active);
    if (orderIndex !== undefined) data.orderIndex = Number(orderIndex);

    const category = await prisma.category.update({
      where: { id },
      data,
    });

    res.json(formatCategory(category));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateCategoriesOrder(req: Request, res: Response) {
  try {
    const { categories } = req.body;
    if (!Array.isArray(categories)) {
      return res.status(400).json({ error: 'Array de categorias esperado' });
    }

    const updates = categories.map((c: any, idx: number) =>
      prisma.category.update({
        where: { id: c.id },
        data: { orderIndex: idx },
      }),
    );
    await prisma.$transaction(updates);

    const updated = await prisma.category.findMany({
      orderBy: [{ orderIndex: 'asc' }, { createdAt: 'desc' }],
    });
    res.json(updated);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteCategory(req: Request, res: Response) {
  try {
    await prisma.category.delete({ where: { id: req.params.id } });
    res.json({ message: 'Categoria removida com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

