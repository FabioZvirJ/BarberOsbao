"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = __importDefault(require("supertest"));
const app_1 = __importDefault(require("../app"));
async function run() {
    console.log('Smoke test: GET /services');
    const s = await (0, supertest_1.default)(app_1.default).get('/services');
    console.log('status', s.status, 'body length', Array.isArray(s.body) ? s.body.length : typeof s.body);
    console.log('Smoke test: POST /services');
    const create = await (0, supertest_1.default)(app_1.default).post('/services').send({ title: 'Smoke Service', price: 9.9, durationMin: 20 });
    console.log('create status', create.status, 'id', create.body?.id);
    console.log('Smoke test: GET /clients');
    const c = await (0, supertest_1.default)(app_1.default).get('/clients');
    console.log('status', c.status, 'body length', Array.isArray(c.body) ? c.body.length : typeof c.body);
    console.log('Smoke test: POST /clients');
    const createC = await (0, supertest_1.default)(app_1.default).post('/clients').send({ name: 'Smoke Client' });
    console.log('create status', createC.status, 'id', createC.body?.id);
}
run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
