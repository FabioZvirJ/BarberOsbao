"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listClients = listClients;
exports.getClient = getClient;
exports.createClient = createClient;
exports.updateClient = updateClient;
exports.deleteClient = deleteClient;
const app_1 = require("../app");
async function listClients(_req, res) {
    try {
        const clients = await app_1.prisma.client.findMany({ orderBy: { createdAt: 'desc' } });
        res.json(clients);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function getClient(req, res) {
    try {
        const client = await app_1.prisma.client.findUnique({ where: { id: req.params.id } });
        if (!client)
            return res.status(404).json({ error: 'Cliente não encontrado' });
        res.json(client);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function createClient(req, res) {
    try {
        const { name, phone, email, avatarUrl, nascimento, plano, observacoes, status } = req.body;
        if (!name || name.trim() === '') {
            return res.status(400).json({ error: 'Nome do cliente é obrigatório' });
        }
        const client = await app_1.prisma.client.create({
            data: {
                name: name.trim(),
                phone: phone?.trim() || null,
                email: email?.trim() || null,
                avatarUrl: avatarUrl?.trim() || null,
                nascimento: nascimento?.trim() || null,
                plano: plano?.trim() || 'Nenhum',
                observacoes: observacoes?.trim() || null,
                status: status || 'active',
            },
        });
        res.status(201).json(client);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function updateClient(req, res) {
    try {
        const { id } = req.params;
        const { name, phone, email, avatarUrl, nascimento, plano, observacoes, status, totalGasto, ultimaVisita } = req.body;
        const client = await app_1.prisma.client.update({
            where: { id },
            data: {
                ...(name !== undefined && { name: name.trim() }),
                ...(phone !== undefined && { phone: phone?.trim() || null }),
                ...(email !== undefined && { email: email?.trim() || null }),
                ...(avatarUrl !== undefined && { avatarUrl: avatarUrl?.trim() || null }),
                ...(nascimento !== undefined && { nascimento: nascimento?.trim() || null }),
                ...(plano !== undefined && { plano: plano?.trim() || 'Nenhum' }),
                ...(observacoes !== undefined && { observacoes: observacoes?.trim() || null }),
                ...(status !== undefined && { status }),
                ...(totalGasto !== undefined && { totalGasto: Number(totalGasto) }),
                ...(ultimaVisita !== undefined && { ultimaVisita }),
            },
        });
        res.json(client);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function deleteClient(req, res) {
    try {
        await app_1.prisma.client.delete({ where: { id: req.params.id } });
        res.json({ message: 'Cliente removido com sucesso' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
