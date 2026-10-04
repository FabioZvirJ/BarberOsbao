import { Response } from 'express';

export function handleSafeError(res: Response, error: any, defaultMessage: string = 'Erro interno no servidor') {
  console.error('[API Error]:', error?.message || error);
  if (process.env.NODE_ENV === 'development') {
    return res.status(500).json({ error: error?.message || defaultMessage });
  }
  return res.status(500).json({ error: defaultMessage });
}
