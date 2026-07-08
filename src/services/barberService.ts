import { Barber } from '../types';
import { ApiClient } from './api';
import { getInitialDB } from './mockData';

export class BarberService {
  public static async getBarbers(): Promise<Barber[]> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.barbers;
    });
  }

  public static async getBarberById(id: string): Promise<Barber | null> {
    return ApiClient.request(() => {
      const db = getInitialDB();
      return db.barbers.find(b => b.id === id) || null;
    });
  }
}
