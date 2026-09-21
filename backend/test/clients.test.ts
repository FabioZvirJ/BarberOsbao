import request from 'supertest';
import app from '../src/app';

describe('Clients API', () => {
  it('GET /clients should return 200 and array', async () => {
    const res = await request(app).get('/clients');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /clients should create a client', async () => {
    const res = await request(app).post('/clients').send({ name: 'Test Client', email: 'test-client@example.com' });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.name).toBe('Test Client');
  });
});
