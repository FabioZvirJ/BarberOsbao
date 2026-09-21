"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = __importDefault(require("supertest"));
const app_1 = __importDefault(require("../src/app"));
describe('Clients API', () => {
    it('GET /clients should return 200 and array', async () => {
        const res = await (0, supertest_1.default)(app_1.default).get('/clients');
        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
    });
    it('POST /clients should create a client', async () => {
        const res = await (0, supertest_1.default)(app_1.default).post('/clients').send({ name: 'Test Client', email: 'test-client@example.com' });
        expect(res.status).toBe(201);
        expect(res.body).toHaveProperty('id');
        expect(res.body.name).toBe('Test Client');
    });
});
