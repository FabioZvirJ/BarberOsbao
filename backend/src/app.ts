import express from 'express';
const cors = require('cors');
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
app.use(cors());
app.use(express.json());

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

app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.get('/', (_req, res) => res.json({ ok: true }));

export default app;

