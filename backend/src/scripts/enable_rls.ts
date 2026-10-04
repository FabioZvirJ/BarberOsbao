import { prisma } from '../app';

const tables = [
  'User',
  'Client',
  'Employee',
  'Service',
  'Category',
  'Product',
  'StockMovement',
  'Plan',
  'Appointment',
  'FinancialTransaction',
  'Bill',
  'CashShift',
  'ClubBenefit',
  'ClubMember',
  'CashMovement',
];

async function enableRLS() {
  console.log('Enabling Row Level Security (RLS) on all Supabase tables...');
  for (const table of tables) {
    try {
      await prisma.$executeRawUnsafe(`ALTER TABLE "${table}" ENABLE ROW LEVEL SECURITY;`);
      console.log(`[OK] RLS enabled on table: "${table}"`);
    } catch (e: any) {
      console.warn(`[WARN] Could not enable RLS on "${table}": ${e.message}`);
    }
  }
  console.log('Row Level Security configuration complete.');
}

enableRLS()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
