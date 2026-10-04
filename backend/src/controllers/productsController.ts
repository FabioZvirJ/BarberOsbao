import { Request, Response } from 'express';
import { prisma } from '../app';

export async function listProducts(_req: Request, res: Response) {
  try {
    const products = await prisma.product.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(products);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getProduct(req: Request, res: Response) {
  try {
    const product = await prisma.product.findUnique({ where: { id: req.params.id } });
    if (!product) return res.status(404).json({ error: 'Produto não encontrado' });
    res.json(product);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createProduct(req: Request, res: Response) {
  try {
    const {
      name,
      brand,
      category,
      supplier,
      code,
      costPrice,
      price,
      stock,
      minStock,
      description,
      status,
      imageUrl,
    } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Nome do produto é obrigatório' });
    }

    const product = await prisma.product.create({
      data: {
        name: name.trim(),
        brand: brand?.trim() || null,
        category: category?.trim() || 'Geral',
        supplier: supplier?.trim() || null,
        code: code?.trim() || null,
        costPrice: costPrice !== undefined ? Number(costPrice) : 0.0,
        price: price !== undefined ? Number(price) : 0.0,
        stock: stock !== undefined ? Number(stock) : 0,
        minStock: minStock !== undefined ? Number(minStock) : 0,
        description: description?.trim() || null,
        status: status !== undefined ? Boolean(status) : true,
        imageUrl: imageUrl?.trim() || null,
      },
    });

    res.status(201).json(product);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateProduct(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const {
      name,
      brand,
      category,
      supplier,
      code,
      costPrice,
      price,
      stock,
      minStock,
      description,
      status,
      imageUrl,
    } = req.body;

    const data: any = {};
    if (name !== undefined) data.name = name.trim();
    if (brand !== undefined) data.brand = brand?.trim() || null;
    if (category !== undefined) data.category = category.trim();
    if (supplier !== undefined) data.supplier = supplier?.trim() || null;
    if (code !== undefined) data.code = code?.trim() || null;
    if (costPrice !== undefined) data.costPrice = Number(costPrice);
    if (price !== undefined) data.price = Number(price);
    if (stock !== undefined) data.stock = Number(stock);
    if (minStock !== undefined) data.minStock = Number(minStock);
    if (description !== undefined) data.description = description?.trim() || null;
    if (status !== undefined) data.status = Boolean(status);
    if (imageUrl !== undefined) data.imageUrl = imageUrl?.trim() || null;

    const product = await prisma.product.update({
      where: { id },
      data,
    });

    res.json(product);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteProduct(req: Request, res: Response) {
  try {
    await prisma.product.delete({ where: { id: req.params.id } });
    res.json({ message: 'Produto removido com sucesso' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function listStockMovements(_req: Request, res: Response) {
  try {
    const movements = await prisma.stockMovement.findMany({
      orderBy: { createdAt: 'desc' },
    });
    res.json(movements);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createStockMovement(req: Request, res: Response) {
  try {
    const { productId, productName, type, quantity, reason, responsible } = req.body;

    if (!productId) return res.status(400).json({ error: 'productId é obrigatório' });
    const qty = Number(quantity);
    if (isNaN(qty) || qty <= 0) return res.status(400).json({ error: 'Quantidade deve ser maior que 0' });

    const product = await prisma.product.findUnique({ where: { id: productId } });
    if (!product) return res.status(404).json({ error: 'Produto não encontrado' });

    let newStock = product.stock;
    if (type === 'Entrada') {
      newStock += qty;
    } else if (type === 'Saída') {
      newStock = Math.max(0, newStock - qty);
    } else if (type === 'Inventário') {
      newStock = qty;
    }

    const todayStr = new Date().toLocaleDateString('pt-BR');

    const [movement] = await prisma.$transaction([
      prisma.stockMovement.create({
        data: {
          productId,
          productName: productName || product.name,
          type: type || 'Entrada',
          quantity: qty,
          reason: reason?.trim() || null,
          date: todayStr,
          responsible: responsible?.trim() || 'Sistema / Usuário',
        },
      }),
      prisma.product.update({
        where: { id: productId },
        data: { stock: newStock },
      }),
    ]);

    res.status(201).json(movement);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

