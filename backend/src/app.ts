import express from 'express';
const cors = require('cors');
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';
import authRoutes from './routes/auth';
import clientsRoutes from './routes/clients';
import appointmentsRoutes from './routes/appointments';
import servicesRoutes from './routes/services';
import paymentsRoutes from './routes/payments';
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
app.use('/payments', paymentsRoutes);

app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.get('/', (_req, res) => res.json({ ok: true }));

export default app;
