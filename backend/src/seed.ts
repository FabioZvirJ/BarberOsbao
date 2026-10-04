import { prisma } from './app';

async function main() {
  console.log('Seeding...');
  const services = [
    { name: 'Corte Clássico', price: 35.0, durationMinutes: 30, category: 'Cabelo', colorHex: 'C89B3C', orderIndex: 0 },
    { name: 'Barba Terapia', price: 25.0, durationMinutes: 20, category: 'Barba', colorHex: 'C89B3C', orderIndex: 1 },
    { name: 'Corte + Barba', price: 55.0, durationMinutes: 50, category: 'Combos', colorHex: 'C89B3C', orderIndex: 2 }
  ];

  for (const s of services) {
    const exists = await prisma.service.findFirst({ where: { name: s.name } });
    if (!exists) await prisma.service.create({ data: s });
  }

  let client = await prisma.client.findFirst({ where: { email: 'cliente@exemplo.com' } });
  if (!client) {
    client = await prisma.client.create({
      data: {
        name: 'Cliente Demo',
        email: 'cliente@exemplo.com',
        phone: '(11) 99999-9999',
        status: 'active'
      }
    });
  }

  const service = await prisma.service.findFirst();
  if (service && client) {
    const apptExists = await prisma.appointment.findFirst({ where: { clientName: client.name } });
    if (!apptExists) {
      await prisma.appointment.create({
        data: {
          clientName: client.name,
          clientPhone: client.phone,
          barberName: 'Barbeiro Principal',
          serviceName: service.name,
          dateTime: new Date(),
          price: service.price,
          status: 'Confirmado'
        }
      });
    }
  }

  console.log('Seeding finished');
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
