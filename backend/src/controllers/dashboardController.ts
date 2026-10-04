import { Request, Response } from 'express';
import { prisma } from '../app';

export async function getDashboardMetrics(_req: Request, res: Response) {
  try {
    const [
      totalClients,
      totalAppointments,
      appointments,
      transactions,
      products,
      plans,
    ] = await Promise.all([
      prisma.client.count({ where: { status: 'active' } }),
      prisma.appointment.count(),
      prisma.appointment.findMany({
        orderBy: { dateTime: 'desc' },
        take: 10,
      }),
      prisma.financialTransaction.findMany(),
      prisma.product.findMany(),
      prisma.plan.findMany(),
    ]);

    // Calculate revenue from completed appointments and transactions
    const totalRevenue = transactions
      .filter((t) => t.type === 'Receita')
      .reduce((acc, t) => acc + t.amount, 0);

    const totalExpenses = transactions
      .filter((t) => t.type === 'Despesa')
      .reduce((acc, t) => acc + t.amount, 0);

    // Products low stock
    const lowStockCount = products.filter((p) => p.stock <= p.minStock).length;

    // Today's appointments
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);

    const todayAppointmentsCount = await prisma.appointment.count({
      where: {
        dateTime: {
          gte: startOfDay,
          lte: endOfDay,
        },
      },
    });

    res.json({
      totalRevenue,
      dailyRevenue: totalRevenue,
      netProfit: totalRevenue - totalExpenses,
      totalAppointments,
      todayAppointments: todayAppointmentsCount,
      appointmentsTodayCount: todayAppointmentsCount,
      totalClients,
      newClientsCount: totalClients,
      averageRating: 4.9,
      lowStockProducts: lowStockCount,
      activePlans: plans.filter((p) => p.status).length,
      recentAppointments: appointments,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

