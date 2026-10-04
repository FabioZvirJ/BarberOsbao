import request from 'supertest';
import app from '../src/app';

describe('Users API (Admin Only)', () => {
  let adminToken: string;
  let testUserId: string;
  const testEmail = `test-user-${Date.now()}@example.com`;

  jest.setTimeout(25000);

  beforeAll(async () => {
    const loginRes = await request(app)
      .post('/auth/login')
      .send({ email: 'admin@barberosbao.com.br', password: '123456' });

    if (loginRes.body.token) {
      adminToken = loginRes.body.token;
    }
  });

  it('GET /users without token should return 401', async () => {
    const res = await request(app).get('/users');
    expect(res.status).toBe(401);
  });

  it('GET /users with admin token should return 200 array', async () => {
    const res = await request(app)
      .get('/users')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /users should validate required fields', async () => {
    const res = await request(app)
      .post('/users')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ name: 'A', email: 'invalid-email', password: '123' });
    expect(res.status).toBe(400);
  });

  it('POST /users should create a user with valid data', async () => {
    const res = await request(app)
      .post('/users')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        name: 'Usuário Teste Admin',
        email: testEmail,
        password: 'SenhaForte123',
        phone: '(42) 99999-0000',
        role: 'barber',
      });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.email).toBe(testEmail);
    expect(res.body.role).toBe('barber');
    testUserId = res.body.id;
  });

  it('DELETE /users/:id should delete the created user', async () => {
    if (!testUserId) return;
    const res = await request(app)
      .delete(`/users/${testUserId}`)
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.status).toBe(200);
  });
});

