"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listClients = listClients;
exports.createClient = createClient;
const app_1 = require("../app");
async function listClients(_req, res) {
    const clients = await app_1.prisma.client.findMany({ orderBy: { createdAt: 'desc' } });
    res.json(clients);
}
async function createClient(req, res) {
    const { name, phone, email } = req.body;
    if (!name)
        return res.status(400).json({ error: 'name required' });
    const client = await app_1.prisma.client.create({ data: { name, phone, email } });
    res.status(201).json(client);
}
