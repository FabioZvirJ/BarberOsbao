import request from 'supertest';
import app from '../app';

async function run() {
  console.log('Smoke test: GET /services');
  const s = await request(app).get('/services');
  console.log('status', s.status, 'body length', Array.isArray(s.body) ? s.body.length : typeof s.body);

  console.log('Smoke test: POST /services');
  const create = await request(app).post('/services').send({ title: 'Smoke Service', price: 9.9, durationMin: 20 });
  console.log('create status', create.status, 'id', create.body?.id);

  console.log('Smoke test: GET /clients');
  const c = await request(app).get('/clients');
  console.log('status', c.status, 'body length', Array.isArray(c.body) ? c.body.length : typeof c.body);

  console.log('Smoke test: POST /clients');
  const createC = await request(app).post('/clients').send({ name: 'Smoke Client' });
  console.log('create status', createC.status, 'id', createC.body?.id);
}

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
