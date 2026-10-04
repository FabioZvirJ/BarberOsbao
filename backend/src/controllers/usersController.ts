import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../app';

function sanitizeUser(user: any) {
  return {
    id: user.id,
    email: user.email,
    name: user.name || 'Sem nome',
    phone: user.phone || '',
    role: user.role || 'client',
    avatarUrl: user.avatarUrl || null,
    createdAt: user.createdAt,
  };
}

export async function listUsers(req: Request, res: Response) {
  try {
    const { role, search } = req.query;

    const where: any = {};
    if (role && typeof role === 'string' && role !== 'all') {
      where.role = role.toLowerCase();
    }
    if (search && typeof search === 'string' && search.trim()) {
      const q = search.trim().toLowerCase();
      where.OR = [
        { name: { contains: q, mode: 'insensitive' } },
        { email: { contains: q, mode: 'insensitive' } },
        { phone: { contains: q, mode: 'insensitive' } },
      ];
    }

    const users = await prisma.user.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });

    res.json(users.map(sanitizeUser));
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao listar usuários' });
  }
}

export async function getUser(req: Request, res: Response) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
    });
    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }
    res.json(sanitizeUser(user));
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao buscar usuário' });
  }
}

export async function createUser(req: Request, res: Response) {
  try {
    const { name, email, password, phone, role, avatarUrl } = req.body;

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return res.status(400).json({ error: 'E-mail válido é obrigatório' });
    }
    if (!password || typeof password !== 'string' || password.length < 6) {
      return res.status(400).json({ error: 'A senha deve conter no mínimo 6 caracteres' });
    }
    if (!name || typeof name !== 'string' || name.trim().length < 2) {
      return res.status(400).json({ error: 'Nome do usuário deve ter pelo menos 2 caracteres' });
    }

    const cleanEmail = email.trim().toLowerCase();
    const cleanName = name.trim();
    const cleanPhone = (phone || '').trim();
    const validRoles = ['admin', 'barber', 'client'];
    const assignedRole = validRoles.includes((role || '').toLowerCase())
      ? role.toLowerCase()
      : 'client';

    const existing = await prisma.user.findUnique({
      where: { email: cleanEmail },
    });
    if (existing) {
      return res.status(409).json({ error: 'Este e-mail já está cadastrado no sistema' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        name: cleanName,
        email: cleanEmail,
        password: hashedPassword,
        phone: cleanPhone || null,
        role: assignedRole,
        avatarUrl: avatarUrl ? String(avatarUrl).trim() : null,
      },
    });

    res.status(201).json(sanitizeUser(user));
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao criar usuário' });
  }
}

export async function updateUser(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { name, email, password, phone, role, avatarUrl } = req.body;

    const existing = await prisma.user.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    const updateData: any = {};

    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim().length < 2) {
        return res.status(400).json({ error: 'Nome inválido' });
      }
      updateData.name = name.trim();
    }

    if (email !== undefined) {
      const cleanEmail = email.trim().toLowerCase();
      if (!cleanEmail.includes('@')) {
        return res.status(400).json({ error: 'E-mail inválido' });
      }
      if (cleanEmail !== existing.email) {
        const emailTaken = await prisma.user.findUnique({ where: { email: cleanEmail } });
        if (emailTaken) {
          return res.status(409).json({ error: 'Este e-mail já está em uso por outro usuário' });
        }
      }
      updateData.email = cleanEmail;
    }

    if (password) {
      if (typeof password !== 'string' || password.length < 6) {
        return res.status(400).json({ error: 'A nova senha deve ter no mínimo 6 caracteres' });
      }
      updateData.password = await bcrypt.hash(password, 10);
    }

    if (phone !== undefined) {
      updateData.phone = phone ? String(phone).trim() : null;
    }

    if (role !== undefined) {
      const validRoles = ['admin', 'barber', 'client'];
      if (!validRoles.includes(role.toLowerCase())) {
        return res.status(400).json({ error: 'Perfil (role) inválido' });
      }
      updateData.role = role.toLowerCase();
    }

    if (avatarUrl !== undefined) {
      updateData.avatarUrl = avatarUrl ? String(avatarUrl).trim() : null;
    }

    const updated = await prisma.user.update({
      where: { id },
      data: updateData,
    });

    res.json(sanitizeUser(updated));
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao atualizar usuário' });
  }
}

export async function deleteUser(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const currentUserId = req.user?.userId;

    if (id === currentUserId) {
      return res.status(400).json({ error: 'Você não pode excluir sua própria conta de administrador' });
    }

    const existing = await prisma.user.findUnique({ where: { id } });
    if (!existing) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    await prisma.user.delete({ where: { id } });
    res.json({ message: 'Usuário removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Erro ao remover usuário' });
  }
}

