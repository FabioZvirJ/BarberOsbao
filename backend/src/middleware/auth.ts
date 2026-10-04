import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export function getJwtSecret(): string {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret === 'secret') {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('FATAL: JWT_SECRET must be securely configured with at least 32 characters in production.');
    }
    return 'dev_super_secret_jwt_key_barber_osbao_2026_minimum_32_chars';
  }
  return secret;
}

export interface AuthPayload {
  userId: string;
  email: string;
  role: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthPayload;
    }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Token de autenticação não fornecido' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ error: 'Formato de token inválido. Esperado: Bearer <token>' });
  }

  const token = parts[1];
  try {
    const payload = jwt.verify(token, getJwtSecret(), {
      algorithms: ['HS256'],
    }) as AuthPayload;

    req.user = payload;
    next();
  } catch (err: any) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expirado. Por favor, faça login novamente.' });
    }
    return res.status(401).json({ error: 'Token inválido ou não autorizado' });
  }
}

export function requireRole(allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Acesso negado: privilégios insuficientes' });
    }
    next();
  };
}
