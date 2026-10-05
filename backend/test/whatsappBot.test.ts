import request from 'supertest';
import app, { prisma } from '../src/app';

describe('WhatsApp Bot & Webhook API', () => {
  const testPhone = `5541999${Math.floor(100000 + Math.random() * 900000)}`;
  jest.setTimeout(25000);

  afterAll(async () => {
    // Limpeza dos dados criados no teste
    try {
      await prisma.appointment.deleteMany({
        where: { clientPhone: { contains: testPhone.slice(-8) } },
      });
      await prisma.client.deleteMany({
        where: { phone: { contains: testPhone.slice(-8) } },
      });
      await prisma.user.deleteMany({
        where: { email: { contains: testPhone.slice(-8) } },
      });
    } catch (_) {}
  });

  it('GET /webhook/whatsapp should validate Meta webhook handshake', async () => {
    const res = await request(app)
      .get('/webhook/whatsapp')
      .query({
        'hub.mode': 'subscribe',
        'hub.verify_token': 'barberosbao_verify_token',
        'hub.challenge': 'CHALLENGE_ACCEPTED_123',
      });

    expect(res.status).toBe(200);
    expect(res.text).toBe('CHALLENGE_ACCEPTED_123');
  });

  it('GET /webhook/whatsapp with invalid token should return 403', async () => {
    const res = await request(app)
      .get('/webhook/whatsapp')
      .query({
        'hub.mode': 'subscribe',
        'hub.verify_token': 'wrong_token',
        'hub.challenge': 'CHALLENGE_ACCEPTED_123',
      });

    expect(res.status).toBe(403);
  });

  it('GET /webhook/whatsapp/status should return bot status', async () => {
    const res = await request(app).get('/webhook/whatsapp/status');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('online');
    expect(res.body).toHaveProperty('webhookUrl');
  });

  it('POST /webhook/whatsapp/simulate: new user should be asked for full name', async () => {
    const res = await request(app)
      .post('/webhook/whatsapp/simulate')
      .send({ phone: testPhone, text: 'Olá, gostaria de agendar' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.reply).toContain('BarberOsbao');
    expect(res.body.reply).toContain('Digite o seu Nome Completo');
  });

  it('POST /webhook/whatsapp/simulate: user inputs name -> gets registered', async () => {
    const res = await request(app)
      .post('/webhook/whatsapp/simulate')
      .send({ phone: testPhone, text: 'Rodrigo Medeiros' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.reply).toContain('Cadastro realizado com sucesso, Rodrigo Medeiros!');
    expect(res.body.reply).toContain('Agendar Novo Horário');
  });

  it('POST /webhook/whatsapp/simulate: user asks for services & prices (option 4)', async () => {
    const res = await request(app)
      .post('/webhook/whatsapp/simulate')
      .send({ phone: testPhone, text: '4' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.reply).toContain('Nossos Serviços & Valores');
  });

  it('POST /webhook/whatsapp/simulate: user checks my appointments (option 2)', async () => {
    const res = await request(app)
      .post('/webhook/whatsapp/simulate')
      .send({ phone: testPhone, text: '2' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.reply).toContain('Meus Agendamentos');
  });
});

