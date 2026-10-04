import { Request, Response } from 'express';
import { prisma } from '../app';

function generateSlug(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)+/g, '');
}

export async function listBranches(req: Request, res: Response) {
  try {
    const isAdmin = req.user?.role === 'admin';
    const branches = await prisma.branch.findMany({
      where: isAdmin ? undefined : { active: true },
      orderBy: { createdAt: 'asc' },
      include: {
        _count: {
          select: {
            employees: true,
            services: true,
          },
        },
      },
    });

    res.json(branches);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao listar filiais' });
  }
}

export async function getBranch(req: Request, res: Response) {
  try {
    const { idOrSlug } = req.params;

    const branch = await prisma.branch.findFirst({
      where: {
        OR: [{ id: idOrSlug }, { slug: idOrSlug }],
      },
      include: {
        employees: {
          where: { status: true },
        },
        services: {
          where: { status: true },
        },
      },
    });

    if (!branch) {
      return res.status(404).json({ error: 'Filial não encontrada' });
    }

    res.json(branch);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao buscar filial' });
  }
}

export async function createBranch(req: Request, res: Response) {
  try {
    const { name, slug, address, neighborhood, city, state, phone, avatarUrl } = req.body;

    if (!name || typeof name !== 'string' || name.trim() === '') {
      return res.status(400).json({ error: 'Nome da filial é obrigatório' });
    }

    if (!address || typeof address !== 'string' || address.trim() === '') {
      return res.status(400).json({ error: 'Endereço da filial é obrigatório' });
    }

    let finalSlug = slug ? generateSlug(slug) : generateSlug(name);
    if (!finalSlug) {
      finalSlug = `unidade-${Date.now()}`;
    }

    const existingSlug = await prisma.branch.findUnique({
      where: { slug: finalSlug },
    });

    if (existingSlug) {
      finalSlug = `${finalSlug}-${Date.now().toString().slice(-4)}`;
    }

    const branch = await prisma.branch.create({
      data: {
        name: name.trim(),
        slug: finalSlug,
        address: address.trim(),
        neighborhood: neighborhood ? String(neighborhood).trim() : null,
        city: city ? String(city).trim() : 'Mallet',
        state: state ? String(state).trim().toUpperCase() : 'PR',
        phone: phone ? String(phone).trim() : null,
        avatarUrl: avatarUrl ? String(avatarUrl).trim() : null,
        active: true,
      },
    });

    res.status(201).json(branch);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao criar filial' });
  }
}

export async function updateBranch(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { name, slug, address, neighborhood, city, state, phone, avatarUrl, active } = req.body;

    const exists = await prisma.branch.findUnique({ where: { id } });
    if (!exists) {
      return res.status(404).json({ error: 'Filial não encontrada' });
    }

    let updatedSlug = exists.slug;
    if (slug && slug !== exists.slug) {
      updatedSlug = generateSlug(slug);
      const slugClash = await prisma.branch.findUnique({ where: { slug: updatedSlug } });
      if (slugClash && slugClash.id !== id) {
        return res.status(409).json({ error: 'Este link/slug já está em uso por outra filial' });
      }
    }

    const updated = await prisma.branch.update({
      where: { id },
      data: {
        name: name !== undefined ? String(name).trim() : undefined,
        slug: updatedSlug,
        address: address !== undefined ? String(address).trim() : undefined,
        neighborhood: neighborhood !== undefined ? String(neighborhood).trim() : undefined,
        city: city !== undefined ? String(city).trim() : undefined,
        state: state !== undefined ? String(state).trim().toUpperCase() : undefined,
        phone: phone !== undefined ? String(phone).trim() : undefined,
        avatarUrl: avatarUrl !== undefined ? String(avatarUrl).trim() : undefined,
        active: active !== undefined ? Boolean(active) : undefined,
      },
    });

    res.json(updated);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao atualizar filial' });
  }
}

export async function deleteBranch(req: Request, res: Response) {
  try {
    const { id } = req.params;

    const exists = await prisma.branch.findUnique({ where: { id } });
    if (!exists) {
      return res.status(404).json({ error: 'Filial não encontrada' });
    }

    // Desativa a filial de forma segura (Soft Delete)
    await prisma.branch.update({
      where: { id },
      data: { active: false },
    });

    res.json({ message: 'Filial desativada com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao desativar filial' });
  }
}
