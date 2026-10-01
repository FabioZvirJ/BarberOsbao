"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = __importDefault(require("supertest"));
const app_1 = __importDefault(require("../src/app"));
describe('Services API', () => {
    it('GET /services should return 200 and array', async () => {
        const res = await (0, supertest_1.default)(app_1.default).get('/services');
        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
    });
    it('POST /services should create and then GET /services/:id', async () => {
        const create = await (0, supertest_1.default)(app_1.default).post('/services').send({ title: 'Test Service', price: 10.5, durationMin: 15 });
        expect(create.status).toBe(201);
        expect(create.body).toHaveProperty('id');
        const id = create.body.id;
        const get = await (0, supertest_1.default)(app_1.default).get(`/services/${id}`);
        expect(get.status).toBe(200);
        expect(get.body.title).toBe('Test Service');
    });
});
