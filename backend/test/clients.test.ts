import request from 'supertest';
import app from '../src/app';

describe('Clients API', () => {
  let authToken: string;
  jest.setTimeout(25000);

  beforeAll(async () => {
    // Autentica com a conta de admin para obter o Bearer token
    const loginRes = await request(app)
      .post('/auth/login')
      .send({ email: 'admin@barberosbao.com.br', password: '123456' });

    if (loginRes.body.token) {
      authToken = loginRes.body.token;
    }
  });

  it('GET /clients without token should return 401 Unauthorized', async () => {
    const res = await request(app).get('/clients');
    expect(res.status).toBe(401);
  });

  it('GET /clients with token should return 200 and array', async () => {
    const res = await request(app)
      .get('/clients')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /clients should create a client', async () => {
    const res = await request(app)
      .post('/clients')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ name: 'Test Client', email: `test-${Date.now()}@example.com` });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.name).toBe('Test Client');
  });
});
