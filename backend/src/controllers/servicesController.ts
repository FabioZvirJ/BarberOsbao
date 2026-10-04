import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listServices(req: Request, res: Response) {
  try {
    const { branchId } = req.query;
    const services = await prisma.service.findMany({
      where: branchId ? { OR: [{ branchId: String(branchId) }, { branchId: null }] } : undefined,
      include: { branch: true },
      orderBy: [{ orderIndex: 'asc' }, { createdAt: 'desc' }],
    });
    res.json(services);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getService(req: Request, res: Response) {
  try {
    const service = await prisma.service.findUnique({ where: { id: req.params.id } });
    if (!service) return res.status(404).json({ error: 'Serviço não encontrado' });
    res.json(service);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createService(req: Request, res: Response) {
  try {
    const {
      name,
      title,
      category,
      description,
      price,
      durationMinutes,
      durationMin,
      imageUrl,
      colorHex,
      status,
      orderIndex,
    } = req.body;

    const serviceName = name || title;
    if (!serviceName || serviceName.trim() === '') {
      return res.status(400).json({ error: 'Nome do serviço é obrigatório' });
    }
    const finalPrice = price !== undefined ? Number(price) : 0.0;
    const finalDuration = durationMinutes !== undefined ? Number(durationMinutes) : (durationMin !== undefined ? Number(durationMin) : 30);

    const service = await prisma.service.create({
      data: {
        name: serviceName.trim(),
        category: category?.trim() || 'Geral',
        description: description?.trim() || null,
        price: finalPrice,
        durationMinutes: finalDuration,
        imageUrl: imageUrl?.trim() || null,
        colorHex: colorHex?.trim() || 'C89B3C',
        status: status !== undefined ? Boolean(status) : true,
        orderIndex: orderIndex !== undefined ? Number(orderIndex) : 0,
        branchId: req.body.branchId || null,
      },
    });

    res.status(201).json(service);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateService(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const {
      name,
      title,
      category,
      description,
      price,
      durationMinutes,
      durationMin,
      imageUrl,
      colorHex,
      status,
      orderIndex,
    } = req.body;

    const data: any = {};
    const serviceName = name || title;
    if (serviceName !== undefined) data.name = serviceName.trim();
    if (category !== undefined) data.category = category.trim();
    if (description !== undefined) data.description = description?.trim() || null;
    if (price !== undefined) data.price = Number(price);
    if (durationMinutes !== undefined) data.durationMinutes = Number(durationMinutes);
    else if (durationMin !== undefined) data.durationMinutes = Number(durationMin);
    if (imageUrl !== undefined) data.imageUrl = imageUrl?.trim() || null;
    if (colorHex !== undefined) data.colorHex = colorHex.trim();
    if (status !== undefined) data.status = Boolean(status);
    if (orderIndex !== undefined) data.orderIndex = Number(orderIndex);
    if (req.body.branchId !== undefined) data.branchId = req.body.branchId || null;

    const service = await prisma.service.update({
      where: { id },
      data,
    });

    res.json(service);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateServicesOrder(req: Request, res: Response) {
  try {
    const { services } = req.body;
    if (!Array.isArray(services)) {
      return res.status(400).json({ error: 'Array de serviços esperado' });
    }

    const updates = services.map((s: any, idx: number) =>
      prisma.service.update({
        where: { id: s.id },
        data: { orderIndex: idx },
      }),
    );
    await prisma.$transaction(updates);

    const updated = await prisma.service.findMany({
      orderBy: [{ orderIndex: 'asc' }, { createdAt: 'desc' }],
    });
    res.json(updated);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteService(req: Request, res: Response) {
  try {
    await prisma.service.delete({ where: { id: req.params.id } });
    res.json({ message: 'Serviço removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}
