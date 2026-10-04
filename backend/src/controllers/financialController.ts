import { Request, Response } from 'express';
import { prisma } from '../app';

function formatDate(d: Date): string {
  return d.toISOString().split('T')[0];
}

function formatTime(d: Date): string {
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

// Transactions
export async function listTransactions(_req: Request, res: Response) {
  try {
    const transactions = await prisma.financialTransaction.findMany({
      orderBy: { date: 'desc' },
    });
    const formatted = transactions.map((t) => ({
      ...t,
      date: formatDate(new Date(t.date)),
    }));
    res.json(formatted);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createTransaction(req: Request, res: Response) {
  try {
    const { description, amount, type, category, date, paymentMethod, status } = req.body;
    if (!description || description.trim() === '') {
      return res.status(400).json({ error: 'Descrição é obrigatória' });
    }
    const amt = Number(amount);
    if (isNaN(amt) || amt <= 0) return res.status(400).json({ error: 'O valor da transação deve ser positivo' });

    const transaction = await prisma.financialTransaction.create({
      data: {
        description: description.trim(),
        amount: amt,
        type: type || 'Receita',
        category: category?.trim() || 'Serviços',
        date: date ? new Date(date) : new Date(),
        paymentMethod: paymentMethod || 'Pix',
        status: status || 'Confirmado',
      },
    });

    res.status(201).json({
      ...transaction,
      date: formatDate(new Date(transaction.date)),
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

// Financial Summary
export async function getSummary(_req: Request, res: Response) {
  try {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const transactions = await prisma.financialTransaction.findMany();
    const bills = await prisma.bill.findMany();

    let dailyRevenue = 0;
    let monthlyRevenue = 0;
    let monthlyExpenses = 0;

    for (const t of transactions) {
      const tDate = new Date(t.date);
      const isIncome = t.type.toLowerCase().includes('receita') || t.type.toLowerCase() === 'income';
      if (isIncome) {
        if (tDate >= startOfDay) dailyRevenue += t.amount;
        if (tDate >= startOfMonth) monthlyRevenue += t.amount;
      } else {
        if (tDate >= startOfMonth) monthlyExpenses += t.amount;
      }
    }

    // Include paid bills in monthly expenses
    for (const b of bills) {
      if (b.status === 'Pago' && new Date(b.dueDate) >= startOfMonth) {
        monthlyExpenses += b.amount;
      }
    }

    const commissionsDue = monthlyRevenue * 0.15;
    const netProfit = monthlyRevenue - monthlyExpenses - commissionsDue;

    res.json({
      dailyRevenue,
      monthlyRevenue,
      monthlyExpenses,
      commissionsDue,
      netProfit,
      revenueHistory: [
        { date: '03/07', value: 620.0 },
        { date: '04/07', value: 810.0 },
        { date: '05/07', value: 540.0 },
        { date: '06/07', value: 900.0 },
        { date: '07/07', value: 750.0 },
        { date: '08/07', value: 1150.0 },
        { date: 'Hoje', value: dailyRevenue > 0 ? dailyRevenue : 350.0 },
      ],
      expenseHistory: [
        { date: '03/07', value: 80.0 },
        { date: '04/07', value: 150.0 },
        { date: '05/07', value: 200.0 },
        { date: '06/07', value: 90.0 },
        { date: '07/07', value: 130.0 },
        { date: '08/07', value: 350.0 },
        { date: 'Hoje', value: monthlyExpenses > 0 ? monthlyExpenses / 10 : 80.0 },
      ],
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

// Bills
export async function listBills(_req: Request, res: Response) {
  try {
    const bills = await prisma.bill.findMany({
      orderBy: { dueDate: 'asc' },
    });
    const formatted = bills.map((b) => ({
      id: b.id,
      clientName: b.recipient || b.description,
      items: [
        {
          id: `item_${b.id}`,
          name: b.description,
          type: 'service',
          price: b.amount,
          quantity: 1,
        },
      ],
      status: b.status.toLowerCase() === 'pago' ? 'paid' : (b.status.toLowerCase() === 'cancelado' ? 'cancelled' : 'open'),
      payments: [],
      date: formatDate(new Date(b.dueDate)),
      time: formatTime(new Date(b.dueDate)),
      discount: 0.0,
    }));
    res.json(formatted);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createBill(req: Request, res: Response) {
  try {
    const { clientName, recipient, description, amount, dueDate, date, items, status } = req.body;
    const finalDesc = description || (items && items[0]?.name) || clientName || 'Comanda / Conta';
    const finalAmount = amount !== undefined ? Number(amount) : (items && items[0]?.price ? Number(items[0].price) : 0.0);

    const bill = await prisma.bill.create({
      data: {
        description: finalDesc,
        amount: finalAmount,
        dueDate: (dueDate || date) ? new Date(dueDate || date) : new Date(),
        category: 'Geral',
        status: status === 'paid' ? 'Pago' : 'Pendente',
        recipient: clientName || recipient || null,
      },
    });

    res.status(201).json({
      id: bill.id,
      clientName: bill.recipient || bill.description,
      items: items || [
        {
          id: `item_${bill.id}`,
          name: bill.description,
          type: 'service',
          price: bill.amount,
          quantity: 1,
        },
      ],
      status: bill.status.toLowerCase() === 'pago' ? 'paid' : 'open',
      payments: [],
      date: formatDate(new Date(bill.dueDate)),
      time: formatTime(new Date(bill.dueDate)),
      discount: 0.0,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateBill(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { clientName, recipient, description, amount, dueDate, date, items, status } = req.body;

    const data: any = {};
    if (description !== undefined) data.description = description.trim();
    if (clientName !== undefined || recipient !== undefined) data.recipient = clientName || recipient;
    if (amount !== undefined) data.amount = Number(amount);
    if (dueDate !== undefined || date !== undefined) data.dueDate = new Date(dueDate || date);
    if (status !== undefined) {
      data.status = status === 'paid' ? 'Pago' : (status === 'cancelled' ? 'Cancelado' : 'Pendente');
    }

    const bill = await prisma.bill.upsert({
      where: { id },
      update: data,
      create: {
        id,
        description: description || 'Comanda / Conta',
        amount: amount !== undefined ? Number(amount) : 0.0,
        dueDate: (dueDate || date) ? new Date(dueDate || date) : new Date(),
        category: 'Geral',
        status: status === 'paid' ? 'Pago' : 'Pendente',
        recipient: clientName || recipient || null,
      },
    });

    res.json({
      id: bill.id,
      clientName: bill.recipient || bill.description,
      items: items || [
        {
          id: `item_${bill.id}`,
          name: bill.description,
          type: 'service',
          price: bill.amount,
          quantity: 1,
        },
      ],
      status: bill.status.toLowerCase() === 'pago' ? 'paid' : 'open',
      payments: [],
      date: formatDate(new Date(bill.dueDate)),
      time: formatTime(new Date(bill.dueDate)),
      discount: 0.0,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteBill(req: Request, res: Response) {
  try {
    await prisma.bill.delete({ where: { id: req.params.id } });
    res.json({ message: 'Conta removida com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

// Cash Shifts
function formatShift(shift: any) {
  const openDate = new Date(shift.openedAt);
  const closeDate = shift.closedAt ? new Date(shift.closedAt) : null;
  return {
    id: shift.id,
    operatorName: 'Fábio Zvir',
    openDate: formatDate(openDate),
    openTime: formatTime(openDate),
    closeDate: closeDate ? formatDate(closeDate) : null,
    closeTime: closeDate ? formatTime(closeDate) : null,
    initialBalance: shift.initialAmount,
    totalExpected: shift.finalAmount || (shift.initialAmount + (shift.totalSales || 0)),
    totalReported: shift.finalAmount,
    status: shift.status === 'Aberto' ? 'open' : 'closed',
  };
}

export async function getActiveCashShift(_req: Request, res: Response) {
  try {
    const shift = await prisma.cashShift.findFirst({
      where: { status: 'Aberto' },
      orderBy: { openedAt: 'desc' },
    });
    if (!shift) return res.json(null);
    res.json(formatShift(shift));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function listCashShifts(_req: Request, res: Response) {
  try {
    const shifts = await prisma.cashShift.findMany({
      orderBy: { openedAt: 'desc' },
    });
    res.json(shifts.map(formatShift));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function openCashShift(req: Request, res: Response) {
  try {
    const { initialBalance, initialAmount } = req.body;
    const balance = initialBalance !== undefined ? Number(initialBalance) : (initialAmount !== undefined ? Number(initialAmount) : 0.0);

    const shift = await prisma.cashShift.create({
      data: {
        initialAmount: balance,
        status: 'Aberto',
      },
    });
    res.status(201).json(formatShift(shift));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function closeCashShift(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { finalBalance, reportedCash, finalAmount, totalSales, difference } = req.body;

    const rep = reportedCash !== undefined ? Number(reportedCash) : (finalAmount !== undefined ? Number(finalAmount) : Number(finalBalance || 0));

    let shiftId = id;
    if (!shiftId || shiftId === 'active') {
      const active = await prisma.cashShift.findFirst({ where: { status: 'Aberto' }, orderBy: { openedAt: 'desc' } });
      if (!active) return res.status(404).json({ error: 'Nenhum caixa aberto encontrado' });
      shiftId = active.id;
    }

    const shift = await prisma.cashShift.update({
      where: { id: shiftId },
      data: {
        closedAt: new Date(),
        finalAmount: rep,
        totalSales: totalSales !== undefined ? Number(totalSales) : 0.0,
        difference: difference !== undefined ? Number(difference) : 0.0,
        status: 'Fechado',
      },
    });
    res.json(formatShift(shift));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function addCashMovement(req: Request, res: Response) {
  try {
    const { cashShiftId, type, amount, description, time, user } = req.body;
    const numAmount = Number(amount);
    if (isNaN(numAmount) || numAmount <= 0) {
      return res.status(400).json({ error: 'O valor da movimentação deve ser maior que zero' });
    }

    const movement = await prisma.cashMovement.create({
      data: {
        cashShiftId: cashShiftId ? String(cashShiftId) : null,
        type: type === 'output' ? 'output' : 'input',
        amount: numAmount,
        description: description ? String(description).trim().slice(0, 255) : '',
        responsible: user ? String(user).trim().slice(0, 100) : 'Administrador',
        time: time || formatTime(new Date()),
      },
    });

    res.status(201).json({
      id: movement.id,
      cashShiftId: movement.cashShiftId,
      type: movement.type,
      amount: movement.amount,
      description: movement.description,
      time: movement.time,
      user: movement.responsible,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getCashMovements(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const movements = await prisma.cashMovement.findMany({
      where: { cashShiftId: id },
      orderBy: { createdAt: 'asc' },
    });

    res.json(
      movements.map((m) => ({
        id: m.id,
        cashShiftId: m.cashShiftId,
        type: m.type,
        amount: m.amount,
        description: m.description,
        time: m.time,
        user: m.responsible,
      })),
    );
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}


