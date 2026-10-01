Backend scaffold for BarberOsbao

Stack: Node.js + TypeScript + Express + Prisma + PostgreSQL + Docker

Setup

1. Copy `.env.example` to `.env` and configure `DATABASE_URL` and `JWT_SECRET`.
2. Install dependencies:

```bash
cd backend
npm install
```

3. Run Prisma migrations (if using local Postgres) or use Docker Compose below:

```bash
npx prisma generate
npx prisma migrate dev --name init
npm run dev
```

Using Docker Compose:

```bash
cd backend
docker compose up --build
```

API endpoints (minimal):
- `POST /auth/register`
- `POST /auth/login`
- `GET /clients`
- `POST /clients`
- `GET /appointments`
- `POST /appointments`

Next steps:
- Add validation, tests, logging, rate limiting, OpenAPI docs.
- Configure CI/CD and backups for Postgres.
