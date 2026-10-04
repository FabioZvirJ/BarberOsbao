import request from 'supertest';
import app from '../src/app';

describe('Services API', () => {
  let authToken: string;

  beforeAll(async () => {
    const loginRes = await request(app)
      .post('/auth/login')
      .send({ email: 'admin@barberosbao.com.br', password: '123456' });

    if (loginRes.body.token) {
      authToken = loginRes.body.token;
    }
  });

  it('GET /services without token should return 401 Unauthorized', async () => {
    const res = await request(app).get('/services');
    expect(res.status).toBe(401);
  });

  it('GET /services with token should return 200 and array', async () => {
    const res = await request(app)
      .get('/services')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /services should create and then GET /services/:id', async () => {
    const create = await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ name: 'Test Service', price: 10.5, durationMinutes: 15 });
    expect(create.status).toBe(201);
    expect(create.body).toHaveProperty('id');
    const id = create.body.id;
    const get = await request(app)
      .get(`/services/${id}`)
      .set('Authorization', `Bearer ${authToken}`);
    expect(get.status).toBe(200);
    expect(get.body.name).toBe('Test Service');
  });
});
