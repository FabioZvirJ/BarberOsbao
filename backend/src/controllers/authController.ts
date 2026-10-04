import { Request, Response } from 'express';
import { prisma } from '../app';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { getJwtSecret } from '../middleware/auth';

function sanitizeUser(user: any) {
  return {
    id: user.id,
    email: user.email,
    name: user.name || 'Usuário',
    phone: user.phone || '',
    role: user.role || 'client',
    avatarUrl: user.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
    createdAt: user.createdAt,
  };
}

function generateToken(user: any): string {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role || 'client',
    },
    getJwtSecret(),
    {
      algorithm: 'HS256',
      expiresIn: '7d',
    },
  );
}

// 1. Registro tradicional (Email + Senha)
export async function register(req: Request, res: Response) {
  try {
    const { email, password, name, phone, role } = req.body;

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return res.status(400).json({ error: 'E-mail válido é obrigatório' });
    }
    if (!password || typeof password !== 'string' || password.length < 6) {
      return res.status(400).json({ error: 'Senha deve conter no mínimo 6 caracteres' });
    }

    const cleanEmail = email.trim().toLowerCase();
    const cleanName = (name || '').trim().slice(0, 100);
    const cleanPhone = (phone || '').trim().slice(0, 30);

    // Evita escalada de privilégios não autorizada
    // Contas criadas publicamente são sempre 'client'
    const assignedRole = role === 'admin' ? 'client' : (role || 'client');

    const existingUser = await prisma.user.findUnique({
      where: { email: cleanEmail },
    });

    if (existingUser) {
      return res.status(409).json({ error: 'Já existe uma conta cadastrada com este e-mail' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        email: cleanEmail,
        password: hashedPassword,
        name: cleanName || 'Novo Cliente',
        phone: cleanPhone,
        role: assignedRole,
      },
    });

    const token = generateToken(user);
    res.status(201).json({
      token,
      user: sanitizeUser(user),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Erro ao registrar usuário' });
  }
}

// 2. Login tradicional (Email + Senha)
export async function login(req: Request, res: Response) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'E-mail e senha são obrigatórios' });
    }

    const cleanEmail = email.trim().toLowerCase();

    const user = await prisma.user.findUnique({
      where: { email: cleanEmail },
    });

    if (!user) {
      return res.status(401).json({ error: 'E-mail ou senha incorretos' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'E-mail ou senha incorretos' });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: sanitizeUser(user),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Erro ao realizar login' });
  }
}

// 3. Login com Google (OAuth)
export async function googleLogin(req: Request, res: Response) {
  try {
    const { email, name, avatarUrl } = req.body;

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return res.status(400).json({ error: 'Dados da conta Google inválidos' });
    }

    const cleanEmail = email.trim().toLowerCase();
    const cleanName = (name || '').trim().slice(0, 100);
    const cleanAvatar = avatarUrl && typeof avatarUrl === 'string' ? avatarUrl.trim() : null;

    let user = await prisma.user.findUnique({
      where: { email: cleanEmail },
    });

    if (!user) {
      // Cria nova conta associada ao Google
      const randomPassword = await bcrypt.hash(`google_${Date.now()}_${Math.random()}`, 10);
      user = await prisma.user.create({
        data: {
          email: cleanEmail,
          password: randomPassword,
          name: cleanName || 'Usuário Google',
          avatarUrl: cleanAvatar,
          role: 'client',
        },
      });
    } else if (cleanAvatar && !user.avatarUrl) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { avatarUrl: cleanAvatar },
      });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: sanitizeUser(user),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Erro ao autenticar com Google' });
  }
}

// 4. Login com Celular / WhatsApp
export async function phoneLogin(req: Request, res: Response) {
  try {
    const { phone, name } = req.body;

    if (!phone || typeof phone !== 'string') {
      return res.status(400).json({ error: 'Número de telefone é obrigatório' });
    }

    const cleanDigits = phone.replace(/\D/g, '');
    if (cleanDigits.length < 10) {
      return res.status(400).json({ error: 'Número de celular inválido' });
    }

    const phoneEmail = `cel_${cleanDigits}@phone.barberosbao.com.br`;

    let user = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: cleanDigits },
          { email: phoneEmail },
        ],
      },
    });

    if (!user) {
      const randomPassword = await bcrypt.hash(`phone_${cleanDigits}_${Date.now()}`, 10);
      user = await prisma.user.create({
        data: {
          email: phoneEmail,
          phone: cleanDigits,
          password: randomPassword,
          name: (name || '').trim().slice(0, 100) || `Cliente (${cleanDigits.slice(-4)})`,
          role: 'client',
        },
      });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: sanitizeUser(user),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Erro ao autenticar por celular' });
  }
}

// 5. Acesso Rápido / Convidado
export async function guestLogin(req: Request, res: Response) {
  try {
    const guestId = Date.now().toString(36) + Math.random().toString(36).substring(2, 6);
    const guestEmail = `guest_${guestId}@guest.barberosbao.com.br`;
    const randomPassword = await bcrypt.hash(`guest_${guestId}`, 10);
    const clientName = (req.body?.name || '').trim().slice(0, 100) || 'Cliente Convidado';

    const user = await prisma.user.create({
      data: {
        email: guestEmail,
        password: randomPassword,
        name: clientName,
        role: 'client',
      },
    });

    const token = generateToken(user);
    res.json({
      token,
      user: sanitizeUser(user),
    });
  } catch (error: any) {
    res.status(500).json({ error: 'Erro ao gerar acesso de convidado' });
  }
}

// 6. Perfil autenticado (/auth/me)
export async function me(req: Request, res: Response) {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ error: 'Não autenticado' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ error: 'Usuário não encontrado' });
    }

    res.json(sanitizeUser(user));
  } catch (error: any) {
    res.status(500).json({ error: 'Erro ao buscar perfil' });
  }
}
