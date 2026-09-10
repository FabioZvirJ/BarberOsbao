import { prisma } from './app';

async function main() {
  console.log('Seeding...');
  const services = [
    { title: 'Corte Clássico', price: 35.0, durationMin: 30 },
    { title: 'Barba', price: 20.0, durationMin: 20 },
    { title: 'Corte + Barba', price: 50.0, durationMin: 50 }
  ];

  for (const s of services) {
    const exists = await prisma.service.findFirst({ where: { title: s.title } });
    if (!exists) await prisma.service.create({ data: s });
  }

  let client = await prisma.client.findFirst({ where: { email: 'cliente@exemplo.com' } });
  if (!client) {
    client = await prisma.client.create({ data: { name: 'Cliente Demo', email: 'cliente@exemplo.com', phone: '0000' } });
  }

  const service = await prisma.service.findFirst();
  if (service) {
    await prisma.appointment.create({ data: { clientId: client.id, serviceId: service.id, startAt: new Date(), endAt: new Date(Date.now() + 1000 * 60 * service.durationMin) } });
  }

  console.log('Seeding finished');
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
