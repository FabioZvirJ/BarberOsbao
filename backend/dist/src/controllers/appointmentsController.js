"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listAppointments = listAppointments;
exports.getAppointment = getAppointment;
exports.createAppointment = createAppointment;
exports.updateAppointment = updateAppointment;
exports.deleteAppointment = deleteAppointment;
const app_1 = require("../app");
function formatAppointment(appt) {
    const dt = new Date(appt.dateTime);
    const dateStr = !isNaN(dt.getTime()) ? dt.toISOString().split('T')[0] : '';
    const timeStr = !isNaN(dt.getTime()) ? `${String(dt.getHours()).padStart(2, '0')}:${String(dt.getMinutes()).padStart(2, '0')}` : '';
    return {
        ...appt,
        services: appt.serviceName,
        date: dateStr,
        time: timeStr,
    };
}
async function listAppointments(_req, res) {
    try {
        const appointments = await app_1.prisma.appointment.findMany({
            orderBy: { dateTime: 'desc' },
        });
        res.json(appointments.map(formatAppointment));
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function getAppointment(req, res) {
    try {
        const appointment = await app_1.prisma.appointment.findUnique({
            where: { id: req.params.id },
        });
        if (!appointment)
            return res.status(404).json({ error: 'Agendamento não encontrado' });
        res.json(formatAppointment(appointment));
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function createAppointment(req, res) {
    try {
        const { clientName, clientPhone, clientAvatar, barberName, barberAvatar, serviceName, services, dateTime, date, time, price, status, notes, } = req.body;
        const finalServiceName = (serviceName || services || '').trim();
        if (!clientName || clientName.trim() === '') {
            return res.status(400).json({ error: 'Nome do cliente é obrigatório' });
        }
        if (!barberName || barberName.trim() === '') {
            return res.status(400).json({ error: 'Nome do profissional é obrigatório' });
        }
        if (!finalServiceName) {
            return res.status(400).json({ error: 'Serviço é obrigatório' });
        }
        let resolvedDateTime = null;
        if (dateTime) {
            resolvedDateTime = new Date(dateTime);
        }
        else if (date && time) {
            resolvedDateTime = new Date(`${date}T${time}:00`);
        }
        if (!resolvedDateTime || isNaN(resolvedDateTime.getTime())) {
            return res.status(400).json({ error: 'Data e hora são obrigatórios e válidos' });
        }
        const appointment = await app_1.prisma.appointment.create({
            data: {
                clientName: clientName.trim(),
                clientPhone: clientPhone?.trim() || null,
                clientAvatar: clientAvatar?.trim() || null,
                barberName: barberName.trim(),
                barberAvatar: barberAvatar?.trim() || null,
                serviceName: finalServiceName,
                dateTime: resolvedDateTime,
                price: price !== undefined ? Number(price) : 0.0,
                status: status || 'Pendente',
                notes: notes?.trim() || null,
            },
        });
        res.status(201).json(formatAppointment(appointment));
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function updateAppointment(req, res) {
    try {
        const { id } = req.params;
        const { clientName, clientPhone, clientAvatar, barberName, barberAvatar, serviceName, services, dateTime, date, time, price, status, notes, } = req.body;
        const data = {};
        if (clientName !== undefined)
            data.clientName = clientName.trim();
        if (clientPhone !== undefined)
            data.clientPhone = clientPhone?.trim() || null;
        if (clientAvatar !== undefined)
            data.clientAvatar = clientAvatar?.trim() || null;
        if (barberName !== undefined)
            data.barberName = barberName.trim();
        if (barberAvatar !== undefined)
            data.barberAvatar = barberAvatar?.trim() || null;
        if (serviceName !== undefined || services !== undefined) {
            data.serviceName = (serviceName || services).trim();
        }
        if (dateTime !== undefined) {
            data.dateTime = new Date(dateTime);
        }
        else if (date !== undefined && time !== undefined) {
            data.dateTime = new Date(`${date}T${time}:00`);
        }
        if (price !== undefined)
            data.price = Number(price);
        if (status !== undefined)
            data.status = status;
        if (notes !== undefined)
            data.notes = notes?.trim() || null;
        const appointment = await app_1.prisma.appointment.update({
            where: { id },
            data,
        });
        res.json(formatAppointment(appointment));
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
async function deleteAppointment(req, res) {
    try {
        await app_1.prisma.appointment.delete({ where: { id: req.params.id } });
        res.json({ message: 'Agendamento removido com sucesso' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
