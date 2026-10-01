"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listAppointments = listAppointments;
exports.createAppointment = createAppointment;
const app_1 = require("../app");
async function listAppointments(_req, res) {
    const appointments = await app_1.prisma.appointment.findMany({ orderBy: { startAt: 'asc' }, include: { client: true, service: true } });
    res.json(appointments);
}
async function createAppointment(req, res) {
    const { clientId, serviceId, startAt, endAt } = req.body;
    if (!clientId || !serviceId || !startAt || !endAt)
        return res.status(400).json({ error: 'missing fields' });
    const appt = await app_1.prisma.appointment.create({ data: { clientId, serviceId, startAt: new Date(startAt), endAt: new Date(endAt) } });
    res.status(201).json(appt);
}
