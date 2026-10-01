"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.register = register;
exports.login = login;
const app_1 = require("../app");
const bcrypt_1 = __importDefault(require("bcrypt"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const JWT_SECRET = process.env.JWT_SECRET || 'secret';
async function register(req, res) {
    const { email, password, name } = req.body;
    if (!email || !password)
        return res.status(400).json({ error: 'email and password required' });
    const exists = await app_1.prisma.user.findUnique({ where: { email } });
    if (exists)
        return res.status(409).json({ error: 'user exists' });
    const hash = await bcrypt_1.default.hash(password, 10);
    const user = await app_1.prisma.user.create({ data: { email, password: hash, name } });
    const token = jsonwebtoken_1.default.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
}
async function login(req, res) {
    const { email, password } = req.body;
    const user = await app_1.prisma.user.findUnique({ where: { email } });
    if (!user)
        return res.status(401).json({ error: 'invalid credentials' });
    const ok = await bcrypt_1.default.compare(password, user.password);
    if (!ok)
        return res.status(401).json({ error: 'invalid credentials' });
    const token = jsonwebtoken_1.default.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
}
