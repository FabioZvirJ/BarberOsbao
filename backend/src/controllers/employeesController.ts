import { Request, Response } from 'express';
import { prisma } from '../app';

function serializeEmployee(emp: any) {
  return {
    ...emp,
    specialties: typeof emp.specialties === 'string' ? JSON.parse(emp.specialties || '[]') : emp.specialties,
    diasDisponiveis: typeof emp.diasDisponiveis === 'string' ? JSON.parse(emp.diasDisponiveis || '[]') : emp.diasDisponiveis,
    folgas: typeof emp.folgas === 'string' ? JSON.parse(emp.folgas || '[]') : emp.folgas,
  };
}

export async function listEmployees(req: Request, res: Response) {
  try {
    const { branchId } = req.query;
    const employees = await prisma.employee.findMany({
      where: branchId ? { branchId: String(branchId) } : undefined,
      include: { branch: true },
      orderBy: { createdAt: 'desc' },
    });
    res.json(employees.map(serializeEmployee));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getEmployee(req: Request, res: Response) {
  try {
    const employee = await prisma.employee.findUnique({ where: { id: req.params.id } });
    if (!employee) return res.status(404).json({ error: 'Funcionário não encontrado' });
    res.json(serializeEmployee(employee));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createEmployee(req: Request, res: Response) {
  try {
    const {
      name,
      avatarUrl,
      cargo,
      phone,
      email,
      cpf,
      specialties,
      commissionRate,
      horarioTrabalho,
      diasDisponiveis,
      folgas,
      status,
      rating,
    } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Nome do funcionário é obrigatório' });
    }
    if (!cargo || cargo.trim() === '') {
      return res.status(400).json({ error: 'Cargo é obrigatório' });
    }

    const employee = await prisma.employee.create({
      data: {
        name: name.trim(),
        avatarUrl: avatarUrl?.trim() || null,
        cargo: cargo.trim(),
        phone: phone?.trim() || null,
        email: email?.trim() || null,
        cpf: cpf?.trim() || null,
        specialties: JSON.stringify(Array.isArray(specialties) ? specialties : []),
        commissionRate: commissionRate !== undefined ? Number(commissionRate) : 0.3,
        horarioTrabalho: horarioTrabalho?.trim() || null,
        diasDisponiveis: JSON.stringify(Array.isArray(diasDisponiveis) ? diasDisponiveis : []),
        folgas: JSON.stringify(Array.isArray(folgas) ? folgas : []),
        status: status !== undefined ? Boolean(status) : true,
        rating: rating !== undefined ? Number(rating) : 5.0,
        branchId: req.body.branchId || null,
      },
    });

    res.status(201).json(serializeEmployee(employee));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateEmployee(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const {
      name,
      avatarUrl,
      cargo,
      phone,
      email,
      cpf,
      specialties,
      commissionRate,
      horarioTrabalho,
      diasDisponiveis,
      folgas,
      status,
      rating,
    } = req.body;

    const data: any = {};
    if (name !== undefined) data.name = name.trim();
    if (avatarUrl !== undefined) data.avatarUrl = avatarUrl?.trim() || null;
    if (cargo !== undefined) data.cargo = cargo.trim();
    if (phone !== undefined) data.phone = phone?.trim() || null;
    if (email !== undefined) data.email = email?.trim() || null;
    if (cpf !== undefined) data.cpf = cpf?.trim() || null;
    if (specialties !== undefined) {
      data.specialties = JSON.stringify(Array.isArray(specialties) ? specialties : []);
    }
    if (commissionRate !== undefined) data.commissionRate = Number(commissionRate);
    if (horarioTrabalho !== undefined) data.horarioTrabalho = horarioTrabalho?.trim() || null;
    if (diasDisponiveis !== undefined) {
      data.diasDisponiveis = JSON.stringify(Array.isArray(diasDisponiveis) ? diasDisponiveis : []);
    }
    if (folgas !== undefined) {
      data.folgas = JSON.stringify(Array.isArray(folgas) ? folgas : []);
    }
    if (status !== undefined) data.status = Boolean(status);
    if (rating !== undefined) data.rating = Number(rating);
    if (req.body.branchId !== undefined) data.branchId = req.body.branchId || null;

    const employee = await prisma.employee.update({
      where: { id },
      data,
    });

    res.json(serializeEmployee(employee));
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteEmployee(req: Request, res: Response) {
  try {
    await prisma.employee.delete({ where: { id: req.params.id } });
    res.json({ message: 'Funcionário removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

