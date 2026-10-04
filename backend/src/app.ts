import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';
import authRoutes from './routes/auth';
import clientsRoutes from './routes/clients';
import appointmentsRoutes from './routes/appointments';
import servicesRoutes from './routes/services';
import paymentsRoutes from './routes/payments';
import employeesRoutes from './routes/employees';
import categoriesRoutes from './routes/categories';
import productsRoutes from './routes/products';
import plansRoutes from './routes/plans';
import financialRoutes from './routes/financial';
import dashboardRoutes from './routes/dashboard';
import clubRoutes from './routes/club';
const swaggerUi = require('swagger-ui-express');
import swaggerSpec from './swagger';

dotenv.config();

export const prisma = new PrismaClient();

const app = express();

// 1. Desabilitar identificação do servidor e habilitar proxy reverso confiável (Render/Cloudflare)
app.disable('x-powered-by');
app.set('trust proxy', 1);

// 2. Proteção de Headers HTTP (Helmet)
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  }),
);

// 3. Limitação de Tamanho de Payload (Anti-DoS)
app.use(express.json({ limit: '2mb' }));

// 4. Configuração Estrita de CORS (Sem bypasses de *.github.io ou includes(localhost))
const allowedOrigins = [
  'https://fabiozvirj.github.io',
  'http://localhost:3000',
  'http://localhost:8080',
  'http://localhost:5000',
  'http://127.0.0.1:3000',
  'http://127.0.0.1:8080',
];
if (process.env.CORS_ORIGIN) {
  allowedOrigins.push(process.env.CORS_ORIGIN.trim());
}

app.use(
  cors({
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
      // Permite requisições mobile e CLI/scripts autorizados (sem cabeçalho Origin)
      if (!origin) return callback(null, true);

      // Verificação exata da lista autorizada
      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }

      // Em ambiente de desenvolvimento local, permite portas de loopback
      if (
        process.env.NODE_ENV !== 'production' &&
        /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)
      ) {
        return callback(null, true);
      }

      return callback(new Error('Bloqueado pela política de CORS'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);

// 5. Rate Limiting Geral (Anti-Flood / Anti-DoS)
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 500, // máx 500 requisições por IP a cada 15 min
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Muitas requisições originadas deste IP, tente novamente mais tarde.' },
});
app.use(apiLimiter);

// 6. Rate Limiting Específico para Autenticação (Anti-Brute Force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20, // máx 20 tentativas de login/registro a cada 15 min
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Muitas tentativas de autenticação. Tente novamente em 15 minutos.' },
});
app.use('/auth', authLimiter);

// 7. Registro de Rotas
app.use('/auth', authRoutes);
app.use('/clients', clientsRoutes);
app.use('/appointments', appointmentsRoutes);
app.use('/services', servicesRoutes);
app.use('/employees', employeesRoutes);
app.use('/categories', categoriesRoutes);
app.use('/products', productsRoutes);
app.use('/plans', plansRoutes);
app.use('/financial', financialRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/club', clubRoutes);
app.use('/payments', paymentsRoutes);

// 8. Documentação Swagger apenas em ambiente não-produção
if (process.env.NODE_ENV !== 'production') {
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

// 9. Healthcheck
app.get('/', (_req, res) => res.json({ status: 'healthy', timestamp: new Date().toISOString() }));

// 10. Tratador Global de Erros (Evita vazamento de stacktrace e SQL)
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('[Unhandled Error]:', err);
  res.status(500).json({ error: 'Erro interno no servidor' });
});

export default app;
