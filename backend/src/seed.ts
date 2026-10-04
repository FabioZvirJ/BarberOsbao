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

  // Seed default admin and client users
  const bcrypt = await import('bcryptjs');
  const adminExists = await prisma.user.findUnique({ where: { email: 'admin@barberosbao.com.br' } });
  if (!adminExists) {
    const adminHash = await bcrypt.default.hash('123456', 10);
    await prisma.user.create({
      data: {
        email: 'admin@barberosbao.com.br',
        password: adminHash,
        name: 'Administrador BarberOsbao',
        phone: '(11) 98888-8888',
        role: 'admin',
      },
    });
    console.log('Seeded admin user (admin@barberosbao.com.br)');
  }

  const clientExists = await prisma.user.findUnique({ where: { email: 'cliente@barberosbao.com.br' } });
  if (!clientExists) {
    const clientHash = await bcrypt.default.hash('123456', 10);
    await prisma.user.create({
      data: {
        email: 'cliente@barberosbao.com.br',
        password: clientHash,
        name: 'Cliente BarberOsbao',
        phone: '(11) 97777-7777',
        role: 'client',
      },
    });
    console.log('Seeded demo client user (cliente@barberosbao.com.br)');
  }

  console.log('Seeding finished');
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
