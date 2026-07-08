import { Plan, Membership } from '../types';
import { ApiClient } from './api';
import { getInitialDB, saveDB } from './mockData';

export class MembershipService {
  public static async getPlans(): Promise<Plan[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.plans;
    });
  }

  public static async getActiveMembership(): Promise<Membership | null> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      // Return active membership if any
      const active = db.memberships.find(m => m.status === 'active');
      return active || null;
    });
  }

  public static async subscribeToPlan(planId: string): Promise<Membership> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      const plan = db.plans.find(p => p.id === planId);
      if (!plan) {
        throw new Error('Plano não encontrado.');
      }

      // Expire any existing memberships
      db.memberships = db.memberships.map(m => ({
        ...m,
        status: 'expired' as const
      }));

      const startDate = new Date();
      const endDate = new Date();
      endDate.setMonth(endDate.getMonth() + 1);

      const newMembership: Membership = {
        id: `mem-${Math.random().toString(36).substring(2, 9)}`,
        userId: db.currentUser.id,
        planId: plan.id,
        planName: plan.name,
        startDate: startDate.toISOString().split('T')[0],
        endDate: endDate.toISOString().split('T')[0],
        status: 'active',
        remainingBenefits: [...plan.benefits],
        discountsUsed: 0,
        nextRenewalDate: endDate.toISOString().split('T')[0]
      };

      db.memberships.push(newMembership);
      saveDB(db);
      return newMembership;
    });
  }

  public static async cancelMembership(): Promise<boolean> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      db.memberships = db.memberships.map(m => {
        if (m.status === 'active') {
          return {
            ...m,
            status: 'inactive' as const // Marked inactive but maybe still available until endDate
          };
        }
        return m;
      });
      saveDB(db);
      return true;
    });
  }
}
