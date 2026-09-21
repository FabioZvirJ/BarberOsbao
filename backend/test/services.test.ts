import request from 'supertest';
import app from '../src/app';

describe('Services API', () => {
  it('GET /services should return 200 and array', async () => {
    const res = await request(app).get('/services');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /services should create and then GET /services/:id', async () => {
    const create = await request(app).post('/services').send({ title: 'Test Service', price: 10.5, durationMin: 15 });
    expect(create.status).toBe(201);
    expect(create.body).toHaveProperty('id');
    const id = create.body.id;
    const get = await request(app).get(`/services/${id}`);
    expect(get.status).toBe(200);
    expect(get.body.title).toBe('Test Service');
  });
});
